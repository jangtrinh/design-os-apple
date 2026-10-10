# Luma-derived native UI kit: architecture and delivery contract

Status: architecture contract and additive source implementation, based on the repository at
`8152302037d4a704d42d0e7da98a8ff5309f3088`, with additive work since that baseline. The current
source provides four new semantic APIs, eleven composite APIs, nine shells, and all eighteen
screen types, with compile-fixture source. Four further composite contracts deliberately use
native or existing-component recipes; they are counted separately from public APIs. Native
builds, rendered specimens, and complete reference-state parity require source-bound evidence
for each revision and are not established by these source counts.

The goal is a reusable SwiftUI kit covering the composition and visible state vocabulary of
the complete [Luma atlas](luma-layout-atlas.md): 393 distinct screens, 533 appearances in
120 flows, pinned to version `0ae0e7e9-c7b7-4ef6-bc80-ddd7d4dfc040`. These are 393 reference
states, not 393 independent Swift view implementations. The kit must ship actual reusable
components, shells, and screen types; reference research or copyable snippets alone do not
meet that goal.

## 1. Authority and package boundaries

- Keep the existing zero-dependency `DesignOSApple` product and iOS/iPadOS 17, macOS 14
  package floors. Start with one runtime target and explicit directory/dependency boundaries.
  Split targets only when a real optional framework/dependency or compilation boundary warrants it.
- Preserve `design/design.tokens.json`, `design/component-registry.json`, `design/ds.manifest.json`,
  the existing typed release catalog, and frozen generated bundles. Do not migrate or reseal them
  as a side effect of building the kit.
- `AppStyle/`, `Profile/`, and `Tokens/` remain the runtime theme authority. New layers consume
  existing roles and metrics. Any genuinely missing semantic role needs a separately reviewed
  additive runtime change; metadata must not copy token values into another authority.
- Public Swift names remain unbranded `DesignOS…`. Luma screen IDs and images are research
  provenance, not product names or distributable app assets. Use original/licensed media in fixtures.
- Native controls, navigation, presentations, selection, focus, text editing, keyboard behavior,
  permission dialogs, and provider-owned payment flows retain their proper platform owner.
- Product models, validation decisions, loading work, route state, network requests, authentication,
  persistence, transactions, and permission requests stay in the consuming app. A package screen
  composes caller-owned content and actions; it never starts those operations on appearance.

The explicit user rules remain in force: continuous image corners, actual concentric inset
geometry, and full-pill text actions. Those override a source screenshot's rectangular buttons.
The kit adapts native iPad/macOS behavior; the iPhone screenshots do not prove those adaptations.
See [design-system organization](design-system-organization.md) and [reusable app style](reusable-app-style.md).

## 2. Dependency direction

Theme and policy support every layer. Composition otherwise flows in one direction:

`primitives → semantic components → composites → shells → screen types → consuming apps`

An upper layer may use a lower layer directly when no meaningful intermediate abstraction is
needed. It must not import a consuming app, create a global router, or reach upward into a screen.

| Layer | Location | Owns | Does not own |
| --- | --- | --- | --- |
| Runtime theme | Existing `AppStyle/`, `Profile/`, `Tokens/` | Palette, typography, validated metrics, accessibility policy | Copied Luma source tokens, application state |
| Primitives | `Primitives/Editorial/`, plus existing package primitives | Measurement, finite geometry, clipping, adaptive slot placement | Product labels, gestures, navigation, scroll containers |
| Semantic | `Components/Semantic/`, existing six editorial components | Media frame, identity avatar, labeled value, status message, native action appearance | A replacement TextField/Toggle/DatePicker or data fetching |
| Composite | `Components/Composite/` | Meaningful groups of semantic units with generic content/action slots; a category rail owns its one horizontal scroller | Outer vertical scroll/navigation ownership, product-specific model requirements |
| Shell | `Shells/` | Exactly one native scrolling/container policy and optional safe-area action region | App route state, fabricated tab destinations, duplicate nested scrolling |
| Screen type | `Screens/` | Named task hierarchy assembled from shells and composites | Domain services, automatic submissions, invented source interactions |
| Native integration recipes | Existing `Recipes/` and new bounded recipe documentation/specimens | Platform/provider handoff points and real native call sites | Fake platform dialogs, simulated camera/payment advertised as integration |
| Dogfood and fixtures | App-owned example/test hosts | Real composition, fixture data, interactions, capture | An alternate implementation of the shared kit |

Existing `SectionContentLayout`, `AccessorySlotLayout`, `SymbolContent`, and
`SidebarToolbarContent` have package access. Preserve that boundary. Publish semantic APIs
that consumers can use meaningfully; do not expose every measurement helper merely to fill a layer.

### Existing implementation to reuse

- `DesignOSAppStyle`, adaptive palette/metrics, `DesignOSProfile`, and semantic typography
- `DesignOSCornerGeometry.innerRadius(outerRadius:inset:)`
- `DesignOSMediaRow`, `DesignOSAppSectionHeader`, `DesignOSAppSurface`
- `DesignOSPrimaryButtonStyle`, `DesignOSSecondaryButtonStyle`, `DesignOSMediaBackdrop`
- Existing native List/sidebar content and native navigation/input/presentation recipes

Presence of these APIs does not establish that any of the 393 complete screen states has been
implemented or visually accepted. The [native API coverage guide](component-coverage.md)
also distinguishes source specimens, compile fixtures, documentation, and host-required capabilities.

## 3. First-slice public API contracts and file ownership

Each named type has a same-named Swift file. Generic `@ViewBuilder` slots preserve caller-owned
native content. Prefer concrete generic views over `AnyView`; offer `EmptyView` convenience
initializers for genuinely optional slots. Do not require callers to invent placeholder controls.

### Foundations slice

Own `Primitives/Editorial/`, `Components/Semantic/`, and matching
`Tests/DesignOSAppleTests/EditorialPrimitives/` and `Tests/DesignOSAppleTests/Semantic/`.

| Stable ID | Public API | Contract |
| --- | --- | --- |
| `semantic/media-frame` | `DesignOSMediaFrame` | Finite aspect-ratio media frame; clip the actual rendered media to continuous geometry. Caller supplies image/content, accessibility, and load/error state. No download or fixed screen-size hero. |
| `semantic/avatar` | `DesignOSAvatar` | Identity-sized, circular media or caller-supplied fallback. Size derives from runtime metrics unless explicitly supplied; no initials inferred from private names and no image loading. |
| `semantic/labeled-value-row` | `DesignOSLabeledValueRow` | Label, arbitrary native value/control, optional accessory; horizontal when it fits, structural vertical reflow at accessibility text sizes. Never install a row-wide gesture over a control. |
| `semantic/status-message` | `DesignOSStatusMessage` | Inline title/message/icon/action composition for empty/error/loading/status contexts. It does not invent error copy, announce arbitrary text automatically, or own asynchronous state. |

These semantic APIs must demonstrably reuse internal geometry/layout primitives and the existing
style. They are not a new token system. Preserve accessibility of supplied controls rather than
combining an entire form row into one inaccessible element.

### Composition slice

Own `Components/Composite/`, `Shells/`, `Screens/`, and matching test subdirectories.
Do not edit CalorieCam while the independent product fixes are active.

Initial composites:

- `composite/field-group` → `DesignOSFieldGroup`: heading/help/content slots and meaningful group
  appearance. Native `Section` remains appropriate inside a `Form` or `List`; avoid card-in-card nesting.
- `composite/identity-header` → `DesignOSIdentityHeader`: caller-supplied identity media, title,
  metadata, and real action views; complete text and accessible reflow.

### Extended composite APIs

The following nine types are concrete source additions in `Components/Composite/`. They consume
existing style metrics and lower-layer APIs; no parallel token values or app model are required.
Their native compile and state-ownership fixtures are in
[`DesignOSExtendedCompositeTests.swift`](../Tests/DesignOSAppleTests/Composite/DesignOSExtendedCompositeTests.swift).
Fixture source is a callable usage contract, not proof of rendered or interactive behavior.

| Stable ID | Public API | Reusable contract and caller boundary |
| --- | --- | --- |
| `composite/media-detail-header` | `DesignOSMediaDetailHeader` | Optional crisp hero followed by identity/title/metadata/actions using `DesignOSIdentityHeader`; caller supplies accessible media and real actions. No background or scroll ownership. |
| `composite/media-composer-header` | `DesignOSMediaComposerHeader` | Media and native media actions, then the primary editable field and persistent feedback. Caller owns media selection, bindings and validation; controls do not occlude the hero. |
| `composite/choice-row` | `DesignOSChoiceRow` | Leading content, flexible description and independently accessible native control. Shared measurement reflows the same control at narrow widths and accessibility text sizes; no implicit selection or row-wide gesture. |
| `composite/selection-summary` | `DesignOSSelectionSummary` | Localized selection summary and caller-supplied completion actions, with accessibility-size reflow. Count/limit copy, readiness and selection remain caller-owned. |
| `composite/category-rail` | `DesignOSCategoryRail` | Header, stable-ID items and explicit empty content. Owns one horizontal `ScrollView` with a `LazyHStack`; the containing shell retains vertical scrolling. Item controls own selection/navigation. |
| `composite/message-bubble` | `DesignOSMessageBubble` | Incoming/outgoing alignment, optional reply context, message content and persistent metadata outside the adaptive surface. Caller owns sender/delivery facts, retry and context-menu actions. |
| `composite/conversation-composer` | `DesignOSConversationComposer` | Native attachment controls, flexible input, completion actions and persistent feedback. Shared measurement reflows the same controls; caller owns draft, focus, line limits and repeat-submit guards. |
| `composite/record-summary` | `DesignOSRecordSummary` | Record identifier/status header with labeled facts in one adaptive surface. Caller supplies safe data and actual status; no credential generation or inferred transaction state. |
| `composite/utility-overlay` | `DesignOSUtilityOverlay` | Readable status and native actions on an opaque adaptive surface over an app-owned canvas. No permission request, surrounding-canvas gesture capture or invented integration. |

The direct fixture functions are `mediaHeaderCompositionsCompile`, `choiceRowCompositionCompiles`,
`selectionSummaryCompositionCompiles`, `categoryRailCompositionCompiles`,
`messageBubbleCompositionsCompile`, `conversationComposerStateOwnership`, and
`recordAndUtilityCompositionsCompile`. `compositeAdaptiveLayoutPolicy` checks the shared reflow
and flexible-middle-slot allocation policy without claiming a hosted control interaction.

### Native and existing-component composite recipes

Four source-atlas contracts have meaningful composition but do not justify another public
wrapper. Their exact recipes are bound to
[`DesignOSCompositeRecipeTests.swift`](../Tests/DesignOSAppleTests/Composite/DesignOSCompositeRecipeTests.swift):

| Stable ID | Actual implementation boundary | Named compile fixture |
| --- | --- | --- |
| `composite/form-section` | Native `SwiftUI.Section` inside native `Form` owns header/footer, row grouping and platform behavior; app supplies real controls and validation. | `nativeFormSectionRecipeCompiles` |
| `composite/sectioned-media-collection` | Native `Section` plus stable-ID `ForEach` and `DesignOSMediaRow` inside `DesignOSFlatListShell`; the shell's `List` remains the only vertical scroller. | `nativeSectionedMediaCollectionRecipeCompiles` |
| `composite/status-content` | Reuse `DesignOSStatusMessage` for title/message/icon/actions; caller chooses the actual state, recovery action and any accessibility announcement. | `reusedStatusContentRecipeCompiles` |
| `composite/confirmation-content` | Native consequence `Text` and role-bearing `Button` content inside existing `DesignOSConfirmationScreen`; app owns presentation and actual consequences. Short decisions may use native `confirmationDialog` or `alert`. | `nativeConfirmationContentRecipeCompiles` |

These four records use `recipe_present`, never `source_present`, in the layered index. Their
native/existing bindings are consumer recipe references, not runtime dependencies from the
composite layer upward to a screen. They do not create four new public types, prove executed
native presentations, or establish any complete reference-screen state.

### Shell and screen API contracts

First shells:

| Stable ID | Public API | Container and boundary |
| --- | --- | --- |
| `shell/flat-list` | `DesignOSFlatListShell` | Owns one native plain `List`; caller supplies Sections/rows and optional native modifiers. No surrounding ScrollView. |
| `shell/grouped-form` | `DesignOSGroupedFormShell` | Owns one native `Form`; caller supplies native Sections/fields. Content grouping follows platform form behavior. |
| `shell/ambient-scroll` | `DesignOSAmbientScrollShell` | Owns one ScrollView and media/canvas background. Caller supplies actual media or explicit no-media content; existing opaque fallbacks apply. |
| `shell/focused-task` | `DesignOSFocusedTaskShell` | Owns one ScrollView and an optional native safe-area action region. Native keyboard avoidance stays active; large text can scroll to the action. |

First screen types:

| Stable ID | Public API | Ordered content contract |
| --- | --- | --- |
| `screen/flat-collection` | `DesignOSFlatCollectionScreen` | Optional summary/header → native sections/rows → explicit caller-supplied state branch |
| `screen/media-detail` | `DesignOSMediaDetailScreen` | Optional media → identity/meta → local actions → open detail sections |
| `screen/media-composer` | `DesignOSMediaComposerScreen` | Media → primary editable fact → grouped native fields → inline validation/action |
| `screen/grouped-form` | `DesignOSGroupedFormScreen` | Optional introduction → semantic form sections → helper/destructive region |
| `screen/focused-task` | `DesignOSFocusedTaskScreen` | Task heading → focused field/content → persistent validation → primary action |

Screen types compose shells, rather than duplicating shell internals. They must contain usable
native layout, not empty marker enums or aliases advertised as finished screens. Navigation titles,
toolbars, `.sheet`, and route/selection bindings belong to the host unless an explicitly named
navigation shell receives caller-owned bindings. Do not stack a shell List/Form/TextEditor inside
another vertical ScrollView.

## 4. Complete atlas-to-kit mapping

The immutable research source is [the 393-record inventory](luma-layout-atlas.inventory.json).
It contains 71 raw family labels, including space/underscore aliases and mixed buckets such as
`sheet`, `popover`, and `grouped form/settings`. These labels must remain intact for provenance.

The additive [coverage file](luma-kit-coverage.json) is the per-screen mapping contract. Each of the 393
source IDs maps to exactly one primary screen family, one shell, its visible state/variant,
and the lower-layer dependencies. A state may have additional overlay or native-host dependencies.
No screen is dropped because its current name is inconsistent or because its platform is specialized.
The coverage file is maintained separately from this architecture plan and from the frozen catalog.

The initial map accounts for all 393 IDs, with 81 explicit anatomy overrides and zero unmapped
records. Its family counts are grouped form 95; focused task 43; search/selection 39; flat
collection 29; native presentation 26; media detail 23; confirmation 23; message thread 20;
profile detail 15; freeform editor 14; media composer 14; status 11; discovery 10; record detail 9;
onboarding 7; provider host 7; utility canvas 6; hero collection 2. These sum to 393. Complete
screen-state implementation, native execution and visual comparison remain unverified/not run
in this initial map; all lower-layer implementation work is tracked separately.

| Canonical screen family | Source anatomy and variants | Principal shell |
| --- | --- | --- |
| `screen/onboarding` | Launch, welcome/auth choices, permission explainer, setup prompt; domain art/copy slots | `shell/focused-task` |
| `screen/flat-collection` | Feed, dated directory, people/inbox/transaction lists; empty, populated, scrolled, filtered | `shell/flat-list` |
| `screen/discovery` | Sectioned collection with category/city/media rails and search entry | `shell/flat-scroll` |
| `screen/profile-detail` | Plain, ambient, or cover identity header; counts/actions/sections, blocked/empty | `shell/flat-scroll` or `shell/ambient-scroll` |
| `screen/media-detail` | Poster/content detail, open prose, metadata, hosted/registered/status variants | `shell/ambient-scroll` |
| `screen/hero-collection` | Immersive image/title introduction transitioning into a flat collection | `shell/flat-scroll` |
| `screen/media-composer` | Cover selection plus editable identity, scheduling/location/options, filled/empty | `shell/ambient-scroll` |
| `screen/grouped-form` | Management/preferences, identity editing, conditional sections, controls and validation | `shell/grouped-form` |
| `screen/focused-task` | One task with a field, compact configuration, review, or explanation; keyboard/error/busy | `shell/focused-task` |
| `screen/freeform-editor` | Borderless text/rich-text entry with native editing and caller-owned accept/cancel | `shell/native-host` |
| `screen/search-selection` | Search results, single/multi-selection, reordering, visual choices, disabled/processed | `shell/flat-list` or `shell/flat-scroll` |
| `screen/confirmation` | Risk/choice/access gate/invitation content; preserve context and explicit consequences | `shell/focused-task` |
| `screen/status` | Success, waitlist, submission result or blocked state with optional recovery action | `shell/focused-task` |
| `screen/message-thread` | Incoming/outgoing messages, reply/media variants and native expanding composer | `shell/conversation` |
| `screen/utility-canvas` | Map, camera, scanner, media grid/crop task and overlaid result controls | `shell/utility-canvas` |
| `screen/provider-host` | Embedded payment/scanning, platform contact sharing, externally owned integration | `shell/native-host` |
| `screen/record-detail` | Ticket/QR/receipt details with domain-owned safe data and actions | `shell/flat-scroll` |
| `screen/native-presentation` | Real native menu, alert, date picker, share surface, dialog/popover | `shell/native-host` |

`shell/adaptive-navigation` is the ninth shell ID. Its source is a native
NavigationStack/NavigationSplitView composition with caller-owned selection/path. It must not
pretend that a native alert or phone screenshot requires a custom global application router.

The public source names for the five additional shells are `DesignOSFlatScrollShell`,
`DesignOSConversationShell`, `DesignOSUtilityCanvasShell`, `DesignOSNativeHostShell`, and
`DesignOSAdaptiveNavigationShell`. A native-host shell inserts no implicit scrolling; a
conversation shell supplies its message scroll and a safe-area composer; a utility shell
supplies native canvas/overlay slots without inventing the underlying integration.

The thirteen additional screen API names bind the canonical IDs in the table:
`DesignOSOnboardingScreen`, `DesignOSDiscoveryScreen`, `DesignOSProfileDetailScreen`,
`DesignOSHeroCollectionScreen`, `DesignOSFreeformEditorScreen`, `DesignOSSearchSelectionScreen`,
`DesignOSConfirmationScreen`, `DesignOSStatusScreen`, `DesignOSMessageThreadScreen`,
`DesignOSUtilityCanvasScreen`, `DesignOSProviderHostScreen`, `DesignOSRecordDetailScreen`, and
`DesignOSNativePresentationScreen`. Native presentation/provider screens host real supplied
content; these names do not claim implementations of payment processing or operating-system UI.
Their source and evidence status is recorded by the [layered index](layered-kit-index.json),
independently of this naming contract. A hosting wrapper is not proof of an executed integration.

### Mapping rules that prevent false coverage

1. Preserve `id`, source URL, observed family/state/observations, and image hash. A normalized
   state identifier is an additional key, never a rewrite of the source observation.
2. Resolve mixed buckets from their recorded anatomy per source ID. For example, the generic
   sheets include freeform editors, person details, compact numeric tasks, confirmation, and
   status results. Popovers include date pickers as well as action menus. One blanket mapping
   for those buckets is not complete semantic coverage.
3. Keep screen content, transient state, and presentation independent. The same confirmation
   content can appear in a native sheet on iPhone and a native presentation on macOS.
4. A dark reference is evidence only for its actual state. Generate and test missing appearances
   as explicit native adaptations, not as supposedly inspected source screenshots.
5. Assign native/provider ownership explicitly. The still image of a cropper does not prove its
   vendor or implementation. Supply a content/integration contract until that is known; no fake
   Apple control or working payment/camera claim.
6. Repeated screen IDs in 533 flow occurrences remain one screen-state record. Preserve the
   separate 120-flow ordering evidence; do not multiply implementation coverage by occurrences.

### Lower-layer vocabulary for the coverage graph

Stable primitive IDs: `primitive/corner-geometry`, `primitive/section-content-layout`,
`primitive/accessory-slot-layout`, `primitive/symbol-content`, `primitive/sidebar-toolbar-content`.
New internal editorial primitives receive IDs only when their actual source exists.

Semantic IDs include the first-slice four and the existing `semantic/media-row`,
`semantic/section-header`, `semantic/content-surface`, `semantic/primary-action`,
`semantic/secondary-action`, and `semantic/media-backdrop`.

The fifteen composite IDs now resolve to eleven concrete APIs and four documented native or
existing-component recipes above. The mapping retains the same stable IDs; a recipe is an
intentional delegation rather than a missing type renamed as implemented. A coverage dependency
still does not establish a complete source-screen implementation or visual acceptance.

## 5. Additive layered-kit discovery and gate

Keep the existing six-component app-style index intact. Its current top-level Components scan
does not cover new Semantic/Composite subdirectories, Shells, or Screens. New files must not
evade discovery by falling outside that scan.

The separately versioned [layered-kit index](layered-kit-index.json) and portable
[`verify-layered-kit.py`](../scripts/verify-layered-kit.py) gate cover these directories.
Schema v2 distinguishes:

- **Planned:** stable ID, layer, intended contract and dependencies; no fabricated source path
- **Source present:** real module, public symbol, source path, usage documentation, compile fixture
- **Recipe present:** explicit native/existing API bindings, actual named consumer compile fixture
  and its hash, documented ownership; no fabricated runtime source, public symbol or API count
- **Native compiled:** exact source revision, command, toolchain, result artifact and success
- **Rendered/reviewed:** exact state, appearance, platform/window, capture hash and actual reviewer

Swift remains the runtime authority. The index stores references and requirements, not copied
palette values, metrics, or generated implementations. Evidence tiers remain separate rather
than one optimistic `complete` boolean. Native delegation is a distinct disposition; it can
fulfil an intentional native boundary, but is not a custom SwiftUI reconstruction or executed
provider integration.

The gate must:

1. Reconcile all 393 exact screen IDs/hashes with the pinned inventory and reject omissions,
   duplicates, unknown IDs, stale source hashes, and unexplained family overrides.
2. Validate all dependency IDs, layer direction, cycles, module ownership and safe paths.
3. Discover all new public declarations recursively in the explicitly owned runtime directories;
   every declaration has an index record, and every source-present record resolves to a declaration.
4. Require documentation and a native compile specimen for public semantic/composite/shell/screen
   APIs. Internal primitive records must not be promoted as public APIs. Recipe documentation
   names the stable ID and exact fixture function; actual constructor calls within that function
   must match the registered native/existing bindings. Comments alone cannot satisfy a binding.
5. Require source-bound evidence for claims at each tier. `research_mapped` does not imply
   `implemented`; a compiling view does not imply 393 rendered screen states.
6. Reject invented native/provider implementations, placeholder evidence, unsupported platforms,
   changed source with retained pass receipts, and mutations of the frozen store/catalog.
7. Include red controls for missing/unregistered/dangling components, duplicate source IDs,
   missing state variants, unsafe paths, illegal upper-layer imports, and false verification claims.

The evidence register must use honest initial states. The atlas establishes 393 researched and
mapped references. Complete screen-state implementation/rendered acceptance starts unverified
and advances only with actual artifacts, even when lower-layer APIs already exist.

### Current source milestone versus completion

The first packaged-kit milestone is measurable: 393 exact source IDs mapped; all 18 named
screen types and 9 shells callable from an independent `DesignOSApple` consumer; 4 new semantic
components and 11 composites reusing shared primitives/style; 4 native/existing-component recipes
with real consumer fixtures; recursive index validation; and
native build plus representative interactive/capture proof for every family and platform claimed.
The source portion is present. Native specimen proof must be attached before calling this
milestone verified.

That milestone does not close the full reconstruction request by itself. The separate remaining
measure is exact state coverage: all 393 source-state records need concrete fixture bindings,
native captures and review or an explicit, justified native/provider delegation. The coverage
file currently preserves that work as unverified. Do not silently equate 18 generic screen
scaffolds with 393 completed screens, or count the 4 recipe contracts as extra public APIs.

## 6. Bounded implementation slices

| Slice | Build | Acceptance and stop condition |
| --- | --- | --- |
| 0: Coverage contract | Exact 393-ID map, 18 families, 9 shells, layer graph | Exhaustive mapping and explicit ambiguous/native boundaries; no runtime claims |
| 1: Foundations | Four semantic APIs backed by reusable internal geometry/layout; existing theme/actions | Public consumer compile fixtures, finite/invalid geometry tests, accessible reflow, no app imports |
| 2: Core compositions | Two composites, four shells, first five concrete screen types | Native build/tests and fixture captures for each type; one scroll owner; state slots usable with real controls |
| 3: Browsing and identity | Discovery/hero/profile, search/select/reorder, onboarding/status/record detail; reusable headers, choice/selection summary, category rail and record summary | Configured fixtures for every mapped variant in these families; selection/focus/navigation owned correctly |
| 4: Communication and integrations | Conversation, message bubble/composer, utility overlay/canvas, freeform editor, four native/existing composite recipes and provider host | Real supported call sites and honest host requirements; no simulated integration advertised as real |
| 5: Full state coverage and reuse | All 393 reference-state fixtures plus cross-platform stress/adaptation suite | Every source record resolves to a concrete tested composition or explicit native-delegation evidence; independent visual review and owner acceptance remain separately recorded |

Coverage counts after each slice are computed from the mapping and actual receipts, not guessed
from family names. Report researched, mapped, source-present API, recipe-present, compiled,
rendered, reviewed, and native-delegated counts separately. No claim of a complete 393-screen UI kit from a small gallery
of five representative screens.

### Verification matrix

- Render every reference-state fixture on a pinned iPhone container before claiming full visual
  state coverage. Original/licensed fixture content may replace restricted source imagery; record
  that adaptation and review composition, not identical copyrighted pixels.
- For each screen family, cover light/dark, narrow/expanded, normal/accessibility Dynamic Type,
  long/RTL/localized content, no-media, Reduce Transparency, Increase Contrast, and reduced motion
  where applicable. Shared test cases can prove shared behavior only at their actual scope.
- For interactive families, test keyboard entry, focus/error visibility, disable/busy/double
  activation, interruption, cancel/back/return, selection/reorder, pointer and hardware keyboard.
- iPad uses actual resizable/windowed proposals and input modes. macOS uses actual windows,
  keyboard/menu conventions and supported native containers. Do not multiply phone captures into
  platform coverage or hardcode device-model breakpoints.
- A missing high-contrast fixture, native SDK, device, or live assistive-technology result remains
  not verified. Still images cannot prove animation, permission behavior, VoiceOver or hardware.
- Run the existing package/release gates and new layered coverage gates on final source; keep
  deterministic, rendered, accessibility, independent review and owner acceptance separate.

## 7. Dogfood without coupling the package to CalorieCam

After the shared APIs compile and active product fixes are published, migrate bounded app surfaces:

- Journal → `DesignOSFlatCollectionScreen`, native sections and `DesignOSMediaRow`
- Saved meal detail → `DesignOSMediaDetailScreen`, real retained photo/provenance and open sections
- Capture/review → `DesignOSMediaComposerScreen` and native editable field groups
- AI settings → `DesignOSGroupedFormScreen`, preserving consent, secure storage, endpoint and error handling
- Focused editing/confirmation → task screen or native presentation as appropriate

The app's data model, consent rules, photo retention, sample-versus-real provenance, save/delete
semantics and live service calls remain unchanged by UI extraction. Add a separate minimal
consumer compile host that imports only `DesignOSApple` and supplies unrelated fixture data;
successful reuse must not require copying a CalorieCam file or importing its Core module.

Families absent from CalorieCam still need a native specimen host and state fixtures. Do not add
chat, event ticketing, payment, or social-account features to CalorieCam merely to demonstrate
coverage. A new demonstration host is additive and separate from the frozen release catalog.
