# Native layout recipes

Use these app-local compositions to carry the shared editorial language into another Apple
app. The [complete Luma atlas](luma-layout-atlas.md) covers 393 distinct screens across 120
flows; it supports several layout families, not one universal rounded-card template.
These recipes are native adaptations, not claims about Luma's implementation or exact pixels.

The complete, copyable SwiftUI implementations live in
[`NativeLayoutRecipeCompositionTests.swift`](../Tests/DesignOSAppleTests/AppStyle/NativeLayoutRecipeCompositionTests.swift).
Its `MARK` sections match the names below. Private fixture types keep product composition out
of public API. Copy the relevant composition into the consuming app, replace synthetic
content with its own data, and supply real bindings/actions. No additional package is needed.

## Choose the composition by task

| User task | Start with the specimen | Source observation | Routing and ownership |
| --- | --- | --- | --- |
| Browse a collection | `FlatMediaListRecipe` | [Flat home](https://mobbin.com/screens/4e0f5ef3-de35-450a-b8b8-f8e7ac192e6a), [dated list](https://mobbin.com/screens/f959fe82-8c3e-4bc0-9ad1-6a289eac3845) | Native plain `List`, `NavigationLink(value:)`, flat `DesignOSMediaRow`, real empty branch. The app resolves destinations in its navigation stack. Do not enclose each row in a surface. |
| Inspect an item | `OptionalMediaDetailRecipe` | [Media detail](https://mobbin.com/screens/1370090b-627d-4789-b36c-4665180a544b), [plain profile](https://mobbin.com/screens/81b8325a-b08d-4a15-b780-5275e02bec3b) | Optional crisp cover, title/meta, quiet action, flowing sections. Actual image supplies the backdrop. With no image, omit the hero and use adaptive canvas. |
| Edit media-led content | `MediaComposerRecipe` | [Composer](https://mobbin.com/screens/5468c5bc-943d-4211-b2f0-1f14bbf2ecda), [changed cover](https://mobbin.com/screens/bc829875-4790-42af-83c3-c05259f7be40) | Cover and native fields inside one semantic surface; compact native Save toolbar. Bindings, validation, media selection and save completion belong to the app. |
| Manage settings or metadata | `GroupedManagementRecipe` | [Management](https://mobbin.com/screens/97fc81b7-4fed-46d0-a019-aa70a9a3ee02), [preferences](https://mobbin.com/screens/3ef7d2d1-40cf-45e0-a90f-83749684d3c5) | Native `Form` and `Section`, real fields/toggles, helper text. Use this instead of the media composer when form behavior matters more than atmosphere. Do not put app surfaces inside native form groups. |
| Complete one bounded edit | `FocusedTaskSheetRecipe` | [Single field](https://mobbin.com/screens/a5c932a1-b0c5-46dd-911e-9b9188faf5b6), [validation](https://mobbin.com/screens/46b79fb5-fa43-4bcf-8d4f-aa429d98f41a) | Native `.sheet`, native focus/input, scrollable content, primary pill in `.safeAreaInset`. App owns presentation, cancel/discard, validity and commit outcome. |
| Search and choose | `SearchSelectionRecipe` | [Selection](https://mobbin.com/screens/8a0ca0a7-30b0-4dac-b017-76f9dd01fda1), [people search](https://mobbin.com/screens/3c445308-cc7d-4692-910a-374022783faf) | Native `.searchable` plus `List(selection:)`; one optional stable ID; native no-results content and Done. App owns filtering policy, selection lifetime and completion. |
| Confirm a consequential action | `NativeConfirmationRecipe` | [Confirmation](https://mobbin.com/screens/db78c794-320c-4882-b6e4-e07c9492773f), [native alert](https://mobbin.com/screens/493127ee-b16e-4fc5-ad70-2d0cf2a84545) | Native `.confirmationDialog` with destructive/cancel roles and exact app-supplied consequence copy. Choose `.alert` for a short blocking decision, `.sheet` when explanation/input needs room. |

Apply `.designOSAppStyle(.editorial)` once at the app's content boundary. Keep the app's
`NavigationStack` or `NavigationSplitView`, route models and platform toolbar behavior.
The flat-list test demonstrates native destination registration; the focused-task test
demonstrates sheet presentation. The guide does not prescribe a tab architecture.

## Compose with existing components

- Use `DesignOSMediaRow` and `DesignOSAppSectionHeader` for content hierarchy. Let native
  lists preserve selection foregrounds, focus and keyboard behavior; avoid painting a
  selected row's text with an unconditional custom color.
- Use `DesignOSAppSurface` only for meaningful custom content groups. Native `Form` owns
  its own groups. Do not nest rounded group surfaces or introduce cards to every screen.
- Use `DesignOSMediaBackdrop` only with actual owned/licensed media. It remains decorative
  and retains the existing light/contrast/Reduce Transparency opaque fallbacks. CalorieCam
  adopts one root-owned System/Light/Dark choice across sidebar, content and presentations;
  no individual media or no-media page forces a different theme.
- Use primary/secondary button styles for app-owned content actions. They already produce
  continuous full pills at actual height. Leave system toolbar actions, menus, alerts,
  sheets and pickers under native control; do not replace safety UI to force a pill shape.
- `RecipeCover` clips the actual image bounds with a continuous rounded rectangle. Its square
  aspect and semantic surface radius are a specimen choice, not a universal measured hero.
  For genuine nested media, use `DesignOSCornerGeometry.innerRadius(outerRadius:inset:)`
  with the actual padding/border inset as shown in the [geometry guide](reusable-app-style.md#continuous-and-nested-image-corners).
  Do not subtract page margins for a standalone cover or adjacent thumbnails.

For a freeform edit, keep the focused-task presentation and replace the field with native
`TextEditor`; do not simulate it with a label and gesture. For multiple selection or reordering,
use native selection/editing APIs appropriate to each platform, rather than bolting custom
checkmark gestures onto the single-selection specimen. These are extensions to validate in
the consuming app, not additional verified specimens here.

## State and behavior belong to the app

The specimens have synthetic labels/illustrations and constant test bindings. They do not
load data, request permissions, upload or retain photos, persist settings, or implement
consent. Real consumers supply those effects and their exact disclosures. Do not copy fixture
accessibility labels as descriptions of real media; supply a meaningful description or hide
decorative images when adjacent text already communicates them.

Keep loading, empty, no results, validation and failed-save states distinct. Preserve entered
values during failure; retain visible recovery. Set readiness false while committing to
prevent repeated submission. Dismiss only after confirmed success, or after the app's cancel/
discard policy permits it. Preserve a selected ID across a temporary search filter unless
the product explicitly defines a different behavior; invalidate it when the item is removed.

## Verification boundary

The specimen file is part of the existing `DesignOSAppleTests` target, so `swift test`
typechecks every SwiftUI body and instantiates each recipe, including populated/empty lists,
media/no-media detail and composer, invalid focused input, and search/no-results configurations.
These are compile/instantiation checks, not hosted interaction or screenshot tests.

Run `scripts/verify-swift-package.sh` on the supported Apple toolchain for package tests,
strict release build and formatting. The existing release-candidate CI runs that command.
The authoring Linux environment has no Swift/SwiftUI toolchain; native results remain
unverified until that lane runs for the exact revision. No new public API, runtime tokens,
profile authority or release-catalog stories are introduced.

Before shipping a consuming app, test light/dark, narrow/wide windows, long content and
accessibility Dynamic Type; media/no-media; empty/loading/error/recovery; disabled and repeated
actions; keyboard shown/hidden; Cancel, Back and sheet dismissal; selection and pointer/keyboard
focus; VoiceOver; Increase Contrast and Reduce Transparency. Native controls provide the
foundation, but compilation and still reference images cannot establish those outcomes.
