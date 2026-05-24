import os
import httpx
import json
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from anthropic import Anthropic
from dotenv import load_dotenv

load_dotenv()

app = FastAPI(title="Call BS API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

client = Anthropic()


class ClaimRequest(BaseModel):
    claim: str


async def search_web(query: str, count: int = 5) -> list[dict]:
    api_key = os.getenv("BRAVE_SEARCH_API_KEY")
    if not api_key:
        return []

    async with httpx.AsyncClient() as http:
        response = await http.get(
            "https://api.search.brave.com/res/v1/web/search",
            headers={"Accept": "application/json", "X-Subscription-Token": api_key},
            params={"q": query, "count": count, "search_lang": "en"},
            timeout=10.0,
        )
        if response.status_code != 200:
            return []
        data = response.json()
        results = []
        for r in data.get("web", {}).get("results", []):
            results.append({
                "title": r.get("title", ""),
                "url": r.get("url", ""),
                "snippet": r.get("description", ""),
            })
        return results


def analyze_with_claude(claim: str, sources: list[dict], deep: bool = False) -> dict:
    sources_text = "\n".join([
        f"[{i+1}] {s['title']}\nURL: {s['url']}\nSnippet: {s['snippet']}"
        for i, s in enumerate(sources)
    ])

    if deep:
        prompt = f"""You are a rigorous fact-checker. Analyze this claim thoroughly using the provided sources.

Claim: "{claim}"

Sources:
{sources_text}

Respond ONLY with valid JSON in this exact format:
{{
  "verdict": "true" OR "false" OR "needs_context",
  "confidence": <float 0.0-1.0>,
  "summary": "<2-3 sentence summary of your finding>",
  "analysis": "<detailed multi-paragraph analysis explaining the evidence>",
  "key_points": ["<key finding 1>", "<key finding 2>", "<key finding 3>"],
  "source_assessments": [
    {{"index": 1, "relevance": "<why this source matters or doesn't>"}},
    ...
  ]
}}

Rules:
- verdict "true": claim is supported by credible evidence
- verdict "false": claim is contradicted by credible evidence
- verdict "needs_context": claim is partially true, misleading, or lacks sufficient evidence
- confidence: your confidence level (0.5=uncertain, 0.9=very confident)
- Be honest when sources are insufficient"""
    else:
        prompt = f"""You are a fact-checker. Quickly assess this claim using the provided sources.

Claim: "{claim}"

Sources:
{sources_text}

Respond ONLY with valid JSON in this exact format:
{{
  "verdict": "true" OR "false" OR "needs_context",
  "confidence": <float 0.0-1.0>,
  "summary": "<1-2 sentence verdict explanation>"
}}

Rules:
- verdict "true": claim is supported by credible evidence
- verdict "false": claim is contradicted by credible evidence
- verdict "needs_context": claim is partially true, misleading, or lacks sufficient evidence
- confidence: 0.5=uncertain, 0.9=very confident"""

    message = client.messages.create(
        model="claude-sonnet-4-6",
        max_tokens=1024 if not deep else 2048,
        messages=[{"role": "user", "content": prompt}]
    )

    text = message.content[0].text.strip()
    # Strip markdown code fences if present
    if text.startswith("```"):
        text = text.split("```")[1]
        if text.startswith("json"):
            text = text[4:]
    return json.loads(text)


@app.get("/health")
def health():
    return {"status": "ok"}


@app.post("/check")
async def quick_check(req: ClaimRequest):
    if not req.claim.strip():
        raise HTTPException(status_code=400, detail="Claim cannot be empty")

    sources = await search_web(req.claim, count=5)
    result = analyze_with_claude(req.claim, sources, deep=False)

    return {
        "claim": req.claim,
        "verdict": result["verdict"],
        "confidence": result["confidence"],
        "summary": result["summary"],
        "sources": sources,
    }


@app.post("/deep-check")
async def deep_check(req: ClaimRequest):
    if not req.claim.strip():
        raise HTTPException(status_code=400, detail="Claim cannot be empty")

    sources = await search_web(req.claim, count=10)
    result = analyze_with_claude(req.claim, sources, deep=True)

    # Attach relevance info to sources
    enriched_sources = sources.copy()
    for assessment in result.get("source_assessments", []):
        idx = assessment.get("index", 0) - 1
        if 0 <= idx < len(enriched_sources):
            enriched_sources[idx]["relevance"] = assessment.get("relevance", "")

    return {
        "claim": req.claim,
        "verdict": result["verdict"],
        "confidence": result["confidence"],
        "summary": result["summary"],
        "analysis": result.get("analysis", ""),
        "key_points": result.get("key_points", []),
        "sources": enriched_sources,
    }
