#!/bin/bash
# Script to encode the keystore for GitHub Secrets storage

KEYSTORE_FILE="android/app/keystore.jks"

if [ ! -f "$KEYSTORE_FILE" ]; then
  echo "Error: $KEYSTORE_FILE not found"
  exit 1
fi

echo "Encoding keystore to base64..."
base64 < "$KEYSTORE_FILE" | pbcopy || base64 < "$KEYSTORE_FILE"

echo ""
echo "✓ Keystore has been encoded to base64."
echo "  If on macOS, the output has been copied to your clipboard."
echo "  If not on macOS, copy the output above."
echo ""
echo "Next steps:"
echo "1. Go to your GitHub repository"
echo "2. Settings → Secrets and variables → Actions → New repository secret"
echo "3. Create the following secrets:"
echo "   - KEYSTORE_BASE64: (paste the base64 string)"
echo "   - KEYSTORE_STORE_PASSWORD: (your keystore password)"
echo "   - KEYSTORE_KEY_PASSWORD: (your key password)"
echo "   - KEYSTORE_KEY_ALIAS: (your key alias)"
echo ""
echo "For testing, you can use the default values:"
echo "   KEYSTORE_STORE_PASSWORD: callbs_pass"
echo "   KEYSTORE_KEY_PASSWORD: callbs_pass"
echo "   KEYSTORE_KEY_ALIAS: callbs_key"
