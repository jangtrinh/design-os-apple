# `design-os-apple` Prompt & CLI Cookbook

Copy-paste recipes for **Apple Design OS** (`skills/design-os-apple/SKILL.md`).

---

## 1. Generate & Scaffold

> "Build a native SwiftUI settings and telemetry screen using DesignOSApple semantic tokens, 44pt minimum hit targets, and Dynamic Type."

## 2. Audit & Verify

> "Audit our SwiftUI views against the Apple HIG gate for hardcoded colors, missing accessibility labels, and Reduce Motion fallbacks."

## 3. Export & Automate

> "Run the portable contract verifiers for quickstart parity, app style registry, and layered UI-kit specimens."

---

## 4. CLI & Diagnostic Commands

```bash
# Run deterministic offline self-check
python3 scripts/self_check.py

# Run primary domain verification / workflow
python3 scripts/verify-quickstart-parity.py && python3 scripts/verify-layered-kit.py

# Run primary CLI command
python3 scripts/verify-quickstart-parity.py
```
