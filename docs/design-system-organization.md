# Design-system organization

This package follows the separation of design authority, reusable implementation, product
composition, and verification in [DESIGN:OS at `0c6210d`](https://github.com/jangtrinh/design-os/tree/0c6210d102ed0e20d58d3218309dc83b90199c13).
The mapping is native SwiftUI; it does not introduce a web runtime or require package
consumers to install the DESIGN:OS CLI.

## Authority and ownership

Use this order when reference styling and native behavior disagree:

1. Apple platform APIs, accessibility settings, and current system behavior
2. The product's content, tasks, interaction contract, and authorized visual reference
3. This package's design roles, reusable components, and retained evidence
4. A particular implementation or screenshot measurement

This follows upstream [Apple SwiftUI craft](https://github.com/jangtrinh/design-os/blob/0c6210d102ed0e20d58d3218309dc83b90199c13/knowledge/apple-swiftui-craft.md).
The Luma reference informs the opt-in editorial language. It does not override native
navigation, keyboard behavior, accessible contrast, or system-owned controls. Measured
pixels and inferred point values stay distinguished in the [reference study](luma-style-reference.md).

There are three different authorities, each with a bounded job:

- **Management intent:** `design/design.tokens.json`, `design/component-registry.json`,
  and `design/ds.manifest.json` form the existing sealed DESIGN:OS store. Do not hand-edit
  or reseal it to make this application-style addition appear registered. The Liquid
  Glass persona is historical management intent, not an instruction to turn the
  editorial flat feed into translucent cards.
- **Runtime:** Swift declarations in `Sources/DesignOSApple/` own the actual public
  API, resolved colors, spacing, behavior, and platform support. The editorial preset's
  values are authored here; a documentation index must reference them, not create a
  second token-value source.
- **Release discovery:** `DesignOSReleaseCatalog` owns the existing release stories.
  Generated catalog bundles are projections. An app-style index, a demo, or a screenshot
  does not admit new release stories or change existing catalog IDs.

Upstream verifies its management triplet together in
[`design-system.ts`](https://github.com/jangtrinh/design-os/blob/0c6210d102ed0e20d58d3218309dc83b90199c13/src/core/design-system.ts),
with canonical hashes and generation history defined in
[`ds-manifest.ts`](https://github.com/jangtrinh/design-os/blob/0c6210d102ed0e20d58d3218309dc83b90199c13/src/core/ds-manifest.ts).
That integrity check cannot establish Swift runtime or visual correctness.

## Current native layers

| Layer | Existing location | Owns | Must not own |
| --- | --- | --- | --- |
| Platform semantics | `Sources/DesignOSApple/Tokens/` | Native color, type, and surface roles | An app's palette or navigation |
| Typed runtime policy | `Sources/DesignOSApple/Profile/` | Validated semantic typography, spacing, radii, accessibility policy | App data, persisted selection, camera state |
| Application language | `Sources/DesignOSApple/AppStyle/` | `DesignOSAppStyle`, adaptive palette, metrics, the `.editorial` preset, environment injection | Network requests, assets, business logic |
| Reusable content | `Sources/DesignOSApple/Components/` | Media rows, headings, surfaces, decorative backdrop, native button appearance | Gestures or navigation that replace caller-owned native controls |
| Implementation details | `Sources/DesignOSApple/Primitives/` | Internal layout and symbol composition | A competing app-level design system |
| Native recipes | `Sources/DesignOSApple/Recipes/` and DocC | How to compose system APIs and their fallbacks | Wrappers around every SwiftUI control |
| Product dogfood | `Examples/CalorieCam/` | Meal data, route state, editing, consent, capture, persistence, app-owned media | Duplicated package components or style constants |
| Discovery and teaching | `Sources/DesignOSAppleCatalog/`, DocC, `docs/` | API guidance, ownership, availability, source pointers, examples | Independent runtime definitions |
| Verification | `Tests/`, `scripts/`, native result artifacts | Explicitly scoped checks and evidence | Inferred visual or owner approval |

`DesignOSProfile` is the base native design policy. `DesignOSAppStyle` composes that
profile with app-owned content appearance; it is not a replacement profile hierarchy.
Upstream's **capability profiles** are a different concept: they route work to web,
iOS, iPadOS, or macOS and declare required evidence. Do not copy those routing profiles
into the runtime theme API.

## Reuse from another app

Import the existing `DesignOSApple` product, apply `.designOSAppStyle(.editorial)` at a
product subtree, and compose with native `Button`, `NavigationLink`, `List`, `Form`,
navigation stacks, toolbars, and presentations.

The shared reusable inventory is:

- `DesignOSMediaRow`: flat media-plus-label composition, with accessibility-size reflow
- `DesignOSAppSectionHeader`: semantic heading with a caller-owned accessory
- `DesignOSAppSurface`: opaque standard/subtle content grouping
- `DesignOSPrimaryButtonStyle`: appearance for a real native `Button`
- `DesignOSMediaBackdrop`: decorative, image-derived background with opaque fallbacks

The [adoption guide](reusable-app-style.md) contains complete call sites and constraints.
CalorieCam supplies meal-specific labels, actions, photos, analysis, and persistence.
Neither the shared kit nor its metadata should import the CalorieCam module. A new
product should be able to use these components without copying any CalorieCam source.

## Native work loop

1. **Discover:** Read the relevant runtime declarations, component usage guidance,
   reference provenance, existing native recipes, and applicable state requirements.
   Read the full relevant inventory, not a truncated catalog preview.
2. **Specify:** Name the task, platforms, screen states, owner of navigation/focus/data,
   and what the visual reference actually demonstrates. Unseen interactions and inferred
   measurements remain assumptions.
3. **Compose:** Reuse the shared components and style roles. Keep content and behavior
   native. Make only product-specific composition in CalorieCam.
4. **Check:** Run portable metadata checks separately from Apple compilation, unit
   tests, strict release build, format, DocC, and app UI tests. A structural pass is
   not a native pass.
5. **Collect:** Retain logs and screenshots from the exact implementation revision and
   platform. Include state, appearance, container size, Dynamic Type, accessibility
   settings, and test command. Screenshot files are evidence, not new runtime assets.
6. **Review:** Compare native captures with the authorized reference and product task.
   Record implementation errors separately from intentional native adaptations. Keep
   independent review and owner acceptance separate from the implementer's checks.
7. **Deliver:** Report only the evidence obtained. A changed source or capture requires
   fresh checks at the affected tier; an earlier screenshot verdict does not transfer.

The relevant upstream workflows are
[`native-ios`](https://github.com/jangtrinh/design-os/blob/0c6210d102ed0e20d58d3218309dc83b90199c13/templates/workflows/native-ios.md),
[`native-ipados`](https://github.com/jangtrinh/design-os/blob/0c6210d102ed0e20d58d3218309dc83b90199c13/templates/workflows/native-ipados.md),
and [`native-macos`](https://github.com/jangtrinh/design-os/blob/0c6210d102ed0e20d58d3218309dc83b90199c13/templates/workflows/native-macos.md).
Those arms are provisional at the pinned revision. Reading their workflow is not a
claim that an activation receipt was produced or their evidence gates were executed.

### Checks already available here

- `scripts/verify-swift-package.sh`: package tests, strict release build, Swift formatting
- `scripts/verify-caloriecam.sh`: product-core tests and iPhone/iPad/macOS UI tests;
  retains result bundles and attempts attachment export
- `scripts/verify-release-candidate.sh`: existing package release gate, including
  documentation, catalog drift, publication boundary, and Gallery checks

Run Apple commands on an actual supported Apple toolchain. Do not turn a Linux text
inspection into a successful SwiftUI build result. These commands still do not imply
live camera, real photo recognition, manual VoiceOver, pixel fidelity, or owner acceptance.
See [Quality Evidence](quality-evidence.md).

### Required component and product states

Describe requirements independently from their verification status:

- Every style: light/dark, increased contrast, normal/accessibility Dynamic Type
- Media rows and headings: long labels and structural reflow without lost content
- Primary action: enabled, pressed, disabled, keyboard focus, pointer hover, multiline label
- Backdrop: photo/no photo, dark/light, Reduce Transparency, increased contrast,
  profile `opaqueOnly`, and no motion-dependent information
- Product: loading, empty, error, recovery, editing/keyboard, cancel/back, saved data,
  consent granted/declined, compact/expanded layouts, and interrupted/repeated actions

For each claimed result, bind evidence to the source revision and actual state. Keep
deterministic checks, native rendering, structural accessibility, live assistive
technology/hardware, independent review, and owner acceptance distinct. The upstream
[native proof schema](https://github.com/jangtrinh/design-os/blob/0c6210d102ed0e20d58d3218309dc83b90199c13/schemas/native-mobile-proof-manifest.schema.json)
illustrates subject-bound evidence and explicit pending states; its pilot-specific
screen counts and platform list are not a schema to copy blindly into this app.

## Minimal integration gap

The existing sealed management registry is empty, while the Swift runtime has real
components. That does not make the components unavailable, but it leaves their new
app-style grouping undiscoverable to tools that only read that registry. The frozen
release catalog must not be silently expanded as a workaround.

The additive [editorial app-style index](app-styles/editorial/manifest.json) closes this
discovery gap with stable IDs, Swift module/symbol/source references, usage documentation,
variant and state requirements, ownership boundaries, and verification commands. Swift
source remains authoritative; the index stores no copied color/spacing values and no pass
statuses. All paths in the index are relative to the repository root. Component IDs are
scoped to the style ID, so `editorial/media-row` is an unambiguous discovery key.

The v1 contract is enforced by
[`verify-app-style-registry.py`](../scripts/verify-app-style-registry.py). It requires the
runtime entry points, all five currently app-style-consuming components, their usage
guidance and compiling specimen references, native command paths, six evidence tiers,
and explicit non-membership in the sealed registry and release catalog. The inventory
check discovers top-level public component declarations in source files using the style
environment. This is a lexical drift guard, not a Swift parser or build result.

```bash
python3 scripts/verify-app-style-registry.py
python3 scripts/test-app-style-registry.py
```

The portable regression suite checks invalid paths, duplicate or missing IDs, drifted
symbols and call sites, missing documentation, incomplete inventories, absent required
states, and false authority/verification fields. These scripts never execute the native
commands listed in the index. Adding a future style uses a sibling directory and the
validator's `--manifest docs/app-styles/<style-id>/manifest.json` option; it must describe
the actual runtime preset and complete reusable app-style component inventory.

The index is a native discovery projection, not an upstream sealed registry, kit lock,
catalog admission, or readiness receipt. Any future promotion into the managed registry
needs a deliberate native record contract and sanctioned reseal. Adding it to the typed
release catalog is a separate reviewed change with its normal drift checks.

## What not to import

- Upstream [`generate`](https://github.com/jangtrinh/design-os/blob/0c6210d102ed0e20d58d3218309dc83b90199c13/templates/workflows/generate.md)
  is the qualified **web-marketing HTML** route, not the native SwiftUI implementation path.
- Its [component registry schema](https://github.com/jangtrinh/design-os/blob/0c6210d102ed0e20d58d3218309dc83b90199c13/schemas/component-registry.schema.json)
  expects HTML/JSX `markup` and web state vocabulary. Do not register fake HTML specimens
  or put Swift in that field and claim native support.
- The owner-kit onboarding path currently targets React on a shadcn/Tailwind base. Do
  not add those dependencies, CSS token compilation, a 25-component starter floor, or
  a web kit seal to this zero-dependency Swift package.
- HTML/DOM/CSS lint, web screenshots, Figma mirrors, and browser prototypes cannot
  substitute for native build/runtime/accessibility evidence.
- Do not fork upstream's entire CLI, knowledge tree, agent workflows, or evidence engine.
  Keep the useful principles and call the existing native verification lanes.

This is a bounded organization mapping for the reusable app style and CalorieCam. It
does not change the sealed tokens, existing profile defaults, release catalog, or the
separate historical platform-intake work.
