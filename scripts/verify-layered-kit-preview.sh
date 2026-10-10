#!/bin/bash
# Native visual specimen verification. Requires macOS/Xcode and XcodeGen.
set -euo pipefail
root=$(cd "$(dirname "$0")/.." && pwd)
app="$root/Examples/LayeredKitPreview"
destination=${LAYERED_KIT_DESTINATION:-all}
case "$destination" in all|iphone|ipad|macos) ;; *) echo 'Invalid layered-kit destination' >&2; exit 1;; esac
[[ $(uname -s) == Darwin ]] || { echo 'Native preview verification requires macOS/Xcode' >&2; exit 1; }
for tool in xcodegen xcodebuild xcrun python3; do command -v "$tool" >/dev/null; done
results=${LAYERED_KIT_RESULTS_DIR:-$(mktemp -d "${TMPDIR:-/tmp}/layered-kit-results.XXXXXX")}
mkdir -p "$results"
xcodebuild -version | tee "$results/toolchain.txt"
swift --version | tee -a "$results/toolchain.txt"
xcodegen generate --spec "$app/project.yml" --project "$app"
xcrun simctl list devices available --json > "$results/simulators.json"
python3 - "$results/simulators.json" "$destination" > "$results/selected-simulators.txt" <<'PY'
import json,re,sys
data=json.load(open(sys.argv[1]))['devices']
runtimes=sorted(data,key=lambda v:tuple(map(int,re.findall(r'\d+',v))),reverse=True)
for family in {'all':('iPhone','iPad'),'iphone':('iPhone',),'ipad':('iPad',),'macos':()}[sys.argv[2]]:
    device=next((d for r in runtimes if 'iOS' in r for d in data[r] if d.get('isAvailable') and d['name'].startswith(family)),None)
    if device is None: raise SystemExit('Missing installed '+family+' simulator')
    print(family,device['udid'])
PY
status=0
while read -r family identifier; do
  if ! xcodebuild test -project "$app/LayeredKitPreview.xcodeproj" -scheme LayeredKitPreview-iOS \
    -sdk iphonesimulator -destination "id=$identifier" -derivedDataPath "$results/DerivedData-$family" \
    -resultBundlePath "$results/$family.xcresult" CODE_SIGNING_ALLOWED=YES CODE_SIGN_STYLE=Manual CODE_SIGN_IDENTITY=-; then status=1; fi
done < "$results/selected-simulators.txt"
if [[ "$destination" == all || "$destination" == macos ]]; then
  if ! xcodebuild test -project "$app/LayeredKitPreview.xcodeproj" -scheme LayeredKitPreview-macOS \
    -destination 'platform=macOS' -derivedDataPath "$results/DerivedData-macOS" \
    -resultBundlePath "$results/macOS.xcresult" CODE_SIGNING_ALLOWED=NO; then status=1; fi
fi
for bundle in "$results"/*.xcresult; do
  [[ -d "$bundle" ]] || continue
  name=$(basename "$bundle" .xcresult)
  mkdir -p "$results/screenshots-$name"
  if ! xcrun xcresulttool export attachments --path "$bundle" --output-path "$results/screenshots-$name"; then
    echo "Attachment export failed for $name; original xcresult retained." >&2
    status=1
  fi
done
[[ $status -eq 0 ]] || { echo 'Native layered-kit preview failed; inspect retained evidence.' >&2; exit "$status"; }
echo 'Native specimen tests passed. Exact393 source-state visual parity remains separately tracked.'
