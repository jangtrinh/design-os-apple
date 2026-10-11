#!/usr/bin/env python3
"""Verify the exact reviewed public marketing image set, without network access.

Hashes bind these documentation assets to the reviewed CI export manifest. This
checks provenance integrity, not independent runtime acceptance or visual fidelity.
"""
import argparse
import hashlib
import json
import re
from pathlib import Path
import struct
import sys

DIRECTORY = "docs/assets/marketing"
MANIFEST_SHA256 = "8d41bcc4d4972815526432b09677b4657f5ecf70470a5ad4aec25a7c0a8feb27"
EXPECTED = {
    "iphone-discovery-light.png", "iphone-discovery-dark.png",
    "iphone-media-composer-dark.png", "iphone-grouped-form-light.png",
    "iphone-message-thread-dark.png", "iphone-onboarding-light.png",
    "ipad-discovery-light.png", "macos-discovery-dark.png", "kit-overview.png",
}
CANDIDATE_SHA = "adcf88a468a43ed1727c9c902ae5243423e4176e"
RUN_ID = 38087127370


def require(condition, message):
    if not condition:
        raise ValueError(f"E_MARKETING_IMAGE: {message}")


def regular(root, relative):
    target = root / relative
    require(target.is_file() and not target.is_symlink(), f"missing or nonregular {relative}")
    require(target.resolve() == target, f"symlink-resolved {relative}")
    return target


def verify(root):
    root = Path(root).resolve(strict=True)
    directory = root / DIRECTORY
    require(directory.is_dir() and not directory.is_symlink(), "missing or symlinked marketing directory")
    require(directory.resolve() == directory, "symlinked marketing ancestor")
    require({p.name for p in directory.iterdir()} == EXPECTED | {"manifest.json"}, "unexpected or missing marketing file")
    raw = regular(root, f"{DIRECTORY}/manifest.json").read_bytes()
    require(hashlib.sha256(raw).hexdigest() == MANIFEST_SHA256, "unreviewed provenance manifest")
    manifest = json.loads(raw)
    require(manifest.get("version") == 1, "unsupported manifest version")
    source = manifest.get("source", {})
    require(source.get("repository") == "jangtrinh/design-os-apple", "wrong source repository")
    require(source.get("head_sha") == CANDIDATE_SHA, "wrong source commit")
    require(source.get("run_id") == RUN_ID, "wrong source CI run")
    require(source.get("run_url") == f"https://github.com/jangtrinh/design-os-apple/actions/runs/{RUN_ID}", "wrong source run URL")
    assets = manifest.get("assets", [])
    require(len(assets) == len(EXPECTED), "wrong asset count")
    require({a.get("file") for a in assets} == EXPECTED, "duplicate or unexpected asset entry")
    for asset in assets:
        name = asset["file"]
        expected_kind = "screenshot-composition" if name == "kit-overview.png" else "native-ci-screenshot"
        require(asset.get("kind") == expected_kind, f"wrong source kind: {name}")
        if expected_kind == "native-ci-screenshot":
            original = asset.get("source", {})
            platform = "iphone" if name.startswith("iphone-") else "ipad" if name.startswith("ipad-") else "macos"
            artifact_ids = {"iphone": 11683400972, "ipad": 11683226773, "macos": 11682309988}
            require(original.get("artifact_id") == artifact_ids[platform], f"wrong source artifact: {name}")
            require(original.get("artifact_name") == f"layered-kit-{platform}-test-results", f"wrong artifact name: {name}")
            require(original.get("test_identifier") == "LayeredKitPreviewUITests/testEighteenScreenTypesInLightAndDark()", f"wrong capture test: {name}")
            for key in ("sha256", "artifact_sha256", "manifest_sha256"):
                require(re.fullmatch(r"[a-f0-9]{64}", original.get(key, "")), f"missing source hash: {name}/{key}")
        else:
            inputs = asset.get("source_files", [])
            require(inputs and set(inputs) <= EXPECTED - {name}, "unadmitted composition input")
            placements = asset.get("composition", {}).get("placements", [])
            require({p.get("file") for p in placements} == set(inputs), "composition placement mismatch")
        data = regular(root, f"{DIRECTORY}/{name}").read_bytes()
        require(0 < len(data) <= 8 * 1024 * 1024, f"image exceeds bounded size: {name}")
        require(len(data) == asset.get("byte_size"), f"byte count mismatch: {name}")
        require(hashlib.sha256(data).hexdigest() == asset.get("sha256"), f"image hash mismatch: {name}")
        require(data[:8] == b"\x89PNG\r\n\x1a\n" and data[12:16] == b"IHDR", f"not a PNG: {name}")
        width, height = struct.unpack(">II", data[16:24])
        require((width, height) == (asset.get("width"), asset.get("height")), f"dimension mismatch: {name}")
        require(0 < width <= 10000 and 0 < height <= 10000, f"invalid dimensions: {name}")
    return len(assets)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--root", type=Path, default=Path(__file__).resolve().parent.parent)
    args = parser.parse_args()
    try:
        count = verify(args.root)
    except (OSError, ValueError, KeyError, TypeError, struct.error) as error:
        print(error, file=sys.stderr)
        return 1
    print(f"Marketing image provenance passed: {count} exact reviewed images (runtime acceptance is separate).")
    return 0


if __name__ == "__main__":
    sys.exit(main())
