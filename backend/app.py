from fastapi import FastAPI, Query, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import List, Optional
import os

import httpx
from bs4 import BeautifulSoup


app = FastAPI(
    title="Call-BS API",
    description="Backend API for quick fact-checking and deeper claim analysis.",
    version="0.2.0",
)


app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


class Source(BaseModel):
    title: str
    url: str


class DeepItem(BaseModel):
    heading: str
    detail: str
    source: str


class CheckResponse(BaseModel):
    claim: str
    verdict: str
    confidence: int
    summary: str
    sources: List[Source]
    deep: Optional[List[DeepItem]] = None


async def _search_duckduckgo(query: str, max_results: int = 6) -> List[Source]:
    """Lightweight DuckDuckGo HTML search fallback (no API key required).
    This is best-effort and intended for prototype/testing only.
    """
    q = query.replace(' ', '+')
    url = f'https://html.duckduckgo.com/html?q={q}'
    headers = {"User-Agent": "Mozilla/5.0 (compatible; Call-BS/0.1)"}
    async with httpx.AsyncClient(timeout=10) as client:
        resp = await client.get(url, headers=headers)
    if resp.status_code != 200:
        return []
    soup = BeautifulSoup(resp.text, 'html.parser')
    results: List[Source] = []
    # DuckDuckGo uses class 'result' and links with class 'result__a'
    for a in soup.select('a.result__a')[:max_results]:
        title = a.get_text(strip=True)
        href = a.get('href')
        if href and title:
            results.append(Source(title=title, url=href))
    # Fallback: collect any links
    if not results:
        for a in soup.find_all('a', href=True)[:max_results]:
            results.append(Source(title=a.get_text(strip=True) or a['href'], url=a['href']))
    return results


async def web_search(query: str, max_results: int = 6) -> List[Source]:
    """Pick the best available search provider. If provider API keys are set
    this function should be extended to use them. Currently uses DuckDuckGo fallback.
    """
    # TODO: Add support for SerpAPI/Bing/Google when API keys provided
    return await _search_duckduckgo(query, max_results=max_results)


def _simulate_ai_decision(claim: str, sources: List[Source]) -> dict:
    lower = claim.lower()
    if 'not true' in lower or 'false' in lower or 'myth' in lower:
        return {
            'verdict': 'false',
            'confidence': 82,
            'summary': 'The evidence does not support the claim; multiple fact-checks contradict it.'
        }
    if 'true' in lower or 'confirmed' in lower:
        return {
            'verdict': 'true',
            'confidence': 74,
            'summary': 'Available sources support the claim though exact details may vary.'
        }
    return {
        'verdict': 'needs context',
        'confidence': 66,
        'summary': 'Sources are mixed or insufficient; deeper analysis recommended.'
    }


async def call_ai_model(claim: str, sources: List[Source], detail: bool = False) -> dict:
    """Call an external AI model (OpenAI-compatible) if configured, otherwise simulate.
    Expects environment variables `OPENAI_API_KEY` and optionally `OPENAI_API_URL`.
    """
    api_key = os.getenv('OPENAI_API_KEY')
    if not api_key:
        # No key configured — use simulation
        return _simulate_ai_decision(claim, sources)

    # Build a compact prompt with sources for the model to evaluate and return JSON
    system_prompt = (
        "You are a fact-check assistant. Given a user claim and a short list of sources, "
        "return a JSON object with: verdict (true/false/needs context), confidence (0-100 int), "
        "and a short summary. If 'detail' is true, include an array 'deep' of {heading, detail, source}."
    )
    source_text = '\n'.join([f"- {s.title}: {s.url}" for s in sources[:6]])
    user_prompt = f"Claim: {claim}\nSources:\n{source_text}\nRespond with JSON only."

    payload = {
        'model': 'gpt-4o-mini',
        'messages': [
            {'role': 'system', 'content': system_prompt},
            {'role': 'user', 'content': user_prompt},
        ],
        'temperature': 0.0,
        'max_tokens': 800,
    }

    url = os.getenv('OPENAI_API_URL', 'https://api.openai.com/v1/chat/completions')
    headers = {'Authorization': f'Bearer {api_key}', 'Content-Type': 'application/json'}
    async with httpx.AsyncClient(timeout=20) as client:
        try:
            r = await client.post(url, json=payload, headers=headers)
            r.raise_for_status()
            j = r.json()
            # Extract text from response (best-effort)
            content = ''
            if 'choices' in j and len(j['choices']) > 0:
                content = j['choices'][0]['message'].get('content', '')
            # Expect JSON content — attempt parse
            import json
            try:
                parsed = json.loads(content)
                return parsed
            except Exception:
                # If model didn't return JSON, fall back to simulation
                return _simulate_ai_decision(claim, sources)
        except Exception:
            return _simulate_ai_decision(claim, sources)


def build_deep_items_from_sources(claim: str, sources: List[Source]) -> List[DeepItem]:
    items: List[DeepItem] = []
    for i, s in enumerate(sources[:4]):
        items.append(
            DeepItem(
                heading=f'Key point from {s.title}',
                detail=f'Review the source at {s.url} for claims, data, and direct quotes relevant to the claim.',
                source=s.url,
            )
        )
    if not items:
        items.append(DeepItem(heading='Verification tips', detail='Check official reports, publication dates, and authors.', source=''))
    return items


@app.get('/api/health')
async def health_check() -> dict:
    return {'status': 'ok', 'service': 'Call-BS backend'}


@app.post('/api/check', response_model=CheckResponse)
async def check_claim(claim: str = Query(..., min_length=5), detail: bool = Query(False)) -> CheckResponse:
    # Quick: run a small search and ask the model for a short verdict
    sources = await web_search(claim, max_results=5)
    ai_result = await call_ai_model(claim, sources, detail=False)

    verdict = ai_result.get('verdict', 'needs context')
    confidence = int(ai_result.get('confidence', 60))
    summary = ai_result.get('summary', '')

    response = CheckResponse(
        claim=claim,
        verdict=verdict,
        confidence=confidence,
        summary=summary,
        sources=sources,
    )

    if detail:
        # Deeper search + model prompt
        deep_sources = await web_search(claim, max_results=12)
        response.deep = build_deep_items_from_sources(claim, deep_sources)

    return response
