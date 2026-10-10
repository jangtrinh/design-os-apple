#!/bin/bash
# Native dogfood verification. Requires macOS, Swift 6.2+, XcodeGen and simulators.
set -euo pipefail

root=$(cd "$(dirname "$0")/.." && pwd)
app="$root/Examples/CalorieCam"
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
python3 - "$results/simulators.json" > "$results/selected-simulators.txt" <<'PY'
import json, re, sys
data = json.load(open(sys.argv[1]))["devices"]
runtimes = sorted(data, key=lambda value: tuple(map(int, re.findall(r"\d+", value))), reverse=True)
for family in ("iPhone", "iPad"):
    chosen = next((device for runtime in runtimes if "iOS" in runtime
                   for device in data[runtime]
                   if device.get("isAvailable") and device["name"].startswith(family)), None)
    if chosen is None:
        raise SystemExit(f"E_CALORIECAM_SIMULATOR: no available {family}")
    print(f"{family} {chosen['udid']}")
PY

while read -r family identifier; do
  xcodebuild test \
    -project "$app/CalorieCam.xcodeproj" \
    -scheme CalorieCam-iOS \
    -destination "id=$identifier" \
    -derivedDataPath "$results/DerivedData-$family" \
    -resultBundlePath "$results/$family.xcresult" \
    CODE_SIGNING_ALLOWED=NO
done < "$results/selected-simulators.txt"

xcodebuild test \
  -project "$app/CalorieCam.xcodeproj" \
  -scheme CalorieCam-macOS \
  -destination 'platform=macOS' \
  -derivedDataPath "$results/DerivedData-macOS" \
  -resultBundlePath "$results/macOS.xcresult" \
  CODE_SIGNING_ALLOWED=NO

echo "CalorieCam native core and iPhone/iPad/macOS UI tests passed."
echo "Camera hardware, photo recognition, visual acceptance and Duo posture remain separate checks."
