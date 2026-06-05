# Call-BS Backend

This backend provides a simple API for claim analysis and deeper claim evaluation.

## Run locally

1. Create a virtual environment:

```bash
python3 -m venv .venv
source .venv/bin/activate
```

2. Install dependencies:

```bash
pip install -r requirements.txt
```

3. Start the API server:

```bash
uvicorn app:app --reload --host 0.0.0.0 --port 8000
```

## API endpoints

- `GET /api/health`
- `POST /api/check?detail=false&claim=...`

For Android emulator use `http://10.0.2.2:8000`; for iOS simulator use `http://localhost:8000`.

## AI integration

The backend supports calling an OpenAI-compatible chat completion endpoint. To enable it set:

- `OPENAI_API_KEY` — your API key
- `OPENAI_API_URL` — optional custom URL (defaults to OpenAI's `https://api.openai.com/v1/chat/completions`)

If `OPENAI_API_KEY` is not provided the backend will run a deterministic simulation which is useful for development.

## Notes and next steps

- The current web search uses a DuckDuckGo HTML fallback — replace with SerpAPI/Bing/Google for production (requires API keys).
- The AI prompt expects JSON output; the connector attempts to parse model output and falls back to a simulation if parsing fails.
