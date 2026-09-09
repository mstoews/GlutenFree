#!/usr/bin/env bash
# deploy_testflight.sh — archive, export, and upload GlutenFree to TestFlight
#
# Requires an App Store Connect API key. Store credentials in ~/.config/gurufuri/asc.env:
#   ASC_KEY_ID=XXXXXXXXXX
#   ASC_ISSUER_ID=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
#   ASC_KEY_PATH=/path/to/AuthKey_XXXXXXXXXX.p8
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
ENV_FILE="$HOME/.config/gurufuri/asc.env"
SCRATCHPAD="$TMPDIR/gurufuri_build"

# Load credentials
if [[ ! -f "$ENV_FILE" ]]; then
  echo "ERROR: $ENV_FILE not found. Create it with ASC_KEY_ID, ASC_ISSUER_ID, ASC_KEY_PATH." >&2
  exit 1
fi
# shellcheck source=/dev/null
source "$ENV_FILE"

: "${ASC_KEY_ID:?ASC_KEY_ID not set in $ENV_FILE}"
: "${ASC_ISSUER_ID:?ASC_ISSUER_ID not set in $ENV_FILE}"
: "${ASC_KEY_PATH:?ASC_KEY_PATH not set in $ENV_FILE}"

if [[ ! -f "$ASC_KEY_PATH" ]]; then
  echo "ERROR: API key file not found at $ASC_KEY_PATH" >&2
  exit 1
fi

ARCHIVE_PATH="$SCRATCHPAD/GlutenFree.xcarchive"
EXPORT_PATH="$SCRATCHPAD/export"
EXPORT_OPTIONS="$SCRIPT_DIR/ExportOptions.plist"

rm -rf "$SCRATCHPAD"
mkdir -p "$SCRATCHPAD"

echo "==> Archiving…"
xcodebuild archive \
  -project "$PROJECT_ROOT/GlutenFree.xcodeproj" \
  -scheme GlutenFree \
  -configuration Release \
  -destination "generic/platform=iOS" \
  -archivePath "$ARCHIVE_PATH" \
  -allowProvisioningUpdates \
  -authenticationKeyPath "$ASC_KEY_PATH" \
  -authenticationKeyID "$ASC_KEY_ID" \
  -authenticationKeyIssuerID "$ASC_ISSUER_ID" \
  CODE_SIGN_STYLE=Automatic \
  DEVELOPMENT_TEAM=EF24PCZNX7 \
  | grep -E "^(error:|warning:|.*ARCHIVE)" || true

echo "==> Exporting IPA…"
xcodebuild -exportArchive \
  -archivePath "$ARCHIVE_PATH" \
  -exportPath "$EXPORT_PATH" \
  -exportOptionsPlist "$EXPORT_OPTIONS" \
  -allowProvisioningUpdates \
  -authenticationKeyPath "$ASC_KEY_PATH" \
  -authenticationKeyID "$ASC_KEY_ID" \
  -authenticationKeyIssuerID "$ASC_ISSUER_ID" \
  | grep -E "^(error:|warning:|.*EXPORT)" || true

IPA="$(find "$EXPORT_PATH" -name "*.ipa" | head -1)"
if [[ -z "$IPA" ]]; then
  echo "ERROR: No .ipa found in $EXPORT_PATH" >&2
  exit 1
fi

echo "==> Uploading to TestFlight…"
xcrun altool --upload-app \
  --type ios \
  --file "$IPA" \
  --apiKey "$ASC_KEY_ID" \
  --apiIssuer "$ASC_ISSUER_ID" \
  --verbose

echo "==> Done. Build will appear in TestFlight in ~15 minutes."
