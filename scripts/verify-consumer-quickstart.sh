#!/bin/zsh

set -euo pipefail

project_root=${0:A:h:h}
source_document="$project_root/docs/getting-started.md"
temporary_source=$(mktemp "${TMPDIR:-/tmp}/design-os-apple-quickstart.XXXXXX.swift")
trap 'rm -f "$temporary_source"' EXIT

start_count=$(rg -c '<!-- verify-swift-start -->' "$source_document")
end_count=$(rg -c '<!-- verify-swift-end -->' "$source_document")
if [[ "$start_count" != 1 || "$end_count" != 1 ]]; then
  print -u2 -- "E_QUICKSTART_MARKERS: expected one bounded Swift example"
  exit 1
fi

awk '
  /<!-- verify-swift-start -->/ { capture = 1; next }
  /<!-- verify-swift-end -->/ { capture = 0; next }
  capture && !/^```/ { print }
' "$source_document" > "$temporary_source"

cd "$project_root"
swift build --target DesignOSApple
modules_directory="$(swift build --show-bin-path)/Modules"
xcrun swiftc -typecheck -parse-as-library -I "$modules_directory" "$temporary_source"

print -- "Consumer quickstart type-check passed."
