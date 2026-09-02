#!/bin/zsh

set -euo pipefail

project_root=${0:A:h:h}
mode=${1:---candidate}
require_exact_candidate=0
scan_root=$project_root
staged_root=""
expected_list=""
temporary_directory=${TMPDIR:-/tmp}
temporary_directory=${temporary_directory:A}

temporary_list=$(mktemp "$temporary_directory/design-os-apple-public-files.XXXXXX")
cleanup() {
  rm -f "$temporary_list"
  [[ -z "$expected_list" ]] || rm -f "$expected_list"
  if [[ -n "$staged_root" && "$staged_root" == "$temporary_directory/design-os-apple-staged."* \
    && -d "$staged_root" ]]; then
    find "$staged_root" -depth -delete
  fi
}
trap cleanup EXIT

case "$mode" in
  --candidate)
    "$project_root/scripts/list-public-release-files.sh" > "$temporary_list"
    ;;
  --tracked)
    git -C "$project_root" ls-files | LC_ALL=C sort > "$temporary_list"
    require_exact_candidate=1
    ;;
  --staged)
    git -C "$project_root" diff --cached --name-only --diff-filter=ACMR \
      | LC_ALL=C sort > "$temporary_list"
    staged_root=$(mktemp -d "$temporary_directory/design-os-apple-staged.XXXXXX")
    git -C "$project_root" checkout-index --all --prefix="$staged_root/"
    scan_root=$staged_root
    require_exact_candidate=1
    ;;
  --file-list)
    source_list=${2:?"usage: verify-publication-boundary.sh --file-list <path>"}
    cp "$source_list" "$temporary_list"
    ;;
  --file-list-exact)
    source_list=${2:?"usage: verify-publication-boundary.sh --file-list-exact <path>"}
    cp "$source_list" "$temporary_list"
    require_exact_candidate=1
    ;;
  *)
    print -u2 -- "Unknown mode: $mode"
    exit 2
    ;;
esac

if (( require_exact_candidate )); then
  expected_list=$(mktemp "$temporary_directory/design-os-apple-expected-public-files.XXXXXX")
  "$scan_root/scripts/list-public-release-files.sh" > "$expected_list"
  if ! cmp -s "$expected_list" "$temporary_list"; then
    print -u2 -- "E_PUBLIC_BOUNDARY: supplied file set differs from the exact candidate"
    diff -u "$expected_list" "$temporary_list" >&2 || true
    exit 1
  fi
fi

allowed_file="$scan_root/config/public-release-files.txt"
failures=0
checked=0
typeset -A seen_paths

is_allowed() {
  local candidate=$1 entry
  while IFS= read -r entry; do
    [[ -z "$entry" || "$entry" == \#* ]] && continue
    if [[ "$entry" == */ ]]; then
      [[ "$candidate" == "$entry"* ]] && return 0
    elif [[ "$candidate" == "$entry" ]]; then
      return 0
    fi
  done < "$allowed_file"
  return 1
}

is_approved_catalog_thumbnail() {
  local candidate=$1 parent leaf stem
  [[ "$candidate" == \
    Examples/DesignOSAppleGallery/Resources/CatalogThumbnails.xcassets/catalog-*.imageset/catalog-*.png \
  ]] || return 1
  parent=${candidate%/*}
  parent=${parent##*/}
  leaf=${candidate##*/}
  stem=${parent%.imageset}
  [[ "$parent" == catalog-*.imageset && "$leaf" == "$stem.png" ]]
}
is_gallery_generated_art() {
  case "$1" in
    Examples/DesignOSAppleGallery/Resources/CatalogThumbnails.xcassets/demo-thoughtful-chat-thumbnail.imageset/demo-thoughtful-chat-thumbnail.png|\
      Examples/DesignOSAppleGallery/Resources/CatalogThumbnails.xcassets/demo-visual-assistant-thumbnail.imageset/demo-visual-assistant-thumbnail.png|\
      Examples/DesignOSAppleGallery/Resources/CatalogThumbnails.xcassets/demo-flight-tracker-thumbnail.imageset/demo-flight-tracker-thumbnail.png|\
      Examples/DesignOSAppleGallery/Resources/CatalogThumbnails.xcassets/demo-city-ride-thumbnail.imageset/demo-city-ride-thumbnail.png|\
      Examples/DesignOSAppleGallery/Resources/CatalogThumbnails.xcassets/demo-streaming-library-thumbnail.imageset/demo-streaming-library-thumbnail.png|\
      Examples/DesignOSAppleGallery/Resources/CatalogThumbnails.xcassets/demo-song-finder-thumbnail.imageset/demo-song-finder-thumbnail.png|\
      Examples/DesignOSAppleGallery/Resources/LocalDemoMedia.xcassets/visual-assistant-answer-art.imageset/visual-assistant-answer-art.png|\
      Examples/DesignOSAppleGallery/Resources/LocalDemoMedia.xcassets/streaming-library-poster-atlas.imageset/streaming-library-poster-atlas.png|\
      Examples/DesignOSAppleGallery/Resources/LocalDemoMedia.xcassets/song-finder-afterglow-cover.imageset/song-finder-afterglow-cover.png|\
      Examples/DesignOSAppleGallery/Resources/LocalDemoMedia.xcassets/city-ride-arrival-essentials.imageset/city-ride-arrival-essentials.png)
      return 0
      ;;
  esac
  return 1
}
report() {
  print -u2 -- "E_PUBLIC_BOUNDARY: $1"
  failures=$((failures + 1))
}
gallery_generated_art_admitted=0
if grep -Eq '^Examples/DesignOSAppleGallery/(Generated/local-demo-image-provenance\.v1\.json|Resources/(CatalogThumbnails|LocalDemoMedia)\.xcassets/(demo-(thoughtful-chat|visual-assistant|flight-tracker|city-ride|streaming-library|song-finder)-thumbnail|visual-assistant-answer-art|streaming-library-poster-atlas|song-finder-afterglow-cover|city-ride-arrival-essentials)\.imageset/[^/]+\.png)$' "$temporary_list"; then
  if node "$scan_root/scripts/verify-local-demo-image-provenance.mjs" --root "$scan_root"; then
    gallery_generated_art_admitted=1
  else
    report "gallery-generated-art provenance admission failed"
  fi
fi

while IFS= read -r relative_path; do
  [[ -z "$relative_path" ]] && continue
  checked=$((checked + 1))

  if [[ -n "${seen_paths[$relative_path]-}" ]]; then
    report "duplicate path '$relative_path'"
    continue
  fi
  seen_paths[$relative_path]=1

  if [[ "$relative_path" == /* || "$relative_path" == ./* || "$relative_path" == ../* \
    || "$relative_path" == */../* || "$relative_path" == */.. || "$relative_path" == *//* \
    || "$relative_path" == *$'\n'* || "$relative_path" == *$'\r'* ]]; then
    report "unsafe path '$relative_path'"
    continue
  fi
  is_allowed "$relative_path" || report "unclassified path '$relative_path'"

  case "$relative_path" in
    plans/*|.brv/*|.agentkit/*|.exit|.project-agent.md|AGENTS.md|AGENTS.*|CLAUDE.md|\
      design-os-model.sh|design/changes/*|design/figma-*|design/heartbeat.json|\
      */.DS_Store|*/xcuserdata/*|*.xcuserstate|*.env|*.env.*|*.p12|*.mobileprovision)
      report "forbidden local evidence '$relative_path'"
      continue
      ;;
  esac

  absolute_path="$scan_root/$relative_path"
  [[ -f "$absolute_path" && ! -L "$absolute_path" ]] || {
    report "missing, nonregular, or symlinked file '$relative_path'"
    continue
  }
  expected_path="$scan_root/$relative_path"
  if [[ "${absolute_path:A}" != "$expected_path" ]]; then
    report "path resolves through a symlink '$relative_path'"
    continue
  fi

  size=$(stat -f %z "$absolute_path")
  if (( size > 1048576 )); then
    if ! (( gallery_generated_art_admitted )) || ! is_gallery_generated_art "$relative_path"; then
      report "file exceeds 1 MiB '$relative_path'"
    fi
  fi

  case "$relative_path" in
    *.png|*.jpg|*.jpeg|*.gif|*.pdf|*.fig|*.sketch|*.zip|*.dmg|*.pkg|*.bin)
      is_approved_catalog_thumbnail "$relative_path" \
        || { (( gallery_generated_art_admitted )) && is_gallery_generated_art "$relative_path"; } \
        || report "unapproved binary or design asset '$relative_path'"
      ;;
  esac

  mime_type=$(file -b --mime-type "$absolute_path")
  case "$mime_type" in
    text/*|application/json|application/xml) ;;
    image/png)
      is_approved_catalog_thumbnail "$relative_path" \
        || { (( gallery_generated_art_admitted )) && is_gallery_generated_art "$relative_path"; } \
        || report "unclassified non-text content '$relative_path' ($mime_type)"
      ;;
    *) report "unclassified non-text content '$relative_path' ($mime_type)" ;;
  esac

  personal_path_pattern='/(Users|home)/[^/[:space:]]+/'
  credential_pattern='gh[pousr]_[A-Za-z0-9]{20,}|github_pat_[A-Za-z0-9_]{20,}|sk-[A-Za-z0-9]{20,}|AKIA[A-Z0-9]{16}|-----BEGIN (RSA |EC |OPENSSH )?PRIVATE KEY-----'
  if LC_ALL=C grep -nE "$personal_path_pattern|$credential_pattern" "$absolute_path" >/dev/null; then
    report "personal path or credential pattern '$relative_path'"
  fi
done < "$temporary_list"

if (( checked == 0 )); then
  report "candidate set is empty"
fi

if (( failures > 0 )); then
  print -u2 -- "Publication boundary failed: $failures finding(s) across $checked file(s)."
  exit 1
fi

print -- "Publication boundary passed: $checked classified file(s)."
