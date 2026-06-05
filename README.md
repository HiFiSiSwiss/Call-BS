# Call-BS

A cross-platform fact-checking mobile app built with Flutter and a backend API. Users enter a claim, receive a quick verdict with a confidence score, and can tap through for a deeper evidence-based breakdown.

## Structure

- `lib/` — Flutter app code
- `backend/` — API service for claim evaluation and source analysis

## Run the backend

```bash
cd backend
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
uvicorn app:app --reload --host 0.0.0.0 --port 8000
```

## Run the mobile app

```bash
cd /Users/simonmcdaniell/Call-BS
flutter pub get
flutter run
```

### Notes

- Use `http://10.0.2.2:8000` for Android emulator access to the local backend.
- Use `http://localhost:8000` for iOS simulator.
- Replace the backend simulation logic in `backend/app.py` with a real web search integration and AI model evaluation for production.

## Build signed APK/AAB

### Local build

```bash
flutter build apk --release
flutter build appbundle --release
```

Output files:
- APK: `build/app/outputs/flutter-apk/app-release.apk`
- AAB: `build/app/outputs/bundle/release/app-release.aab`

### GitHub Actions CI/CD

Automatic signed builds on push to `main` or tag creation. See [GITHUB_ACTIONS_SETUP.md](GITHUB_ACTIONS_SETUP.md) for configuration.

Quick setup:
```bash
bash scripts/encode-keystore.sh
# Copy output to GitHub Secrets (see GITHUB_ACTIONS_SETUP.md)
git push origin main  # Triggers automated build
```
