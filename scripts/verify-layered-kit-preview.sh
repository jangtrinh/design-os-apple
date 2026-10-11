#!/bin/bash
# Native visual specimen verification. Requires macOS/Xcode and XcodeGen.
set -euo pipefail
root=$(cd "$(dirname "$0")/.." && pwd)
app="$root/Examples/LayeredKitPreview"
destination=${LAYERED_KIT_DESTINATION:-all}
# Preserve the original screen-family scope by default. New suites are opt-in.
suite=${LAYERED_KIT_TEST_SUITE:-original}
shard=${LAYERED_KIT_COMPONENT_SHARD:-}
case "$suite" in
  original|fields)
    [[ -z "$shard" ]] || { echo 'Component shard requires the components suite' >&2; exit 1; }
    suite_label=$suite
    ;;
  components)
    case "$shard" in semantic|composite|shell|native) ;; *) echo 'Components suite requires shard: semantic, composite, shell or native' >&2; exit 1;; esac
    suite_label="components-$shard"
    ;;
  *) echo 'Invalid layered-kit suite: use original, fields or components' >&2; exit 1;;
esac

# Explicit allowlists prevent new XCTest classes silently expanding existing jobs.
select_tests() {
  local target=$1
  test_args=()
  local method
  case "$suite" in
    original) test_args+=("-only-testing:$target/LayeredKitPreviewUITests") ;;
    fields) test_args+=("-only-testing:$target/TextFieldSpecimenUITests") ;;
    components)
      local methods=()
      case "$shard" in
        semantic) methods=(testSemanticMediaComponents testSemanticContentComponents testSemanticActionAndFieldComponents testResolvedFoundationSamples testExplicitAlternateStates testAccessibleReflowSamples) ;;
        composite) methods=(testCompositeIdentityAndMediaComponents testCompositeInputAndSelectionComponents testCompositeMessageAndRecordComponents testCompositeNativeRecipes) ;;
        shell) methods=(testListAndScrollShellComponents testTaskAndConversationShellComponents testNavigationAndHostShellComponents) ;;
        native) methods=(testNativeRecipeSamples1 testNativeRecipeSamples2 testNativeRecipeSamples3 testNativeSheetPresentation) ;;
      esac
      for method in "${methods[@]}"; do test_args+=("-only-testing:$target/ComponentInventoryUITests/$method"); done
      ;;
  esac
}
case "$destination" in all|iphone|ipad|macos) ;; *) echo 'Invalid layered-kit destination' >&2; exit 1;; esac
[[ $(uname -s) == Darwin ]] || { echo 'Native preview verification requires macOS/Xcode' >&2; exit 1; }
for tool in xcodegen xcodebuild xcrun python3; do command -v "$tool" >/dev/null; done
results=${LAYERED_KIT_RESULTS_DIR:-$(mktemp -d "${TMPDIR:-/tmp}/layered-kit-results.XXXXXX")}
mkdir -p "$results"
source_revision=$(git -C "$root" rev-parse HEAD)
export LAYERED_KIT_SOURCE_REVISION="$source_revision"
# Xcode forwards TEST_RUNNER_-prefixed variables to the XCTest runner without the prefix.
export TEST_RUNNER_LAYERED_KIT_SOURCE_REVISION="$source_revision"
printf '%s\n' "$source_revision" > "$results/source-revision.txt"
printf 'suite=%s\nshard=%s\ndestination=%s\n' "$suite" "$shard" "$destination" > "$results/test-selection.txt"
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
  select_tests LayeredKitPreview-iOS-UITests
  printf '%s\n' "${test_args[@]}" >> "$results/test-selection.txt"
  if ! xcodebuild test -project "$app/LayeredKitPreview.xcodeproj" -scheme LayeredKitPreview-iOS \
    -sdk iphonesimulator -destination "id=$identifier" -derivedDataPath "$results/DerivedData-$family" \
    -resultBundlePath "$results/$family-$suite_label.xcresult" "${test_args[@]}" CODE_SIGNING_ALLOWED=YES CODE_SIGN_STYLE=Manual CODE_SIGN_IDENTITY=-; then status=1; fi
done < "$results/selected-simulators.txt"
if [[ "$destination" == all || "$destination" == macos ]]; then
  select_tests LayeredKitPreview-macOS-UITests
  printf '%s\n' "${test_args[@]}" >> "$results/test-selection.txt"
  if ! xcodebuild test -project "$app/LayeredKitPreview.xcodeproj" -scheme LayeredKitPreview-macOS \
    -destination 'platform=macOS' -derivedDataPath "$results/DerivedData-macOS" \
    -resultBundlePath "$results/macOS-$suite_label.xcresult" "${test_args[@]}" CODE_SIGNING_ALLOWED=NO; then status=1; fi
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
echo "Native specimen suite $suite_label passed. Exact393 source-state visual parity remains separately tracked."
