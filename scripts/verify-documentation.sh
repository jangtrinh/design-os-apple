#!/bin/zsh

set -euo pipefail

project_root=${0:A:h:h}
temporary_root=$(mktemp -d "${TMPDIR:-/tmp}/design-os-apple-docc.XXXXXX")

cleanup() {
  if [[ "$temporary_root" == "${TMPDIR:-/tmp}/design-os-apple-docc."* && -d "$temporary_root" ]]; then
    find "$temporary_root" -depth ! -path "$temporary_root" -delete
    rmdir "$temporary_root"
  fi
}
trap cleanup EXIT

link_failures=0
while IFS=: read -r source_path line_number matched_link; do
  target=${matched_link#']('}
  target=${target%')'}
  target=${target#<}
  target=${target%>}
  case "$target" in
    ""|\#*|http://*|https://*|mailto:*) continue ;;
  esac
  target=${target%%\#*}
  resolved_path="$project_root/${source_path:h}/$target"
  if [[ ! -e "${resolved_path:A}" ]]; then
    print -u2 -- "E_DOCUMENTATION_LINK: $source_path:$line_number -> $target"
    link_failures=$((link_failures + 1))
  fi
done < <(
  cd "$project_root"
  rg --with-filename --line-number --only-matching '\]\([^)]+\)' \
    README.md CONTRIBUTING.md CODE_OF_CONDUCT.md SECURITY.md SUPPORT.md CHANGELOG.md \
    RELEASING.md docs Sources/DesignOSApple/DesignOSApple.docc
)

if (( link_failures > 0 )); then
  print -u2 -- "Documentation link verification failed: $link_failures finding(s)."
  exit 1
fi

cd "$project_root"
xcodebuild docbuild \
  -scheme DesignOSApple \
  -destination 'generic/platform=macOS' \
  -derivedDataPath "$temporary_root/DerivedData" \
  CODE_SIGNING_ALLOWED=NO \
  -quiet

print -- "Markdown links and DesignOSApple DocC build passed."
