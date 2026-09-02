#!/bin/zsh
set -euo pipefail

project_root=${0:A:h:h}
verifier="$project_root/scripts/verify-publication-boundary.sh"
generated_art_verifier="$project_root/scripts/verify-local-demo-image-provenance.mjs"
temporary_root=${TMPDIR:-/tmp}
temporary_root=${temporary_root:A}
file_list=$(mktemp "$temporary_root/design-os-apple-boundary-test.XXXXXX")
generated_art_fixtures=$(mktemp -d "$temporary_root/design-os-apple-generated-art-test.XXXXXX")
generated_art_fixtures=${generated_art_fixtures:A}
generated_owner_token=${generated_art_fixtures:t}
owner_marker=".publication-boundary-owner"
print -r -- "$generated_owner_token" > "$generated_art_fixtures/$owner_marker"
fixture_dir="" fixture_owner_token="" asset_fixture_dir="" asset_owner_token=""

cleanup_owned_directory() {
  local directory=$1 token=$2 marker
  marker="$directory/$owner_marker"
  if [[ -n "$directory" && -d "$directory" && ! -L "$directory" && -f "$marker" \
    && "$(<"$marker")" == "$token" ]]; then
    find "$directory" -depth -delete
  fi
}
cleanup() {
  cleanup_owned_directory "$asset_fixture_dir" "$asset_owner_token"
  cleanup_owned_directory "$fixture_dir" "$fixture_owner_token"
  cleanup_owned_directory "$generated_art_fixtures" "$generated_owner_token"
  [[ ! -f "$file_list" ]] || find "$file_list" -maxdepth 0 -type f -delete
}
trap cleanup EXIT

expect_generated_accepted() {
  local label=$1 case_root=$2 output
  if ! output=$(node "$generated_art_verifier" --root "$case_root" 2>&1); then
    print -u2 -- "E_BOUNDARY_TEST: rejected pristine generated art fixture '$label': $output"
    exit 1
  fi
}
expect_generated_rejected() {
  local label=$1 case_root=$2 expected_reason=$3 output
  if output=$(node "$generated_art_verifier" --root "$case_root" 2>&1); then
    print -u2 -- "E_BOUNDARY_TEST: accepted hostile generated art fixture '$label'"
    exit 1
  fi
  if [[ "$output" != *"$expected_reason"* ]]; then
    print -u2 -- "E_BOUNDARY_TEST: hostile fixture '$label' rejected for wrong reason"
    print -u2 -- "Expected: $expected_reason"
    print -u2 -- "Actual: $output"
    exit 1
  fi
}
expect_generated_accepted "repository baseline" "$project_root"
generated_base="$generated_art_fixtures/base"
mkdir -p "$generated_base/Examples/DesignOSAppleGallery/Generated" \
  "$generated_base/Examples/DesignOSAppleGallery/Resources/CatalogThumbnails.xcassets" \
  "$generated_base/Examples/DesignOSAppleGallery/Resources/LocalDemoMedia.xcassets" \
  "$generated_base/Sources/DesignOSApple"
cp "$project_root/Examples/DesignOSAppleGallery/Generated/local-demo-image-provenance.v1.json" \
  "$generated_base/Examples/DesignOSAppleGallery/Generated/"
cp "$project_root/Examples/DesignOSAppleGallery/project.yml" "$generated_base/Examples/DesignOSAppleGallery/"
cp "$project_root/Package.swift" "$generated_base/"
for image_set in demo-thoughtful-chat-thumbnail demo-visual-assistant-thumbnail \
  demo-flight-tracker-thumbnail demo-city-ride-thumbnail \
  demo-streaming-library-thumbnail demo-song-finder-thumbnail; do
  cp -R "$project_root/Examples/DesignOSAppleGallery/Resources/CatalogThumbnails.xcassets/$image_set.imageset" \
    "$generated_base/Examples/DesignOSAppleGallery/Resources/CatalogThumbnails.xcassets/"
done
for image_set in visual-assistant-answer-art streaming-library-poster-atlas song-finder-afterglow-cover \
  city-ride-arrival-essentials; do
  cp -R "$project_root/Examples/DesignOSAppleGallery/Resources/LocalDemoMedia.xcassets/$image_set.imageset" \
    "$generated_base/Examples/DesignOSAppleGallery/Resources/LocalDemoMedia.xcassets/"
done
expect_generated_accepted "canonicalized copied baseline" "$generated_base"

generated_case() {
  local case_root="$generated_art_fixtures/$1"
  mkdir -p "$case_root"
  cp -R "$generated_base/." "$case_root"
  print -r -- "$case_root"
}
manifest_mutation() {
  local manifest="$1/Examples/DesignOSAppleGallery/Generated/local-demo-image-provenance.v1.json"
  node -e "const fs=require('fs');const p=process.argv[1];const value=JSON.parse(fs.readFileSync(p));$2;fs.writeFileSync(p,JSON.stringify(value,null,2)+'\\n')" "$manifest"
}
rebind_asset() {
  node -e 'const fs=require("fs"),crypto=require("crypto"),path=require("path");const root=process.argv[1],rel=process.argv[2],b=fs.readFileSync(path.join(root,rel)),p=path.join(root,"Examples/DesignOSAppleGallery/Generated/local-demo-image-provenance.v1.json"),m=JSON.parse(fs.readFileSync(p)),a=m.assets.find(x=>x.path===rel);a.byteSize=b.length;a.dimensions={width:b.readUInt32BE(16),height:b.readUInt32BE(20)};a.sha256=crypto.createHash("sha256").update(b).digest("hex");fs.writeFileSync(p,JSON.stringify(m,null,2)+"\n")' "$1" "$2"
}
mutate_png() {
  local case_root=$1 relative=$2 mode=$3 amount=$4
  node -e 'const fs=require("fs"),path=require("path"),p=path.join(process.argv[1],process.argv[2]),mode=process.argv[3],n=Number(process.argv[4]);let b=fs.readFileSync(p);function crc(parts){let c=0xffffffff;for(const part of parts)for(const v of part){c^=v;for(let i=0;i<8;i++)c=(c>>>1)^(0xedb88320&-(c&1))}return(c^0xffffffff)>>>0}if(mode==="truncate")b=b.subarray(0,n);else if(mode==="width"){b.writeUInt32BE(n,16);b.writeUInt32BE(crc([b.subarray(12,16),b.subarray(16,29)]),29)}else if(mode==="pad"){const type=Buffer.from("raNd"),data=Buffer.alloc(n),chunk=Buffer.alloc(n+12);chunk.writeUInt32BE(n);type.copy(chunk,4);data.copy(chunk,8);chunk.writeUInt32BE(crc([type,data]),n+8);b=Buffer.concat([b.subarray(0,b.length-12),chunk,b.subarray(b.length-12)])}fs.writeFileSync(p,b)' "$case_root" "$relative" "$mode" "$amount"
  rebind_asset "$case_root" "$relative"
}
package_resource_mutation() {
  node -e 'const fs=require("fs"),p=process.argv[1],rule=process.argv[2],rel=process.argv[3];let s=fs.readFileSync(p,"utf8");s=s.replace(".target(name: \"DesignOSApple\"),",".target(name: \"DesignOSApple\", resources: [."+rule+"(\""+rel+"\")]),");fs.writeFileSync(p,s)' "$1/Package.swift" "$2" "$3"
}

probe_relative="Examples/DesignOSAppleGallery/Resources/CatalogThumbnails.xcassets/demo-thoughtful-chat-thumbnail.imageset/demo-thoughtful-chat-thumbnail.png"
case_root=$(generated_case missing-asset)
find "$case_root/$probe_relative" -maxdepth 0 -type f -delete
expect_generated_rejected "missing fixed asset" "$case_root" "missing file '$probe_relative'"
case_root=$(generated_case extra-asset)
manifest_mutation "$case_root" 'value.assets.push({...value.assets[0],name:"demo-extra-thumbnail",path:value.assets[0].path.replace("thoughtful-chat","extra")})'
expect_generated_rejected "extra manifest asset" "$case_root" "manifest asset count mismatch"
case_root=$(generated_case duplicate-asset)
manifest_mutation "$case_root" 'value.assets.push({...value.assets[0]})'
expect_generated_rejected "duplicate manifest asset" "$case_root" "manifest asset count mismatch"
case_root=$(generated_case wrong-path)
manifest_mutation "$case_root" 'value.assets[0].path="Examples/DesignOSAppleGallery/Resources/arbitrary.png"'
expect_generated_rejected "wrong manifest path" "$case_root" "manifest path set mismatch"
case_root=$(generated_case stale-hash)
manifest_mutation "$case_root" 'value.assets[0].sha256="0".repeat(64)'
expect_generated_rejected "stale hash" "$case_root" "SHA-256 mismatch"
case_root=$(generated_case malformed-clean-room)
manifest_mutation "$case_root" 'value.assets[0].cleanRoom.containsReadableText="false"'
expect_generated_rejected "malformed clean-room declaration" "$case_root" "clean-room declaration mismatch"

case_root=$(generated_case malformed-png)
print -n -- "not-a-png" > "$case_root/$probe_relative"
manifest_mutation "$case_root" 'value.assets[0].byteSize=9;value.assets[0].sha256=require("crypto").createHash("sha256").update("not-a-png").digest("hex")'
expect_generated_rejected "malformed PNG signature" "$case_root" "invalid PNG signature"
case_root=$(generated_case malformed-ihdr)
node -e 'const fs=require("fs"),p=process.argv[1],b=fs.readFileSync(p);b.write("NOPE",12,"ascii");fs.writeFileSync(p,b)' "$case_root/$probe_relative"
expect_generated_rejected "malformed PNG IHDR" "$case_root" "PNG CRC mismatch"
case_root=$(generated_case truncated-png)
mutate_png "$case_root" "$probe_relative" truncate 33
expect_generated_rejected "header-valid truncated PNG" "$case_root" "missing PNG IDAT"
case_root=$(generated_case excessive-dimensions)
mutate_png "$case_root" "$probe_relative" width 2049
expect_generated_rejected "dimension excess" "$case_root" "dimension exceeds 2048"
case_root=$(generated_case excessive-size)
mutate_png "$case_root" "$probe_relative" pad 1900000
expect_generated_rejected "per-file size excess" "$case_root" "file exceeds 3 MiB"
case_root=$(generated_case excessive-aggregate)
for image in "$case_root"/Examples/DesignOSAppleGallery/Resources/{CatalogThumbnails,LocalDemoMedia}.xcassets/*.imageset/*.png; do
  relative=${image#$case_root/}
  mutate_png "$case_root" "$relative" pad 320000
done
expect_generated_rejected "aggregate size excess" "$case_root" "aggregate generated art exceeds 20 MiB"
case_root=$(generated_case symlink-asset)
find "$case_root/$probe_relative" -maxdepth 0 -type f -delete
ln -s "$generated_base/$probe_relative" "$case_root/$probe_relative"
expect_generated_rejected "symlinked generated art" "$case_root" "nonregular or symlinked"
case_root=$(generated_case contents-mismatch)
contents="$case_root/Examples/DesignOSAppleGallery/Resources/CatalogThumbnails.xcassets/demo-thoughtful-chat-thumbnail.imageset/Contents.json"
node -e 'const fs=require("fs"),p=process.argv[1],v=JSON.parse(fs.readFileSync(p));v.images[0].filename="wrong.png";fs.writeFileSync(p,JSON.stringify(v,null,2)+"\n")' "$contents"
expect_generated_rejected "asset catalog Contents mismatch" "$case_root" "Contents mismatch"
case_root=$(generated_case package-gallery-directory-copy)
package_resource_mutation "$case_root" copy "../../Examples/DesignOSAppleGallery"
expect_generated_rejected "Package.swift Gallery directory copy" "$case_root" "Swift package admits Gallery generated art"
case_root=$(generated_case package-catalog-directory-process)
package_resource_mutation "$case_root" process "../../Examples/DesignOSAppleGallery/Resources/CatalogThumbnails.xcassets"
expect_generated_rejected "Package.swift catalog directory process" "$case_root" "Swift package admits Gallery generated art"
case_root=$(generated_case package-media-directory-process)
package_resource_mutation "$case_root" process "../../Examples/DesignOSAppleGallery/Resources/LocalDemoMedia.xcassets"
expect_generated_rejected "Package.swift media directory process" "$case_root" "Swift package admits Gallery generated art"

fixture_dir=$(mktemp -d "$project_root/docs/.publication-boundary-fixture.XXXXXX")
fixture_owner_token=${fixture_dir:t}
print -r -- "$fixture_owner_token" > "$fixture_dir/$owner_marker"
asset_root="$project_root/Examples/DesignOSAppleGallery/Resources/CatalogThumbnails.xcassets"
asset_seed=$(mktemp -d "$asset_root/catalog-boundary-fixture.XXXXXX")
asset_owner_token=${asset_seed:t}
print -r -- "$asset_owner_token" > "$asset_seed/$owner_marker"
asset_fixture_dir="${asset_seed}.imageset"
mv "$asset_seed" "$asset_fixture_dir"

expect_rejected() {
  local label=$1 relative_path=$2 expected_reason=$3 output
  print -r -- "$relative_path" > "$file_list"
  if output=$("$verifier" --file-list "$file_list" 2>&1); then
    print -u2 -- "E_BOUNDARY_TEST: accepted hostile fixture '$label'"
    exit 1
  fi
  [[ "$output" == *"$expected_reason"* ]] || {
    print -u2 -- "E_BOUNDARY_TEST: hostile fixture '$label' rejected for wrong reason"
    print -u2 -- "Expected: $expected_reason"
    print -u2 -- "Actual: $output"
    exit 1
  }
}

print -r -- "README.md" > "$file_list"
"$verifier" --file-list "$file_list" >/dev/null
if "$verifier" --file-list-exact "$file_list" >/dev/null 2>&1; then
  print -u2 -- "E_BOUNDARY_TEST: exact mode accepted an incomplete candidate"
  exit 1
fi
approved_thumbnail="Examples/DesignOSAppleGallery/Resources/CatalogThumbnails.xcassets/catalog-foundation-profile-customization.imageset/catalog-foundation-profile-customization.png"
print -r -- "$approved_thumbnail" > "$file_list"
"$verifier" --file-list "$file_list" >/dev/null
cp "$project_root/$approved_thumbnail" "$asset_fixture_dir/wrong-name.png"
expect_rejected "mismatched generated catalog thumbnail name" "${asset_fixture_dir#$project_root/}/wrong-name.png" "unapproved binary or design asset"
expect_rejected "maintainer configuration" "AGENTS.md" "forbidden local evidence"
expect_rejected "private evidence validator" "Sources/DesignOSDogfoodEvidenceValidator/main.swift" "unclassified path"
expect_rejected "parent traversal" "../README.md" "unsafe path"
personal_fixture=${fixture_dir#$project_root/}/personal-path.txt
print -r -- "/""Users""/""private-user""/workspace" > "$project_root/$personal_fixture"
expect_rejected "personal home path" "$personal_fixture" "personal path or credential pattern"
credential_fixture=${fixture_dir#$project_root/}/credential.txt
print -r -- "gh""p_""$(printf 'a%.0s' {1..24})" > "$project_root/$credential_fixture"
expect_rejected "credential" "$credential_fixture" "personal path or credential pattern"
symlink_fixture=${fixture_dir#$project_root/}/linked-readme.txt
ln -s "$project_root/README.md" "$project_root/$symlink_fixture"
expect_rejected "symlink" "$symlink_fixture" "missing, nonregular, or symlinked file"
large_fixture=${fixture_dir#$project_root/}/oversized.txt
dd if=/dev/zero of="$project_root/$large_fixture" bs=1048577 count=1 2>/dev/null
expect_rejected "oversized file" "$large_fixture" "file exceeds 1 MiB"

print -- "Publication boundary hostile probes passed."
