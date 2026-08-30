#!/bin/zsh

set -euo pipefail

project_root=${0:A:h:h}
allowlist_path="$project_root/config/public-release-files.txt"
typeset -A seen_entries

while IFS= read -r entry; do
  [[ -z "$entry" || "$entry" == \#* ]] && continue
  if [[ "$entry" == /* || "$entry" == ./* || "$entry" == *".."* || "$entry" == *//* ]]; then
    print -u2 -- "E_PUBLIC_ALLOWLIST: unsafe entry '$entry'"
    exit 1
  fi
  if [[ -n "${seen_entries[$entry]-}" ]]; then
    print -u2 -- "E_PUBLIC_ALLOWLIST: duplicate entry '$entry'"
    exit 1
  fi
  seen_entries[$entry]=1
  target="$project_root/$entry"
  if [[ "$entry" == */ ]]; then
    if [[ ! -d "$target" || -L "$target" ]]; then
      print -u2 -- "E_PUBLIC_ALLOWLIST: missing or symlinked directory '$entry'"
      exit 1
    fi
    find "$target" \( -type f -o -type l \) -print
  elif [[ -f "$target" && ! -L "$target" ]]; then
    print -r -- "$target"
  else
    print -u2 -- "E_PUBLIC_ALLOWLIST: missing or symlinked file '$entry'"
    exit 1
  fi
done < "$allowlist_path" \
  | sed "s#^$project_root/##" \
  | LC_ALL=C sort
