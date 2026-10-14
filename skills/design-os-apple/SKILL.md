---
name: design-os-apple
description: "Use when working with Apple Design OS — Native Swift 6.2 & SwiftUI component system, adaptive color engine, and multi-platform specimen verifier for iOS 26, iPadOS 26, and macOS 26."
---

# Apple Design OS (`design-os-apple`)

Ship HIG-compliant SwiftUI interfaces with semantic tokens (`DesignOSAdaptiveColor`), Liquid Glass & tactile depth, Dynamic Type safety, and automated simulator specimen verification.

## When to Use

Activate this skill when the user asks to:
- `"Build a native SwiftUI settings and telemetry screen using DesignOSApple semantic tokens, 44pt minimum hit targets, and Dynamic Type."`
- `"Audit our SwiftUI views against the Apple HIG gate for hardcoded colors, missing accessibility labels, and Reduce Motion fallbacks."`
- `"Run the portable contract verifiers for quickstart parity, app style registry, and layered UI-kit specimens."`

## Progressive Disclosure Routing (`What loads when`)

1. **Always Loaded**: `skills/design-os-apple/SKILL.md` (this router — keeps context lean).
2. **On Demand — Prompt Recipes**: Load `docs/cookbook.md` when selecting multi-step workflows or copy-paste prompt templates.
3. **On Demand — Diagnostics**: Load `commands/doctor.md` or run `python3 scripts/self_check.py` when verifying installation or troubleshooting.
4. **On Demand — Ecosystem Discovery**: Load `llms.txt` when cross-referencing companion `DESIGN:OS` engines.

## Core Execution Workflow

1. **Inspect Context**: Read the target repository or workspace constraints before mutating files.
2. **Execute Deterministically**: Run `python3 scripts/verify-quickstart-parity.py && python3 scripts/verify-layered-kit.py` or `python3 scripts/verify-quickstart-parity.py` rather than guessing outputs freehand.
3. **Verify Quality Gates**: Run `python3 scripts/self_check.py` and confirm zero errors before reporting completion.

## Quality Bar & Anti-Scope

### It's working if...
- `python3 scripts/self_check.py` exits `0`.
- Outputs match the `DESIGN:OS` 2:1 axonometric B&W art direction and deterministic verification gates.
- Execution remains 100% local with zero external telemetry (`PRIVACY.md`).

### When NOT to use
- Cross-platform React Native, Flutter, or web-only applications (use `design-os` or `design-os-generative-ui`).
- Legacy UIKit/AppKit codebases targeting iOS versions below the SwiftUI 6 deployment baseline.
- Low-level Metal game engines with no standard HIG control surfaces.
