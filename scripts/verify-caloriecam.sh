#!/bin/bash
# Native dogfood verification. Requires macOS, Swift 6.2+, XcodeGen and simulators.
set -euo pipefail

root=$(cd "$(dirname "$0")/.." && pwd)
app="$root/Examples/CalorieCam"
destination=${CALORIECAM_DESTINATION:-all}
case "$destination" in
  all|iphone|ipad|macos) ;;
  *) echo "E_CALORIECAM_DESTINATION: expected all, iphone, ipad or macos" >&2; exit 1 ;;
esac
for tool in swift xcodegen xcodebuild xcrun python3; do
  command -v "$tool" >/dev/null || { echo "E_CALORIECAM_TOOL: missing $tool" >&2; exit 1; }
done
if [[ $(uname -s) != Darwin ]]; then
  echo "E_CALORIECAM_PLATFORM: native app verification requires macOS/Xcode" >&2
  exit 1
fi

results=${CALORIECAM_RESULTS_DIR:-$(mktemp -d "${TMPDIR:-/tmp}/caloriecam-results.XXXXXX")}
mkdir -p "$results"
echo "CalorieCam results: $results"
xcodebuild -version | tee "$results/toolchain.txt"
swift --version | tee -a "$results/toolchain.txt"

swift test --package-path "$app/Core" --scratch-path "$results/CoreBuild"
xcodegen generate --spec "$app/project.yml" --project "$app"

# Use actual installed simulator identifiers. Missing devices are errors, not skips.
xcrun simctl list devices available --json > "$results/simulators.json"
python3 - "$results/simulators.json" "$destination" > "$results/selected-simulators.txt" <<'PY'
import json, re, sys
data = json.load(open(sys.argv[1]))["devices"]
runtimes = sorted(data, key=lambda value: tuple(map(int, re.findall(r"\d+", value))), reverse=True)
families = {"all": ("iPhone", "iPad"), "iphone": ("iPhone",), "ipad": ("iPad",), "macos": ()}[sys.argv[2]]
for family in families:
    chosen = next((device for runtime in runtimes if "iOS" in runtime
                   for device in data[runtime]
                   if device.get("isAvailable") and device["name"].startswith(family)), None)
    if chosen is None:
        raise SystemExit(f"E_CALORIECAM_SIMULATOR: no available {family}")
    print(f"{family} {chosen['udid']}")
PY

status=0
while read -r family identifier; do
  if xcodebuild test \
    -project "$app/CalorieCam.xcodeproj" \
    -scheme CalorieCam-iOS \
    -destination "id=$identifier" \
    -derivedDataPath "$results/DerivedData-$family" \
    -resultBundlePath "$results/$family.xcresult" \
    CODE_SIGNING_ALLOWED=NO; then
    echo "$family UI tests passed."
  else
    status=1
  fi
done < "$results/selected-simulators.txt"

if [[ "$destination" == all || "$destination" == macos ]]; then
  if xcodebuild test \
    -project "$app/CalorieCam.xcodeproj" \
    -scheme CalorieCam-macOS \
    -destination 'platform=macOS' \
    -derivedDataPath "$results/DerivedData-macOS" \
    -resultBundlePath "$results/macOS.xcresult" \
    CODE_SIGNING_ALLOWED=NO; then
    echo "macOS UI tests passed."
  else
    status=1
  fi

fi

# Export actual XCTest attachments for review without requiring Xcode on the viewer.
for bundle in "$results"/*.xcresult; do
  [[ -d "$bundle" ]] || continue
  name=$(basename "$bundle" .xcresult)
  mkdir -p "$results/screenshots-$name"
  if ! xcrun xcresulttool export attachments --path "$bundle" --output-path "$results/screenshots-$name"; then
    echo "Attachment export unavailable for $name; retain the original xcresult." >&2
  fi
done
if [[ $status -ne 0 ]]; then
  echo "E_CALORIECAM_TEST: one or more native destinations failed; inspect results." >&2
  exit "$status"
fi

echo "CalorieCam core and requested native destination ($destination) passed."
echo "Camera hardware, photo recognition, visual acceptance and Duo posture remain separate checks."
