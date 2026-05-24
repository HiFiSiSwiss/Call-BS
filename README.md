# Call BS

A mobile fact-checking app that uses AI and live web search to instantly verdict any claim as **TRUE**, **BS**, or **IT'S COMPLICATED**.

## Overview

Call BS lets you enter any claim and get an AI-powered fact-check backed by real web sources. It features a quick check mode (3-5 sources, fast) and a deep analysis mode (8-10 sources, detailed breakdown with key points and full analysis).

**Tech stack:**
- Flutter (Android) — dark-themed mobile UI with animated verdict cards
- FastAPI (Python) — lightweight REST backend
- Claude AI (`claude-sonnet-4-6`) — verdict reasoning and analysis
- Brave Search API — live web source retrieval

---

## Architecture

```
Call-BS/
├── app/                        # Flutter Android app
│   ├── lib/
│   │   ├── main.dart
│   │   ├── models/             # FactCheckResult, Source, Verdict
│   │   ├── services/           # ApiService (HTTP calls to backend)
│   │   ├── providers/          # FactCheckProvider (state management)
│   │   ├── screens/            # HomeScreen
│   │   └── widgets/            # ClaimInput, ResultCard, LoadingIndicator
│   ├── android/
│   │   └── app/src/main/
│   │       └── AndroidManifest.xml
│   └── pubspec.yaml
├── backend/                    # FastAPI Python backend
│   ├── main.py
│   ├── requirements.txt
│   ├── .env.example
│   └── Dockerfile
└── docker-compose.yml
```

---

## API Keys Required

| Service | Purpose | Get it at |
|---|---|---|
| Anthropic | Claude AI fact analysis | https://console.anthropic.com |
| Brave Search | Live web search results | https://brave.com/search/api/ |

---

## Backend Setup

### Option 1: Local Python

```bash
cd backend
python -m venv venv
source venv/bin/activate        # Windows: venv\Scripts\activate
pip install -r requirements.txt

# Set up environment variables
cp .env.example .env
# Edit .env and add your API keys

uvicorn main:app --reload --port 8000
```

The API will be available at `http://localhost:8000`.

### Option 2: Docker Compose

```bash
cp backend/.env.example backend/.env
# Edit backend/.env and add your API keys

docker-compose up --build
```

### API Endpoints

| Method | Path | Description |
|---|---|---|
| GET | `/health` | Health check |
| POST | `/check` | Quick fact-check (~3-5 sources) |
| POST | `/deep-check` | Deep analysis (~8-10 sources) |

**Request body** (both POST endpoints):
```json
{ "claim": "The Great Wall of China can be seen from space" }
```

---

## Flutter App Setup

### Prerequisites
- Flutter SDK >= 3.0.0
- Android SDK / Android emulator or physical device

### Run the app

```bash
cd app
flutter pub get
flutter run
```

By default the app connects to `http://10.0.2.2:8000` which is the Android emulator's alias for `localhost` on your development machine. Start the backend first, then launch the emulator.

To target a real device or deployed backend, update `_baseUrl` in `app/lib/services/api_service.dart`.

### Build APK

```bash
cd app
flutter build apk --release
```

The APK will be at `build/app/outputs/flutter-apk/app-release.apk`.

---

## Features

- **Quick Check** — submits a claim and returns a verdict in seconds with 3-5 web sources
- **Deep Analysis** — expands to 8-10 sources with key points, full multi-paragraph analysis, and per-source relevance notes
- **Animated verdict card** — color-coded (green = TRUE, red = BS, amber = IT'S COMPLICATED) with an animated confidence bar
- **Tappable sources** — opens source URLs in the device browser
- **Dark theme** — sleek dark UI with smooth flutter_animate transitions
