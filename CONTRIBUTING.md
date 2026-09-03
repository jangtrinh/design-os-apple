# Contributing

Apple Design OS welcomes focused fixes and additions that keep native SwiftUI behavior at
the call site.

## Before changing code

1. Search the runtime, DocC recipes, Gallery, and tests for an existing semantic contract.
2. State the user-visible outcome, platform scope, and behavior that must remain native.
3. Add or update a focused test at the owning public seam.
4. Keep design intent in `design/` and runtime behavior in `Sources/DesignOSApple/`.

Do not hand-edit `design/design.tokens.json`. Maintainers change sealed tokens through a
sanctioned `ui ds` command. Contributors consuming the package do not need DESIGN:OS.

## Verify

Run the narrowest affected test first. The release gate needs Xcode, [XcodeGen](https://github.com/yonaskolb/XcodeGen),
and [ripgrep](https://github.com/BurntSushi/ripgrep) (`brew install xcodegen ripgrep`). Before a pull request, run:

```bash
scripts/verify-release-candidate.sh
```

If a manual device, accessibility, visual, or owner gate was not run, state `NOT VERIFIED`.
Do not describe package or simulator success as proof of those gates.

## Pull requests

Keep one coherent public contract per pull request. Explain the behavior, tests, platform
differences, documentation impact, and unresolved evidence. Do not add Apple-owned design
assets, fonts, symbols, screenshots, or copied reference material without documented rights.
Follow the [Code of Conduct](CODE_OF_CONDUCT.md) and use the [Security Policy](SECURITY.md)
for sensitive reports.

Changes driven by a new Apple SDK must also follow the
[Apple platform evolution policy](docs/apple-platform-evolution.md); beta discovery alone
does not authorize a support-floor or public-contract change.
