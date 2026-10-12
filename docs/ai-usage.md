# AI Usage

Use this route when an AI coding agent builds an Apple-platform interface with Apple Design
OS. The goal is resolvable source authority, not a larger prompt.

## Read in this order

1. [`CONTEXT.md`](https://github.com/jangtrinh/design-os-apple/blob/c8eb91b52820e09310c240e3e7849fd63cdab856/CONTEXT.md) for canonical project terms.
2. [`Package.swift`](https://github.com/jangtrinh/design-os-apple/blob/c8eb91b52820e09310c240e3e7849fd63cdab856/Package.swift) for products and supported platforms.
3. The [DocC landing page](https://github.com/jangtrinh/design-os-apple/blob/c8eb91b52820e09310c240e3e7849fd63cdab856/Sources/DesignOSApple/DesignOSApple.docc/DesignOSApple.md) for
   public runtime concepts and native recipes.
4. The [typed release catalog authority](https://github.com/jangtrinh/design-os-apple/blob/c8eb91b52820e09310c240e3e7849fd63cdab856/Sources/DesignOSAppleCatalog/DesignOSReleaseCatalog.swift)
   for admitted Gallery metadata.
5. The [catalog bundle](https://github.com/jangtrinh/design-os-apple/blob/c8eb91b52820e09310c240e3e7849fd63cdab856/Examples/DesignOSAppleGallery/Generated/design-os-apple-catalog-bundle.v2.json)
   when machine-readable story discovery is needed.
6. [Apple Platform Evolution](apple-platform-evolution.md) before adopting a newly released
   or beta SDK capability.

For product-shaped composition examples, inspect the Gallery's
[`localOnly` demo manifest](https://github.com/jangtrinh/design-os-apple/blob/c8eb91b52820e09310c240e3e7849fd63cdab856/Examples/DesignOSAppleGallery/Generated/local-demo-catalog.v2.json)
and then read the referenced app-owned views under `App/Shared/Flows`. Reuse their native
SwiftUI arrangement and state patterns only. Do not treat demo IDs, views, fixtures, or
visual choices as public runtime APIs.

Validate that projection before trusting its identity, source, or asset sets:

```bash
node scripts/verify-local-demo-catalog.mjs --root .
```

Validate the machine projection before trusting it:

```bash
scripts/verify-catalog-bundle.sh
```

`DesignOSPilotCatalog` is a frozen five-story dogfood evidence boundary. Do not use it to
infer the complete runtime or Gallery inventory.

## Resolve a remembered keyword

Treat `DesignOSStoryID` as permanent machine identity. Resolve a user's phrase through
`DesignOSReleaseCatalog.resolve(_:)`, which checks exact story ID, exact primary keyword, then an
exact alias. Unknown or ambiguous terms fail closed; fuzzy catalog search is never callable
authority.

```swift
let story = try DesignOSReleaseCatalog.resolve("list row")
// story.id == .listRow
```

Read `story.relationship` before generating code. A canonical runtime story may name a public
component or a direct native recipe. An app-owned example teaches composition only and must not be
presented as package API. Use `story.discovery.primaryKeyword` for the quiet user-facing recall key;
do not maintain separate per-story prompt templates.

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
