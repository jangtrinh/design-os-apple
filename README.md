# DESIGN:OS Apple (`design-os-apple`)

**Native Swift 6.2 & SwiftUI component system, adaptive color engine, and multi-platform specimen verifier for iOS 26, iPadOS 26, and macOS 26.**

Ship HIG-compliant SwiftUI interfaces with semantic tokens (`DesignOSAdaptiveColor`), Liquid Glass & tactile depth, Dynamic Type safety, and automated simulator specimen verification.

<p align="center">
  <img src="docs/images/cover.png" alt="Apple Design OS — 2:1 Axonometric Technical Architecture" width="840">
</p>

<p align="center">
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-PolyForm_Shield_1.0.0-202020?style=flat-square&labelColor=202020&color=444444" alt="PolyForm Shield 1.0.0 License"></a>
  <img src="https://img.shields.io/badge/Claude_Code_%C2%B7_Codex_%C2%B7_Gemini_%C2%B7_Antigravity-skill-202020?style=flat-square&labelColor=202020&color=444444" alt="Compatible agents">
  <a href="commands/doctor.md"><img src="https://img.shields.io/badge/diagnostics-%2Fdoctor-202020?style=flat-square&labelColor=202020&color=444444" alt="Doctor command"></a>
  <a href="https://jangtrinh.github.io/design-os-apple/"><img src="https://img.shields.io/badge/live_docs-GitHub_Pages-202020?style=flat-square&labelColor=202020&color=444444" alt="Live GitHub Pages"></a>
  <a href="https://buymeacoffee.com/jangtrinh"><img src="https://img.shields.io/badge/Buy_Me_a_Coffee-FFDD00?style=flat-square&logo=buy-me-a-coffee&logoColor=black" alt="Buy Me a Coffee"></a>
</p>

<p align="center">
  <a href="#quickstart">Quickstart</a> · <a href="#what-it-makes">What it makes</a> · <a href="#installation">Install</a> · <a href="#how-it-works">How it works</a> · <a href="#commands--diagnostics">Commands</a> · <a href="#quality-bar--limitations">Limits</a>
</p>

---

## Why this exists

AI agents writing SwiftUI frequently hallucinate deprecated modifiers, hardcode hex colors that break in Dark Mode, ignore 44×44pt hit targets, and fail Swift 6 strict concurrency checks. **`design-os-apple`** provides a Swift 6.2 package (`DesignOSApple`) paired with portable Python/Node contract verifiers and native Xcode simulator gates.

| Dimension | Generic AI / Manual Workflow | Apple Design OS (`DESIGN:OS`) |
| :--- | :--- | :--- |
| **Swift 6 Concurrency** | Data-race warnings and `@MainActor` compiler errors | Strict Swift 6.2 concurrency compliance out of the box |
| **Color & Dark Mode** | Hardcoded `Color(hex:)` values that break high-contrast and Dark Mode | Semantic `DesignOSAdaptiveColor` tokens verified across light/dark appearances |
| **Accessibility & HIG** | Tiny tap targets (<44pt) and missing VoiceOver labels | Enforced >=44pt hit targets, Dynamic Type scaling, and Reduce Motion support |
| **Documentation Parity** | README Swift snippets that no longer compile against the library | Automated `verify-quickstart-parity.py` + native `swiftc` typecheck in CI |
| **Privacy & Telemetry** | Opaque cloud telemetry or unverified third-party APIs | **Zero telemetry** — 100% local execution ([`PRIVACY.md`](PRIVACY.md) audited) |

---

## Quickstart

### 1. Install the plugin or CLI

**In Claude Code:**

```text
/plugin marketplace add jangtrinh/design-os-apple
/plugin install design-os-apple@design-os-apple
```

**Or from your terminal (Codex, Gemini CLI, Antigravity, OpenCode, or standalone CLI):**

```bash
git clone https://github.com/jangtrinh/design-os-apple.git
cd design-os-apple
python3 scripts/verify-quickstart-parity.py && python3 scripts/verify-layered-kit.py
```

### 2. Ask in plain English

Open your project in your AI coding agent and describe what you need:

> "Build a native SwiftUI settings and telemetry screen using DesignOSApple semantic tokens, 44pt minimum hit targets, and Dynamic Type."

> "Audit our SwiftUI views against the Apple HIG gate for hardcoded colors, missing accessibility labels, and Reduce Motion fallbacks."

> "Run the portable contract verifiers for quickstart parity, app style registry, and layered UI-kit specimens."

### 3. Verify your setup

```bash
python3 scripts/self_check.py
```

---

## What it makes

Every deliverable produced by `design-os-apple` is backed by a deterministic verification gate rather than freehand AI guesswork.

<p align="center">
  <img src="docs/images/cover.png" alt="Apple Design OS Output Specimen" width="840"><br>
  <sub>Prompt: <code>"Build a native SwiftUI settings and telemetry screen using DesignOSApple semantic tokens, 44pt minimum hit targets, and Dynamic Type."</code></sub>
</p>

| Deliverable / Mode | Best for | Output Format | Verification Gate |
| :--- | :--- | :--- | :--- |
| **`DesignOSApple` Swift Package** | Drop-in SwiftUI tokens, fields, cards, shells, and adaptive colors | `Package.swift + Sources/DesignOSApple` | `swift test & verify-release-candidate.sh` |
| **CalorieCam Reference App** | End-to-end iOS/iPadOS/macOS reference app + local Node analysis server | `Examples/CalorieCam` | `scripts/verify-caloriecam.sh` |
| **Portable Contract Verifiers** | Fast Linux/macOS CI checks for quickstart parity, style registry, and specimens | `scripts/verify-*.py` | `Zero drift between code and docs` |

---

## Installation

Choose the setup that matches your AI coding agent. Every option installs the same canonical skill (`skills/design-os-apple/SKILL.md`) and `/doctor` diagnostic suite.

### Claude Code

Run these two commands inside Claude Code:

```text
/plugin marketplace add jangtrinh/design-os-apple
/plugin install design-os-apple@design-os-apple
```

### OpenAI Codex

Install to your personal Codex skills directory:

```bash
git clone https://github.com/jangtrinh/design-os-apple.git /tmp/design-os-apple
mkdir -p ~/.codex/skills/design-os-apple ~/.codex/prompts
cp -R /tmp/design-os-apple/skills/design-os-apple/* ~/.codex/skills/design-os-apple/
cp /tmp/design-os-apple/prompts/doctor.md ~/.codex/prompts/design-os-apple-doctor.md
rm -rf /tmp/design-os-apple
```

### Gemini CLI & Google Antigravity

```bash
git clone https://github.com/jangtrinh/design-os-apple.git /tmp/design-os-apple
mkdir -p ~/.gemini/skills/design-os-apple
cp -R /tmp/design-os-apple/skills/design-os-apple/* ~/.gemini/skills/design-os-apple/
rm -rf /tmp/design-os-apple
```

### OpenCode, Cursor, Windsurf & Other Agent Harnesses

```bash
git clone https://github.com/jangtrinh/design-os-apple.git /tmp/design-os-apple
mkdir -p ~/.agents/skills/design-os-apple
cp -R /tmp/design-os-apple/skills/design-os-apple/* ~/.agents/skills/design-os-apple/
rm -rf /tmp/design-os-apple
```

<details>
<summary>Verify or uninstall</summary>

**Verify installation:**

```bash
python3 scripts/self_check.py
```

Or run `/doctor` inside Claude Code / Codex to inspect installed skill paths, plugin manifests, and gate health.

**Uninstall:**

```bash
rm -rf ~/.claude/skills/design-os-apple ~/.codex/skills/design-os-apple ~/.gemini/skills/design-os-apple ~/.agents/skills/design-os-apple
```

</details>

---

## Usage & Prompt Cookbook

Once installed, `skills/design-os-apple/SKILL.md` activates automatically when your prompt matches its domain triggers. Browse [`docs/cookbook.md`](docs/cookbook.md) for copy-paste prompt recipes.

**Generate & Scaffold**

```text
"Build a native SwiftUI settings and telemetry screen using DesignOSApple semantic tokens, 44pt minimum hit targets, and Dynamic Type."
```

**Audit & Verify**

```text
"Audit our SwiftUI views against the Apple HIG gate for hardcoded colors, missing accessibility labels, and Reduce Motion fallbacks."
```

**Export & Automate**

```text
"Run the portable contract verifiers for quickstart parity, app style registry, and layered UI-kit specimens."
```

---

## Commands & Diagnostics

| Command | Environment | What it does |
| :--- | :--- | :--- |
| `/doctor` | Claude Code / Codex | Read-only diagnostic check of installed skill paths, plugin manifests, and runtime prerequisites |
| `python3 scripts/self_check.py` | Terminal / CI | Deterministic offline verification of manifests, skill contracts, and governance files |
| `python3 scripts/verify-quickstart-parity.py` | Terminal / CI | Verify that published Swift quickstart examples in docs and HTML remain 100% byte-identical and type-safe |

---

## How it works

1. **Intent Routing** — Your AI agent matches your request against `skills/design-os-apple/SKILL.md` frontmatter triggers.
2. **Progressive Context Loading** — Only the entry-point `SKILL.md` router loads initially; detailed recipes and scripts load on demand.
3. **Deterministic Execution** — Domain scripts and contracts execute locally with reproducible inputs and outputs.
4. **Gate Verification** — `scripts/self_check.py` and domain verifiers (`python3 scripts/verify-quickstart-parity.py && python3 scripts/verify-layered-kit.py`) validate the artifact before completion.
5. **Zero-Telemetry Delivery** — Verified files are written directly to your workspace with zero external network calls.

```text
User Prompt / CLI Invocation
            │
            ▼
┌───────────────────────────────────────────────┐
│ skills/design-os-apple/SKILL.md
│ Progressive disclosure router & hard rules    │
└───────────┬───────────────────────────────────┘
            │ loads on demand
            ▼
┌───────────────────────────────────────────────┐
│ python3 scripts/verify-quickstart-parity.py
│ Deterministic build & contract enforcement    │
└───────────┬───────────────────────────────────┘
            │ verifies
            ▼
┌───────────────────────────────────────────────┐
│ python3 scripts/self_check.py + /doctor       │
│ Zero-telemetry local verification gate        │
└───────────────────────────────────────────────┘
```

### What loads when

`design-os-apple` uses progressive context disclosure so your agent's context window stays fast and focused:

| File | Loaded when |
| :--- | :--- |
| `skills/design-os-apple/SKILL.md` | Always (~100–150 lines) — routing rules, triggers, and execution workflow |
| `docs/cookbook.md` | When selecting multi-step prompt recipes or domain patterns |
| `commands/doctor.md` / `prompts/doctor.md` | Only when running `/doctor` diagnostics |
| `llms.txt` | When indexed by AI answer engines, RAG pipelines, or repo crawlers |

---

## File structure

```text
design-os-apple/
├── .claude-plugin/
│   ├── plugin.json                 # Claude Code plugin manifest
│   └── marketplace.json            # Claude Code marketplace catalog
├── .codex-plugin/
│   └── plugin.json                 # OpenAI Codex plugin & interface manifest
├── .agents/
│   └── plugins/marketplace.json    # Cross-agent local plugin registry
├── .factory-plugin/
│   ├── plugin.json                 # Factory / Droid plugin manifest
│   └── marketplace.json            # Factory marketplace metadata
├── skills/
│   └── design-os-apple/
│       └── SKILL.md                # Canonical agent skill entrypoint
├── commands/
│   └── doctor.md                   # /doctor diagnostic slash command
├── prompts/
│   └── doctor.md                   # Codex diagnostic prompt mirror
├── scripts/
│   └── self_check.py               # Deterministic repository & skill self-check
├── docs/
│   ├── cookbook.md                 # Copy-paste prompt recipes by job
│   └── llms.txt                    # GEO / LLM discovery index
├── PRIVACY.md                      # Zero-telemetry & local-first privacy commitment
├── SECURITY.md                     # Vulnerability disclosure & security policy
├── CONTRIBUTING.md                 # Contribution workflow & verification rules
├── CODE_OF_CONDUCT.md              # Contributor Covenant code of conduct
├── CHANGELOG.md                    # Release history
├── llms.txt                        # Root LLM indexing manifest
├── LICENSE                         # PolyForm Shield 1.0.0
└── README.md
```

---

## Quality bar & Limitations

### It's working if...

- `python3 scripts/self_check.py` prints `ok: design-os-apple self-check passed (design-os-apple)` and exits `0`.
- `python3 scripts/verify-quickstart-parity.py && python3 scripts/verify-layered-kit.py` passes with zero contract or test regressions.
- Your AI coding agent loads `skills/design-os-apple/SKILL.md` automatically when given any prompt from [`docs/cookbook.md`](docs/cookbook.md).
- Network traffic during execution remains zero (guaranteed by [`PRIVACY.md`](PRIVACY.md)).

### When not to use

- Cross-platform React Native, Flutter, or web-only applications (use `design-os` or `design-os-generative-ui`).
- Legacy UIKit/AppKit codebases targeting iOS versions below the SwiftUI 6 deployment baseline.
- Low-level Metal game engines with no standard HIG control surfaces.

---

## DESIGN:OS Ecosystem

`design-os-apple` is one of the 13 source-available engines in the **`DESIGN:OS`** ecosystem:

| Engine | Live Docs | Repository | Layer |
| :--- | :--- | :--- | :--- |
| **DESIGN:OS CLI** | [jangtrinh.github.io/design-os](https://jangtrinh.github.io/design-os/) | [`jangtrinh/design-os`](https://github.com/jangtrinh/design-os) | `cli` |
| **Knowledge Builder** | [jangtrinh.github.io/design-os-knowledge-builder](https://jangtrinh.github.io/design-os-knowledge-builder/) | [`jangtrinh/design-os-knowledge-builder`](https://github.com/jangtrinh/design-os-knowledge-builder) | `compiler` |
| **Figma Plugin & CLI** | [jangtrinh.github.io/design-os-figma-plugin](https://jangtrinh.github.io/design-os-figma-plugin/) | [`jangtrinh/design-os-figma-plugin`](https://github.com/jangtrinh/design-os-figma-plugin) | `plugin` |
| **SVG Animation Engine** | [jangtrinh.github.io/design-os-svg-animation](https://jangtrinh.github.io/design-os-svg-animation/) | [`jangtrinh/design-os-svg-animation`](https://github.com/jangtrinh/design-os-svg-animation) | `engine` |
| **3D Blender Agent** | [jangtrinh.github.io/design-os-3d-blender](https://jangtrinh.github.io/design-os-3d-blender/) | [`jangtrinh/design-os-3d-blender`](https://github.com/jangtrinh/design-os-3d-blender) | `3d / cad` |
| **OPAH ONE Drone** | [jangtrinh.github.io/design-os-drone-showcase](https://jangtrinh.github.io/design-os-drone-showcase/) | [`jangtrinh/design-os-drone-showcase`](https://github.com/jangtrinh/design-os-drone-showcase) | `hardware` |
| **GitHub Pages Engine** | [jangtrinh.github.io/design-os-github-page](https://jangtrinh.github.io/design-os-github-page/) | [`jangtrinh/design-os-github-page`](https://github.com/jangtrinh/design-os-github-page) | `pages` |
| **Apple Design OS** | [jangtrinh.github.io/design-os-apple](https://jangtrinh.github.io/design-os-apple/) | [`jangtrinh/design-os-apple`](https://github.com/jangtrinh/design-os-apple) | `swiftui` |
| **Agent Teacher** | [jangtrinh.github.io/design-os-pedagogy](https://jangtrinh.github.io/design-os-pedagogy/) | [`jangtrinh/design-os-pedagogy`](https://github.com/jangtrinh/design-os-pedagogy) | `pedagogy` |
| **Origami CAD** | [jangtrinh.github.io/design-os-origami](https://jangtrinh.github.io/design-os-origami/) | [`jangtrinh/design-os-origami`](https://github.com/jangtrinh/design-os-origami) | `packaging` |
| **Voice UX Architecture** | [jangtrinh.github.io/design-os-voice-ux](https://jangtrinh.github.io/design-os-voice-ux/) | [`jangtrinh/design-os-voice-ux`](https://github.com/jangtrinh/design-os-voice-ux) | `voice-ai` |
| **Code2Flow** | [jangtrinh.github.io/design-os-code2flow](https://jangtrinh.github.io/design-os-code2flow/) | [`jangtrinh/design-os-code2flow`](https://github.com/jangtrinh/design-os-code2flow) | `ast / audit` |
| **Generative UI** | [jangtrinh.github.io/design-os-generative-ui](https://jangtrinh.github.io/design-os-generative-ui/) | [`jangtrinh/design-os-generative-ui`](https://github.com/jangtrinh/design-os-generative-ui) | `runtime` |

---

## Contributing, Governance & License

- **Contributing**: See [`CONTRIBUTING.md`](CONTRIBUTING.md) for pull request guidelines and verification gates (`python3 scripts/self_check.py`).
- **Code of Conduct**: Governed by [`CODE_OF_CONDUCT.md`](CODE_OF_CONDUCT.md).
- **Security & Privacy**: Zero telemetry — see [`SECURITY.md`](SECURITY.md) and [`PRIVACY.md`](PRIVACY.md).
- **Changelog & LLM Index**: Track releases in [`CHANGELOG.md`](CHANGELOG.md) and machine-readable index in [`llms.txt`](llms.txt).
- **License**: [PolyForm Shield 1.0.0](LICENSE) © [Jang Trinh](https://github.com/jangtrinh). Free to use and modify, including for paid client work; you may not resell it or build a competing product from it.

---

If `design-os-apple` saves you time, a star on GitHub helps other engineers and AI agents find it.

<p align="left">
  <a href="https://buymeacoffee.com/jangtrinh">
    <img src="https://img.shields.io/badge/Buy_Me_a_Coffee-FFDD00?style=for-the-badge&logo=buy-me-a-coffee&logoColor=black" alt="Buy Me a Coffee">
  </a>
</p>
