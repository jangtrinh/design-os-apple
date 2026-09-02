#!/bin/zsh

set -euo pipefail

project_root=${0:A:h:h}
if [[ "${DESIGN_OS_APPLE_GALLERY_LOCKED:-0}" != 1 ]]; then
  command -v lockf >/dev/null || {
    print -u2 -- "E_GALLERY_TOOL: missing 'lockf'"
    exit 1
  }
  lock_file="${TMPDIR:-/tmp}/design-os-apple-gallery.lock"
  exec lockf -k -t 300 "$lock_file" \
    env DESIGN_OS_APPLE_GALLERY_LOCKED=1 "$0" "$@"
fi

gallery_root="$project_root/Examples/DesignOSAppleGallery"
temporary_root=$(mktemp -d "${TMPDIR:-/tmp}/design-os-apple-gallery.XXXXXX")
temporary_project_root="$temporary_root/design-os-apple/Examples/DesignOSAppleGallery"

cleanup() {
  if [[ "$temporary_root" == "${TMPDIR:-/tmp}/design-os-apple-gallery."* && -d "$temporary_root" ]]; then
    find "$temporary_root" -depth ! -path "$temporary_root" -delete
    rmdir "$temporary_root"
  fi
}
trap cleanup EXIT

for command in xcodegen xcodebuild ditto; do
  command -v "$command" >/dev/null || {
    print -u2 -- "E_GALLERY_TOOL: missing '$command'"
    exit 1
  }
done

simulator_id_for() {
  local family=$1 line
  line=$(xcrun simctl list devices available | grep -m1 -E "^[[:space:]]+$family ") || {
    print -u2 -- "E_GALLERY_SIMULATOR: no available $family simulator"
    exit 1
  }
  if [[ "$line" =~ '\(([0-9A-F-]{36})\)' ]]; then
    print -r -- "$match[1]"
  else
    print -u2 -- "E_GALLERY_SIMULATOR: could not resolve $family simulator ID"
    exit 1
  fi
}

mkdir -p "${temporary_project_root:h}"
ditto --noqtn --norsrc "$gallery_root" "$temporary_project_root"
xcodegen generate --quiet \
  --spec "$temporary_project_root/project.yml" \
  --project "$temporary_project_root"

generated_project="$temporary_project_root/DesignOSAppleGallery.xcodeproj"
for relative_file in \
  project.pbxproj \
  project.xcworkspace/contents.xcworkspacedata \
  xcshareddata/xcschemes/DesignOSAppleGallery-iOS.xcscheme \
  xcshareddata/xcschemes/DesignOSAppleGallery-macOS.xcscheme \
  xcshareddata/xcschemes/TocChienDogfoodPilot-iOS.xcscheme \
  xcshareddata/xcschemes/TocChienDogfoodPilot-macOS.xcscheme; do
  if ! cmp -s \
    "$gallery_root/DesignOSAppleGallery.xcodeproj/$relative_file" \
    "$generated_project/$relative_file"; then
    print -u2 -- "E_GALLERY_PROJECT_DRIFT: $relative_file"
    exit 1
  fi
done

cd "$project_root"
xcodebuild build \
  -project Examples/DesignOSAppleGallery/DesignOSAppleGallery.xcodeproj \
  -scheme DesignOSAppleGallery-iOS \
  -destination 'generic/platform=iOS' \
  -derivedDataPath "$temporary_root/DerivedData-iOS" \
  CODE_SIGNING_ALLOWED=NO \
  -quiet

iphone_id=$(simulator_id_for iPhone)
ipad_id=$(simulator_id_for iPad)
ios_test_selection=(
  -only-testing:DesignOSAppleGalleryUITests/DesignOSAppleGalleryUITests/testDefaultLaunchShowsCatalogWithoutDebugText
  -only-testing:DesignOSAppleGalleryUITests/DesignOSAppleGalleryLocalDemoUITests
)
for simulator_id in "$iphone_id" "$ipad_id"; do
  xcodebuild test \
    -project Examples/DesignOSAppleGallery/DesignOSAppleGallery.xcodeproj \
    -scheme DesignOSAppleGallery-iOS \
    -destination "id=$simulator_id" \
    -derivedDataPath "$temporary_root/DerivedData-$simulator_id" \
    "${ios_test_selection[@]}" \
    CODE_SIGNING_ALLOWED=NO \
    -quiet
done

macos_test_selection=(
  -only-testing:DesignOSAppleGalleryRendererTests
  -only-testing:DesignOSAppleGalleryMacOSUITests/DesignOSAppleGalleryLocalDemoMacOSUITests
)
xcodebuild test \
  -project Examples/DesignOSAppleGallery/DesignOSAppleGallery.xcodeproj \
  -scheme DesignOSAppleGallery-macOS \
  -destination 'platform=macOS' \
  -derivedDataPath "$temporary_root/DerivedData" \
  "${macos_test_selection[@]}" \
  CODE_SIGNING_ALLOWED=YES \
  CODE_SIGN_STYLE=Manual \
  CODE_SIGN_IDENTITY=- \
  -quiet

print -- "Gallery project drift, iOS/iPadOS local-demo behavior, and macOS renderer/local-demo checks passed."
