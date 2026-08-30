# AI Usage

Use this route when an AI coding agent builds an Apple-platform interface with Apple Design
OS. The goal is resolvable source authority, not a larger prompt.

## Read in this order

1. [`CONTEXT.md`](../CONTEXT.md) for canonical project terms.
2. [`Package.swift`](../Package.swift) for products and supported platforms.
3. The [DocC landing page](../Sources/DesignOSApple/DesignOSApple.docc/DesignOSApple.md) for
   public runtime concepts and native recipes.
4. The [typed release catalog authority](../Sources/DesignOSAppleCatalog/DesignOSReleaseCatalog.swift)
   for admitted Gallery metadata.
5. The [catalog bundle](../Examples/DesignOSAppleGallery/Generated/design-os-apple-catalog-bundle.v1.json)
   when machine-readable story discovery is needed.
6. [Apple Platform Evolution](apple-platform-evolution.md) before adopting a newly released
   or beta SDK capability.

Validate the machine projection before trusting it:

```bash
scripts/verify-catalog-bundle.sh
```

`DesignOSPilotCatalog` is a frozen six-story dogfood evidence boundary. Do not use it to
infer the complete runtime or Gallery inventory.

## Generation rules

- Prefer native SwiftUI controls, containers, modifiers, and platform behavior.
- Use a library component only when its public semantic contract matches the need.
- Use a profile only for axes consumed by the runtime. Keep app state and native interaction
  at the call site.
- Treat the Gallery as executable implementation evidence, not Apple HIG authority or a
  blanket visual specification.
- Do not infer catalog admission, ownership, or availability from filenames. Resolve the
  typed authority and checked bundle.

Package consumption must not invoke `ui`, read local plans, or depend on `.brv`, `.agentkit`,
raw Figma operations, or maintainer evidence. Those are workflow inputs, not runtime APIs.

Before proposing a completed change, run the narrow gate for the touched contract and then
`scripts/verify-release-candidate.sh`. Report deterministic results separately from manual
device/accessibility, independent-review, and owner-acceptance results.
