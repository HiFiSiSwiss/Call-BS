# GitHub Actions CI/CD Setup for Call-BS

This document explains how to set up GitHub Actions to automatically build signed APK and AAB artifacts.

## Overview

The workflow (`.github/workflows/build-release.yml`) will:
- Trigger on push to `main` branch or when you create a version tag (`v*`)
- Set up Java 17 and Flutter
- Decrypt your keystore from GitHub Secrets
- Build a signed release APK and AAB
- Upload artifacts to GitHub Actions
- Create a GitHub Release (when pushing a tag)

## Prerequisites

- The keystore file at `android/app/keystore.jks`
- Keystore credentials (store password, key password, key alias)
- A GitHub repository

## Setup Steps

### 1. Encode Your Keystore

Run the helper script to convert your keystore to base64:

```bash
bash scripts/encode-keystore.sh
```

This will output or copy to clipboard a base64-encoded string of your keystore.

### 2. Create GitHub Secrets

In your GitHub repository:

1. Go to **Settings → Secrets and variables → Actions**
2. Click **"New repository secret"** and create these four secrets:

| Secret Name | Value |
|---|---|
| `KEYSTORE_BASE64` | (Paste the base64 output from step 1) |
| `KEYSTORE_STORE_PASSWORD` | `callbs_pass` (or your store password) |
| `KEYSTORE_KEY_PASSWORD` | `callbs_pass` (or your key password) |
| `KEYSTORE_KEY_ALIAS` | `callbs_key` (or your key alias) |

### 3. Trigger a Build

Push to the `main` branch or create a tag:

```bash
# Push to main (runs workflow)
git push origin main

# Or create a release tag (runs workflow + creates GitHub Release)
git tag v1.0.0
git push origin v1.0.0
```

### 4. Monitor the Build

- Go to your repository → **Actions** tab
- Click the running workflow to see real-time logs
- After completion, download APK/AAB from **Artifacts**

## Outputs

### APK (Android Package)
- File: `app-release.apk`
- Use for: Direct installation on Android devices, side-loading
- Location: GitHub Actions > Artifacts > `call-bs-release.apk`

### AAB (Android App Bundle)
- File: `app-release.aab`
- Use for: Google Play Store distribution (recommended)
- Location: GitHub Actions > Artifacts > `call-bs-release.aab`

## Publishing to Google Play Store

Once you have an AAB:

1. Create a Google Play Developer account (if not already done)
2. Create an app in Google Play Console
3. Upload the AAB to the store using Play Console

Or, you can configure the workflow to auto-upload to Play Store:

```yaml
# Add to the workflow after building AAB:
- name: Upload to Play Store
  uses: r0adkll/upload-google-play@v1
  with:
    serviceAccountJson: ${{ secrets.PLAY_STORE_SERVICE_ACCOUNT_JSON }}
    packageName: com.callbs.call_bs
    releaseFiles: build/app/outputs/bundle/release/app-release.aab
    track: internal  # or 'beta', 'production'
```

For this, you'll also need to:
- Generate a service account JSON from Google Cloud Console
- Add it as a GitHub Secret named `PLAY_STORE_SERVICE_ACCOUNT_JSON`

## Debugging Failed Builds

If a build fails:

1. Check the **Actions** tab logs for error details
2. Common issues:
   - Incorrect keystore password in secrets
   - Keystore base64 not properly encoded
   - Outdated Flutter or Java version

To re-run a failed workflow:
- Go to the failed action → Click **Re-run failed jobs** or **Re-run all jobs**

## Security Best Practices

- Never commit `android/app/keystore.jks` or `android/key.properties` to Git
- Rotate keystore passwords periodically (requires re-encoding)
- Use different keystores for dev/staging/production
- Store the original keystore file in a secure vault (not in Git)
- Review GitHub Secrets regularly for unused or old entries

## Manual Build

To build locally without CI:

```bash
flutter build apk --release
flutter build appbundle --release
```

Artifacts will be in:
- APK: `build/app/outputs/flutter-apk/app-release.apk`
- AAB: `build/app/outputs/bundle/release/app-release.aab`

## Next Steps

- Configure Play Store publishing (auto-upload via secrets)
- Add beta/staging environments with separate keystores
- Set up code signing for iOS (similar process)
- Add backend deployment to the workflow
