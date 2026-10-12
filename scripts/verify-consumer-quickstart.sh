#!/bin/zsh

set -euo pipefail

project_root=${0:A:h:h}
temporary_source=$(mktemp "${TMPDIR:-/tmp}/design-os-apple-quickstart.XXXXXX.swift")
trap 'rm -f "$temporary_source"' EXIT

python3 "$project_root/scripts/verify-quickstart-parity.py" --output "$temporary_source"

cd "$project_root"
swift build --target DesignOSApple
modules_directory="$(swift build --show-bin-path)/Modules"
xcrun swiftc -typecheck -parse-as-library -I "$modules_directory" "$temporary_source"

print -- "Consumer quickstart type-check passed."
