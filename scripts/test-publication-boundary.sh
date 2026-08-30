#!/bin/zsh

set -euo pipefail

project_root=${0:A:h:h}
verifier="$project_root/scripts/verify-publication-boundary.sh"
fixture_dir="$project_root/docs/.publication-boundary-fixture-$$"
file_list=$(mktemp "${TMPDIR:-/tmp}/design-os-apple-boundary-test.XXXXXX")

cleanup() {
  if [[ "$fixture_dir" == "$project_root/docs/.publication-boundary-fixture-"* \
    && -d "$fixture_dir" ]]; then
    find "$fixture_dir" -depth ! -path "$fixture_dir" -delete
    rmdir "$fixture_dir"
  fi
  rm -f "$file_list"
}
trap cleanup EXIT

mkdir -p "$fixture_dir"

expect_rejected() {
  local label=$1 path=$2
  print -r -- "$path" > "$file_list"
  if "$verifier" --file-list "$file_list" >/dev/null 2>&1; then
    print -u2 -- "E_BOUNDARY_TEST: accepted hostile fixture '$label'"
    exit 1
  fi
}

print -r -- "README.md" > "$file_list"
"$verifier" --file-list "$file_list" >/dev/null
if "$verifier" --file-list-exact "$file_list" >/dev/null 2>&1; then
  print -u2 -- "E_BOUNDARY_TEST: exact mode accepted an incomplete candidate"
  exit 1
fi

expect_rejected "maintainer configuration" "AGENTS.md"
expect_rejected "private evidence validator" "Sources/DesignOSDogfoodEvidenceValidator/main.swift"
expect_rejected "parent traversal" "../README.md"

personal_fixture=${fixture_dir#$project_root/}/personal-path.txt
print -r -- "/""Users""/""private-user""/workspace" > "$project_root/$personal_fixture"
expect_rejected "personal home path" "$personal_fixture"

credential_fixture=${fixture_dir#$project_root/}/credential.txt
print -r -- "gh""p_""$(printf 'a%.0s' {1..24})" > "$project_root/$credential_fixture"
expect_rejected "credential" "$credential_fixture"

symlink_fixture=${fixture_dir#$project_root/}/linked-readme.txt
ln -s "$project_root/README.md" "$project_root/$symlink_fixture"
expect_rejected "symlink" "$symlink_fixture"

large_fixture=${fixture_dir#$project_root/}/oversized.txt
dd if=/dev/zero of="$project_root/$large_fixture" bs=1048577 count=1 2>/dev/null
expect_rejected "oversized file" "$large_fixture"

print -- "Publication boundary hostile probes passed."
