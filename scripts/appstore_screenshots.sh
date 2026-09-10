#!/usr/bin/env bash
#
# Capture App Store Connect screenshots for GlutenFree / グルフリ.
#
# Runs GlutenFreeUITests/AppStoreShots against each required device size and
# each App Store localization, then pulls the XCTAttachment screenshots out of
# the result bundle into screenshots/<size>/<locale>/NN-name.png.
#
# App Store Connect (2026) accepts one iPhone set and one iPad set for a
# universal app; every other size is derived from those. This captures:
#
#   iPhone 6.9"  1320 x 2868   iPhone 17 Pro Max
#   iPad 13"     2064 x 2752   iPad Pro 13-inch (M5)
#
# The Go backend must be on :8090 with the subscribed demo account, or the menu
# screen comes out as the paywall:
#
#   cd ~/projects/glutenfree/glutenfree-go-server && make server
#
# Usage:
#   scripts/appstore_screenshots.sh                 # everything
#   scripts/appstore_screenshots.sh iphone          # one size
#   scripts/appstore_screenshots.sh iphone ja       # one size, one locale
#
set -euo pipefail

cd "$(dirname "$0")/.."
PROJECT_DIR="$PWD"
OUT_DIR="$PROJECT_DIR/screenshots"
DERIVED="/tmp/gf-dd"
WORK="/tmp/gf-appstore"
API="${GF_API_BASE_URL:-http://localhost:8090}"

# size-key | device name | expected WxH | udid resolved at run time
DEVICES=(
  "iphone-6.9|iPhone 17 Pro Max|1320x2868"
  "ipad-13|iPad Pro 13-inch (M5)|2064x2752"
)
LOCALES=("ja|ja_JP" "en|en_US")

ONLY_SIZE="${1:-}"
ONLY_LOCALE="${2:-}"

log() { printf '\033[1;36m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m warn\033[0m %s\n' "$*"; }
die() { printf '\033[1;31m!!\033[0m %s\n' "$*" >&2; exit 1; }

# --- preflight ---------------------------------------------------------------

curl -sf -m 5 "$API/health" >/dev/null \
  || die "backend not answering at $API/health — start it with 'make server' in glutenfree-go-server"
log "backend up at $API"

# The test hardcodes the same default. A non-default host only reaches the app
# if TEST_RUNNER_ propagation works in this Xcode; say so rather than silently
# capturing against localhost.
if [[ "$API" != "http://localhost:8090" ]]; then
  warn "GF_API_BASE_URL is $API — verify the captures really hit it, the runner may fall back to localhost:8090"
fi

# --- helpers -----------------------------------------------------------------

# Newest simulator udid for an exact device name.
udid_for() {
  xcrun simctl list devices available -j | python3 -c '
import sys, json
name = sys.argv[1]
data = json.load(sys.stdin)["devices"]
best = None
for runtime, devices in data.items():
    if "iOS" not in runtime:
        continue
    # runtime keys sort lexically wrong (iOS-26-5 vs iOS-9-0); parse the numbers.
    version = tuple(int(p) for p in runtime.rsplit(".", 1)[-1].split("-")[1:] if p.isdigit())
    for device in devices:
        if device["name"] == name:
            if best is None or version > best[0]:
                best = (version, device["udid"])
print(best[1] if best else "")
' "$1"
}

# A clean marketing status bar: 9:41, full signal, full battery.
dress_status_bar() {
  xcrun simctl status_bar "$1" override \
    --time "9:41" \
    --dataNetwork wifi --wifiMode active --wifiBars 3 \
    --cellularMode active --cellularBars 4 \
    --batteryState charged --batteryLevel 100 2>/dev/null \
    || warn "status bar override failed on $1 (screenshots still usable)"
}

# --- capture -----------------------------------------------------------------

mkdir -p "$OUT_DIR"
captured_total=0

for device_spec in "${DEVICES[@]}"; do
  IFS='|' read -r size_key device_name expected <<<"$device_spec"
  [[ -n "$ONLY_SIZE" && "$ONLY_SIZE" != "$size_key" && "$ONLY_SIZE" != "${size_key%%-*}" ]] && continue

  udid="$(udid_for "$device_name")"
  [[ -n "$udid" ]] || { warn "no simulator named '$device_name' — skipping $size_key"; continue; }

  log "$size_key — $device_name ($udid)"
  xcrun simctl boot "$udid" 2>/dev/null || true
  xcrun simctl bootstatus "$udid" -b >/dev/null 2>&1 || true
  dress_status_bar "$udid"

  for locale_spec in "${LOCALES[@]}"; do
    IFS='|' read -r lang locale <<<"$locale_spec"
    [[ -n "$ONLY_LOCALE" && "$ONLY_LOCALE" != "$lang" ]] && continue

    result="$WORK/$size_key-$lang.xcresult"
    staging="$WORK/$size_key-$lang-att"
    dest="$OUT_DIR/$size_key/$lang"
    rm -rf "$result" "$staging" "$dest"
    mkdir -p "$staging" "$dest"

    log "  capturing $lang …"
    # Clean slate each run: a stale Keychain session or saved-store list would
    # otherwise leak between locales.
    xcrun simctl uninstall "$udid" com.glutenfree.gf 2>/dev/null || true

    # Parallel testing is off on purpose — it runs the tests on a throwaway
    # clone device, and the status bar override above would not follow.
    # The locale is selected by picking the test method, not by environment:
    # variables set here live on the xcodebuild process and never reach the test
    # runner inside the simulator, so an env-driven locale silently no-ops.
    case "$lang" in
      ja) test_method=testCaptureJapanese ;;
      en) test_method=testCaptureEnglish ;;
      *)  warn "no capture method for locale '$lang' — skipping"; continue ;;
    esac

    set +e
    xcodebuild test \
      TEST_RUNNER_GF_API_BASE_URL="$API" \
      -project GlutenFree.xcodeproj \
      -scheme GlutenFree \
      -configuration Debug \
      -destination "platform=iOS Simulator,id=$udid" \
      -derivedDataPath "$DERIVED" \
      -only-testing:"GlutenFreeUITests/AppStoreShots/$test_method" \
      -resultBundlePath "$result" \
      -parallel-testing-enabled NO \
      CODE_SIGNING_ALLOWED=NO \
      >"$WORK/$size_key-$lang.log" 2>&1
    status=$?
    set -e
    [[ $status -eq 0 ]] || warn "xcodebuild exited $status — see $WORK/$size_key-$lang.log (exporting whatever landed)"

    xcrun xcresulttool export attachments --path "$result" --output-path "$staging" >/dev/null 2>&1 \
      || { warn "no attachments in $result"; continue; }

    # Rename exported UUIDs back to the attachment names the test assigned, and
    # drop everything XCUITest adds on its own (screen recordings, UI snapshots,
    # synthesized events) — only the deliberately named "NN-screen" shots.
    python3 - "$staging" "$dest" <<'PY'
import json, os, re, shutil, sys

staging, dest = sys.argv[1], sys.argv[2]
manifest = os.path.join(staging, "manifest.json")
if not os.path.exists(manifest):
    sys.exit("no manifest.json")

WANTED = re.compile(r"^\d{2}-[a-z0-9-]+$")

count = 0
with open(manifest) as handle:
    for entry in json.load(handle):
        for att in sorted(entry.get("attachments", []), key=lambda a: a.get("timestamp", 0)):
            src = os.path.join(staging, att["exportedFileName"])
            if not os.path.exists(src):
                continue
            # "01-explore_0_<uuid>.png" -> "01-explore.png"
            name = att.get("suggestedHumanReadableName") or att["exportedFileName"]
            stem = os.path.splitext(name)[0].split("_")[0]
            if not WANTED.match(stem):
                continue
            shutil.copy2(src, os.path.join(dest, stem + ".png"))
            count += 1
print(f"  kept {count} named shots")
PY

    shot_count=$(ls -1 "$dest"/*.png 2>/dev/null | wc -l | tr -d ' ')
    log "  → $shot_count shots in ${dest#$PROJECT_DIR/}"
    captured_total=$((captured_total + shot_count))

    # Verify pixel dimensions against what App Store Connect expects.
    for png in "$dest"/*.png; do
      [[ -e "$png" ]] || continue
      w=$(sips -g pixelWidth "$png" | awk '/pixelWidth/{print $2}')
      h=$(sips -g pixelHeight "$png" | awk '/pixelHeight/{print $2}')
      if [[ "${w}x${h}" != "$expected" ]]; then
        warn "$(basename "$png") is ${w}x${h}, expected $expected"
      fi
    done
  done

  xcrun simctl status_bar "$udid" clear 2>/dev/null || true
done

log "done — $captured_total screenshots under ${OUT_DIR#$PROJECT_DIR/}/"
