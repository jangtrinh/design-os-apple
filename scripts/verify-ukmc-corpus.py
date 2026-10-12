#!/usr/bin/env python3
"""Strict local verification for UKMC knowledge units, source corpus, and entity relationships.

Validates all artifacts against UKMC standards and the canonical contract:
1. Validates all source files in docs/corpus/ match their SHA256 digests in manifest.json.
2. Invokes canonical UniversalKnowledgeUnit.validate() from knowledge-builder contract.py.
3. Verifies frontmatter source_attribution (uri, modality, sha256, captured_at, license).
4. Verifies ALL <!-- ease:source ... --> anchors match known sources with identical SHA256.
5. Verifies quarantine block exists with is_external_untrusted bool.
6. Verifies relationships.linked_units resolve to real existing knowledge unit IDs.
7. Supports --check mode (read-only verification ensuring existing index.strict.json matches freshly computed normalized entries).
8. Fails closed and never writes index.strict.json if any error occurs.
"""

import argparse
from datetime import datetime
import hashlib
import json
import os
import re
import sys
from pathlib import Path

# Prevent bytecode caching into repository publication boundaries
sys.dont_write_bytecode = True

# Canonical validation remains mandatory unless local-only fallback is explicitly requested.
REPO_ROOT = Path(__file__).resolve().parent.parent
KB_SRC = REPO_ROOT.parent / "knowledge-builder" / "src"
HAS_CANONICAL_BUILDER = False
CANONICAL_ERROR = ""


def load_canonical_contract(source=None):
    """Load the canonical contract from an explicit source or the legacy sibling checkout."""
    global HAS_CANONICAL_BUILDER, CANONICAL_ERROR
    global UniversalKnowledgeUnit, KnowledgeMetadata, SourceAttribution, ModalityType, TrustTier
    source = Path(source or os.environ.get("UKMC_KNOWLEDGE_BUILDER_SRC") or KB_SRC).expanduser().resolve()
    HAS_CANONICAL_BUILDER = False
    CANONICAL_ERROR = f"Canonical knowledge-builder contract not found at {source}"
    if not (source / "knowledge_builder" / "contract.py").is_file():
        return
    if not (source / "knowledge_builder" / "__init__.py").is_file():
        CANONICAL_ERROR = f"Canonical knowledge-builder source at {source} must contain knowledge_builder/__init__.py; namespace packages are not supported"
        return
    # Never let a previously imported or installed package override the selected source.
    for name in list(sys.modules):
        if name == "knowledge_builder" or name.startswith("knowledge_builder."):
            del sys.modules[name]
    sys.path.insert(0, str(source))
    try:
        from knowledge_builder.contract import (
            UniversalKnowledgeUnit, KnowledgeMetadata, SourceAttribution, ModalityType, TrustTier,
        )
        loaded = Path(sys.modules["knowledge_builder.contract"].__file__).resolve()
        if loaded != (source / "knowledge_builder" / "contract.py").resolve():
            raise ImportError(f"Resolved contract outside selected source: {loaded}")
        HAS_CANONICAL_BUILDER = True
        CANONICAL_ERROR = ""
    except Exception as exc:
        CANONICAL_ERROR = f"Canonical knowledge-builder contract could not load from {source}: {type(exc).__name__}: {exc}"
    finally:
        sys.path.remove(str(source))


if __name__ != "__main__":
    load_canonical_contract()


def validate_iso8601_timestamp(ts: str) -> bool:
    if not isinstance(ts, str) or not ts.strip():
        return False
    try:
        s = ts.strip()
        if s.endswith("Z"):
            s = s[:-1] + "+00:00"
        dt = datetime.fromisoformat(s)
        return dt.tzinfo is not None
    except Exception:
        return False


def compute_sha256(filepath: Path) -> str:
    h = hashlib.sha256()
    with open(filepath, "rb") as f:
        while chunk := f.read(65536):
            h.update(chunk)
    return h.hexdigest()


def parse_frontmatter(content: str):
    if not content.startswith("---\n"):
        return None, content
    parts = content.split("---\n", 2)
    if len(parts) < 3:
        return None, content
    fm_raw = parts[1]
    body = parts[2]

    data = {}
    current_key = None
    sub_dict = None
    sub_list = None

    for line in fm_raw.splitlines():
        line_clean = line.rstrip()
        if not line_clean or line_clean.startswith("#"):
            continue

        m_top = re.match(r"^([a-z0-9_]+):\s*(.*)$", line_clean)
        if m_top and not line_clean.startswith(" "):
            key, val = m_top.groups()
            current_key = key
            sub_dict = None
            sub_list = None
            if val:
                val = val.strip().strip("\"'")
                if val.startswith("[") and val.endswith("]"):
                    try:
                        data[key] = json.loads(val)
                    except Exception:
                        data[key] = [x.strip().strip("\"'") for x in val[1:-1].split(",") if x.strip()]
                else:
                    data[key] = val
            else:
                data[key] = {}
            continue

        m_sub = re.match(r"^\s{2}([a-z0-9_]+):\s*(.*)$", line_clean)
        if m_sub and current_key:
            sub_k, sub_v = m_sub.groups()
            sub_v = sub_v.strip()
            if isinstance(data[current_key], dict):
                if sub_v:
                    if sub_v == "false":
                        data[current_key][sub_k] = False
                    elif sub_v == "true":
                        data[current_key][sub_k] = True
                    else:
                        data[current_key][sub_k] = sub_v.strip("\"'")
                else:
                    data[current_key][sub_k] = []
                    sub_list = data[current_key][sub_k]
            continue

        m_item = re.match(r"^\s{4}-\s*(.*)$", line_clean)
        if m_item and sub_list is not None:
            raw_item = m_item.group(1).strip()
            if ":" in raw_item:
                item_dict = {}
                k, v = raw_item.split(":", 1)
                item_dict[k.strip()] = v.strip().strip("\"'")
                sub_list.append(item_dict)
            else:
                sub_list.append(raw_item.strip("\"'"))
            continue

        m_sub_item = re.match(r"^\s{6}([a-z0-9_]+):\s*(.*)$", line_clean)
        if m_sub_item and sub_list and isinstance(sub_list[-1], dict):
            k, v = m_sub_item.groups()
            sub_list[-1][k.strip()] = v.strip().strip("\"'")
            continue

    return data, body


def extract_section(body: str, heading: str) -> str:
    pattern = rf"^## {re.escape(heading)}(?:[^\n]*)\n(.*?)(?=^## |\Z)"
    match = re.search(pattern, body, re.MULTILINE | re.DOTALL)
    return match.group(1).strip() if match else ""


def extract_list_items(section_text: str, subheader: str = None) -> list:
    if subheader:
        pattern = rf"^### {re.escape(subheader)}\s*$(.*?)(?=^### |\Z)"
        m = re.search(pattern, section_text, re.MULTILINE | re.DOTALL)
        if not m:
            return []
        text = m.group(1)
    else:
        text = section_text
    items = []
    for line in text.splitlines():
        line = line.strip()
        if line.startswith("- "):
            items.append(line[2:].strip())
        elif re.match(r"^\d+\.\s+", line):
            items.append(re.sub(r"^\d+\.\s+", "", line).strip())
    return items


def verify_corpus_and_units(repo_root: Path, check_only: bool = False, allow_fallback: bool = False) -> list:
    corpus_dir = repo_root / "docs" / "corpus"
    knowledge_dir = repo_root / "docs" / "knowledge"
    manifest_path = corpus_dir / "manifest.json"
    errors = []

    # 1. Verify Manifest and Corpus Files
    if not manifest_path.exists():
        return [f"Corpus manifest missing: {manifest_path}"]

    try:
        with open(manifest_path, "r", encoding="utf-8") as f:
            manifest = json.load(f)
    except (OSError, ValueError) as exc:
        return [f"Could not read corpus manifest: {exc}"]
    if not isinstance(manifest, dict) or not manifest:
        return ["Corpus manifest must be a non-empty JSON object"]

    manifest_info_by_uri = {}
    print(f"[*] Checking {len(manifest)} source corpus files in {corpus_dir}...")
    for key, info in manifest.items():
        if not isinstance(info, dict):
            errors.append(f"Manifest entry '{key}' must be an object")
            continue
        rel_file = info.get("file", "")
        if not isinstance(rel_file, str) or not rel_file:
            errors.append(f"Manifest entry '{key}' needs a non-empty file path")
            continue
        file_path = (repo_root / rel_file).resolve()
        if not file_path.is_relative_to(corpus_dir.resolve()):
            errors.append(f"Manifest entry '{key}' file path must stay inside docs/corpus")
            continue
        if not file_path.is_file():
            errors.append(f"Corpus file missing: {rel_file}")
            continue

        invalid_fields = False
        for req_key in ["uri", "sha256", "captured_at", "modality", "license"]:
            if not isinstance(info.get(req_key), str) or not info[req_key].strip():
                errors.append(f"Manifest entry '{key}' missing required string field: '{req_key}'")
                invalid_fields = True
        if invalid_fields:
            continue
        if info["uri"] in manifest_info_by_uri:
            errors.append(f"Manifest entry '{key}' duplicates source URI: {info['uri']}")
            continue

        if "captured_at" in info and not validate_iso8601_timestamp(info["captured_at"]):
            errors.append(f"Manifest entry '{key}' has invalid ISO 8601 captured_at: '{info['captured_at']}'")

        actual_hash = compute_sha256(file_path)
        expected_hash = info.get("sha256", "")
        if actual_hash != expected_hash:
            errors.append(f"Corpus hash mismatch for {key}: expected {expected_hash}, got {actual_hash}")
        else:
            manifest_info_by_uri[info["uri"]] = {
                "key": key,
                "sha256": actual_hash,
                "captured_at": info.get("captured_at"),
                "modality": info.get("modality"),
            }
            print(f"  [✓] Source {key}: SHA256 verified ({actual_hash[:12]}...)")

    # 2. Check Knowledge Units
    knowledge_files = sorted(list(knowledge_dir.glob("*.md")))
    if not knowledge_files:
        errors.append("No knowledge units found in docs/knowledge/")

    print(f"\n[*] Validating {len(knowledge_files)} UKMC units in {knowledge_dir}...")
    unit_ids = {}
    parsed_units = {}

    for kf in knowledge_files:
        if kf.name.upper() == "README.MD":
            continue
        content = kf.read_text(encoding="utf-8")
        fm, body = parse_frontmatter(content)
        if not fm:
            errors.append(f"Malformed frontmatter in {kf.name}")
            continue

        uid = fm.get("id")
        if not isinstance(uid, str) or not uid or not re.match(r"^[a-z0-9]+(?:-[a-z0-9]+)*$", uid):
            errors.append(f"Invalid or missing id in {kf.name}: '{uid}'")
            continue
        elif uid in unit_ids:
            errors.append(f"Duplicate unit id '{uid}' in {kf.name}")
        else:
            unit_ids[uid] = kf.name

        # Check required frontmatter fields
        for req in ["title", "domain", "description", "when", "trust_tier", "version", "source_attribution", "quarantine"]:
            if req not in fm:
                errors.append(f"{kf.name} missing frontmatter key: '{req}'")

        # Check when non-empty list of non-empty strings
        when_tags = fm.get("when", [])
        if not isinstance(when_tags, list) or len(when_tags) == 0:
            errors.append(f"{kf.name}: 'when' tags must be a non-empty list")
        elif any(not isinstance(t, str) or not t.strip() for t in when_tags):
            errors.append(f"{kf.name}: 'when' tags must contain non-empty string tags")

        # Check quarantine
        q = fm.get("quarantine", {})
        if not isinstance(q, dict) or "is_external_untrusted" not in q:
            errors.append(f"{kf.name}: 'quarantine.is_external_untrusted' boolean required")
        elif not isinstance(q.get("is_external_untrusted"), bool):
            errors.append(f"{kf.name}: 'quarantine.is_external_untrusted' must be an actual boolean (true/false), got: '{q.get('is_external_untrusted')}'")

        # Verify source_attribution
        sa = fm.get("source_attribution", {})
        if not isinstance(sa, dict):
            errors.append(f"{kf.name}: 'source_attribution' must be a mapping/dict")
            sa = {}
        sa_uri = sa.get("uri")
        sa_sha = sa.get("sha256")
        sa_mod = sa.get("modality")
        sa_cap = sa.get("captured_at")
        sa_lic = sa.get("license")

        for fld, val in [("uri", sa_uri), ("sha256", sa_sha), ("modality", sa_mod), ("captured_at", sa_cap), ("license", sa_lic)]:
            if not val or not str(val).strip():
                errors.append(f"{kf.name}: source_attribution missing or empty '{fld}'")

        if sa_cap:
            if not validate_iso8601_timestamp(sa_cap):
                errors.append(f"{kf.name}: source_attribution.captured_at '{sa_cap}' is not a valid ISO 8601 aware timestamp")

        # Check modality enum strictly without silently coercing
        allowed_modalities = [m.value for m in ModalityType] if HAS_CANONICAL_BUILDER else ["pdf", "video", "audio", "image", "web", "markdown"]
        if not sa_mod:
            errors.append(f"{kf.name}: missing source_attribution.modality")
        elif sa_mod not in allowed_modalities:
            errors.append(f"{kf.name}: invalid modality '{sa_mod}'. Allowed values: {allowed_modalities}")

        # Check trust_tier enum strictly without silently coercing
        allowed_tiers = [t.value for t in TrustTier] if HAS_CANONICAL_BUILDER else ["verified", "community_reference", "draft"]
        tier_val = fm.get("trust_tier")
        if not tier_val:
            errors.append(f"{kf.name}: missing 'trust_tier'")
        elif tier_val not in allowed_tiers:
            errors.append(f"{kf.name}: invalid trust_tier '{tier_val}'. Allowed values: {allowed_tiers}")

        if sa_uri in manifest_info_by_uri:
            m_entry = manifest_info_by_uri[sa_uri]
            if m_entry["sha256"] != sa_sha:
                errors.append(f"{kf.name}: source_attribution SHA256 does not match corpus ({sa_sha} vs {m_entry['sha256']})")
            if sa_cap and m_entry.get("captured_at") and sa_cap != m_entry.get("captured_at"):
                errors.append(f"{kf.name}: source_attribution.captured_at '{sa_cap}' does not match corpus manifest timestamp '{m_entry.get('captured_at')}'")
            print(f"  [✓] {kf.name}: Primary source attribution cryptographically verified.")
        else:
            errors.append(f"{kf.name} references unverified URI: {sa_uri}")

        # Check mandatory body headings
        for h in ["Purpose", "When to Use / When NOT", "Core Knowledge Content", "Failure Modes"]:
            sec_text = extract_section(body, h)
            if not sec_text:
                errors.append(f"{kf.name} missing or empty mandatory section '## {h}'")

        purpose_text = extract_section(body, "Purpose")
        when_section = extract_section(body, "When to Use / When NOT")
        allowed_items = extract_list_items(when_section, "ALLOWED (When to Use)")
        not_allowed_items = extract_list_items(when_section, "NOT ALLOWED (When NOT to Use)")
        core_content = extract_section(body, "Core Knowledge Content")
        failure_section = extract_section(body, "Failure Modes")
        failure_modes = extract_list_items(failure_section)

        if not allowed_items:
            errors.append(f"{kf.name}: 'When to Use / When NOT' missing ALLOWED items")
        if not not_allowed_items:
            errors.append(f"{kf.name}: 'When to Use / When NOT' missing NOT ALLOWED items")
        if not failure_modes:
            errors.append(f"{kf.name}: 'Failure Modes' contains no numbered failure items")

        # Verify ALL <!-- ease:source ... --> anchors in body
        anchor_comments = re.findall(r'<!--\s*ease:source\b.*?(?:-->|\Z)', body, re.DOTALL)
        all_anchors = []
        for comment in anchor_comments:
            match = re.fullmatch(r'<!--\s*ease:source\s+ref="([^"\n]+)"\s+sha256="([a-f0-9]{64})"\s+captured="([^"\n]+)"\s*-->', comment)
            if match is None:
                errors.append(f"{kf.name}: malformed ease:source provenance anchor")
            else:
                all_anchors.append(match.groups())
        if not all_anchors:
            errors.append(f"{kf.name} missing '<!-- ease:source ... -->' provenance anchor")
        else:
            for a_ref, a_sha, a_cap in all_anchors:
                if not validate_iso8601_timestamp(a_cap):
                    errors.append(f"{kf.name} anchor captured timestamp '{a_cap}' is not a valid ISO 8601 aware timestamp")
                if a_ref not in manifest_info_by_uri:
                    errors.append(f"{kf.name} anchor ref '{a_ref}' is not in corpus manifest")
                else:
                    m_entry = manifest_info_by_uri[a_ref]
                    if m_entry["sha256"] != a_sha:
                        errors.append(f"{kf.name} anchor SHA256 '{a_sha}' does not match corpus ({m_entry['sha256']}) for ref '{a_ref}'")
                    if m_entry.get("captured_at") and a_cap != m_entry.get("captured_at"):
                        errors.append(f"{kf.name} anchor captured timestamp '{a_cap}' does not match corpus manifest timestamp '{m_entry.get('captured_at')}' for ref '{a_ref}'")
                    print(f"  [✓] {kf.name}: Verified provenance anchor for '{a_ref}'")

        # Canonical Contract Validation
        if HAS_CANONICAL_BUILDER:
            try:
                tier_enum = TrustTier(tier_val) if tier_val in allowed_tiers else TrustTier.DRAFT
                mod_enum = ModalityType(sa_mod) if sa_mod in allowed_modalities else ModalityType.WEB
                c_meta = KnowledgeMetadata(
                    id=uid,
                    title=fm.get("title", ""),
                    domain=fm.get("domain", ""),
                    description=fm.get("description", ""),
                    when=when_tags,
                    trust_tier=tier_enum,
                    version=fm.get("version", "1.0.0"),
                )
                c_source = SourceAttribution(
                    uri=sa_uri or "",
                    modality=mod_enum,
                    sha256=sa_sha or "",
                    captured_at=sa_cap or "",
                    license_or_origin=sa_lic or "unknown",
                )
                c_unit = UniversalKnowledgeUnit(
                    metadata=c_meta,
                    source=c_source,
                    purpose=purpose_text,
                    when_to_use=allowed_items,
                    when_not_to_use=not_allowed_items,
                    content=core_content,
                    failure_modes=failure_modes,
                    is_external_untrusted=q.get("is_external_untrusted", False) if isinstance(q.get("is_external_untrusted"), bool) else False,
                )
                contract_errors = c_unit.validate()
                if contract_errors:
                    for ce in contract_errors:
                        errors.append(f"{kf.name} canonical contract error: {ce}")
                else:
                    print(f"  [✓] {kf.name}: UniversalKnowledgeUnit.validate() passed.")
            except Exception as ex:
                errors.append(f"{kf.name} canonical instantiation failed: {ex}")
        else:
            if not allow_fallback:
                errors.append(f"{kf.name}: {CANONICAL_ERROR or 'Canonical knowledge-builder contract not found'}. Set --knowledge-builder-src or UKMC_KNOWLEDGE_BUILDER_SRC. --allow-fallback performs local checks only.")

        parsed_units[uid] = (kf, fm, body)

    # 3. Verify Entity Relationships
    print("\n[*] Validating entity relationships...")
    for uid, (kf, fm, _) in parsed_units.items():
        rel = fm.get("relationships", {})
        if not isinstance(rel, dict):
            errors.append(f"{kf.name}: relationships must be a mapping")
            continue
        linked = rel.get("linked_units", [])
        if not isinstance(linked, list):
            errors.append(f"{kf.name}: relationships.linked_units must be a list")
            continue
        if linked:
            for link in linked:
                if not isinstance(link, dict):
                    errors.append(f"{kf.name}: each linked unit must be a mapping")
                    continue
                target_id = link.get("id")
                rel_type = link.get("relationship")
                if not isinstance(target_id, str) or not target_id or target_id not in unit_ids:
                    errors.append(f"{kf.name}: Relationship references non-existent unit id '{target_id}'")
                elif rel_type not in ["prerequisite", "extends", "complements", "replaces"]:
                    errors.append(f"{kf.name}: Invalid relationship type '{rel_type}' for target '{target_id}'")
                else:
                    print(f"  [✓] {uid} --({rel_type})--> {target_id}")

    # 4. Strictly Compile or Verify Index ONLY if 0 errors
    if errors:
        return errors

    strict_index_path = knowledge_dir / "index.strict.json"
    strict_index = []
    for uid, (kf, fm, _) in parsed_units.items():
        file_sha = compute_sha256(kf)
        strict_index.append({
            "id": uid,
            "path": kf.name,
            "file_sha256": file_sha,
            "source_uri": fm.get("source_attribution", {}).get("uri", ""),
            "source_sha256": fm.get("source_attribution", {}).get("sha256", ""),
            "linked_units": fm.get("relationships", {}).get("linked_units", [])
        })

    strict_index = sorted(strict_index, key=lambda x: x["id"])

    if check_only:
        print("\n[*] Verifying existing index.strict.json against current knowledge units (read-only)...")
        if not strict_index_path.exists():
            errors.append(f"Strict index missing in check mode: {strict_index_path.relative_to(repo_root)}")
            return errors

        try:
            with open(strict_index_path, "r", encoding="utf-8") as f:
                existing_index = json.load(f)
        except Exception as ex:
            errors.append(f"Could not parse existing index.strict.json: {ex}")
            return errors

        if not isinstance(existing_index, list):
            errors.append("Existing index.strict.json root must be a JSON array")
            return errors

        if any(not isinstance(entry, dict) for entry in existing_index):
            return ["Each index.strict.json entry must be a JSON object"]
        sorted_existing = sorted(existing_index, key=lambda x: str(x.get("id", "")))

        if len(sorted_existing) != len(strict_index):
            errors.append(
                f"index.strict.json entry count mismatch: expected {len(strict_index)}, got {len(sorted_existing)}"
            )
            return errors

        for exp, act in zip(strict_index, sorted_existing):
            uid = exp["id"]
            if act.get("id") != uid:
                errors.append(f"index.strict.json entry id mismatch: expected '{uid}', got '{act.get('id')}'")
                continue
            if act.get("path") != exp["path"]:
                errors.append(f"index.strict.json path mismatch for unit '{uid}': expected '{exp['path']}', got '{act.get('path')}'")
            if act.get("file_sha256") != exp["file_sha256"]:
                errors.append(
                    f"index.strict.json stale file_sha256 for unit '{uid}': "
                    f"index has '{act.get('file_sha256')}', actual file has '{exp['file_sha256']}'"
                )
            if act.get("source_uri") != exp["source_uri"]:
                errors.append(
                    f"index.strict.json source_uri mismatch for unit '{uid}': "
                    f"index has '{act.get('source_uri')}', expected '{exp['source_uri']}'"
                )
            if act.get("source_sha256") != exp["source_sha256"]:
                errors.append(
                    f"index.strict.json source_sha256 mismatch for unit '{uid}': "
                    f"index has '{act.get('source_sha256')}', expected '{exp['source_sha256']}'"
                )
            if act.get("linked_units") != exp["linked_units"]:
                errors.append(
                    f"index.strict.json linked_units mismatch for unit '{uid}': "
                    f"index has {act.get('linked_units')}, expected {exp['linked_units']}"
                )

        if not errors:
            print("  [✓] Existing index.strict.json matches freshly computed normalized entries and file hashes.")
    else:
        print("\n[*] Compiling strict index with real file SHA256 digests...")
        with open(strict_index_path, "w", encoding="utf-8") as f:
            json.dump(strict_index, f, indent=2)
            f.write("\n")
        print(f"  [✓] Wrote strict verified index to: {strict_index_path.relative_to(repo_root)}")

    return errors


def main():
    parser = argparse.ArgumentParser(description="Strict UKMC and Corpus Verifier")
    parser.add_argument("--check", action="store_true", help="Run in read-only check mode without writing index")
    parser.add_argument("--allow-fallback", action="store_true", help="Allow fallback verification when canonical knowledge-builder is unavailable")
    parser.add_argument("--knowledge-builder-src", type=Path,
                        help="Canonical knowledge-builder src directory (or UKMC_KNOWLEDGE_BUILDER_SRC)")
    args = parser.parse_args()
    load_canonical_contract(args.knowledge_builder_src)

    repo_root = Path(__file__).resolve().parent.parent
    errors = verify_corpus_and_units(repo_root, check_only=args.check, allow_fallback=args.allow_fallback)

    if errors:
        print(f"\n[-] Strict verification FAILED with {len(errors)} error(s):")
        for e in errors:
            print(f"    - {e}")
        sys.exit(1)
    else:
        if HAS_CANONICAL_BUILDER:
            print("\n[✓] ALL CHECKS PASSED: Canonical contract and local provenance validation succeeded.")
        else:
            print("\n[✓] LOCAL CHECKS PASSED: Canonical contract validation NOT VERIFIED (--allow-fallback).")


if __name__ == "__main__":
    main()
