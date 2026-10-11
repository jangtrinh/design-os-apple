# Isolated native component specimens

Status: fixture source and deterministic capture bindings are implemented. Native compilation,
execution and visual acceptance are **pending** for this revision until an Apple CI run supplies
source-bound `.xcresult` evidence. Static checks are not a native build or visual review. Run
`python3 scripts/verify-component-specimens.py` to validate the planned source bindings.

## Coverage and boundaries

`Examples/LayeredKitPreview/App/ComponentInventorySpecimens.swift` contains 53 explicit routes:
13 semantic component fixtures (including the native field modifier), 15 composite fixtures
(11 public APIs and four native/existing-component composition recipes), nine shell fixtures,
one geometry-helper demonstration, three resolved token-role samples and 12 native recipe
call sites. The existing 18 screen-family routes remain the screen evidence source.

Every runtime component fixture calls the actual `DesignOSApple` API. Fixture content describes
an original courtyard reading club. The small book illustration is synthetic content inside the
real media components; it does not redraw their implementation. Ambient-scroll uses the existing
original fixture media resource. No third-party reference screenshot is bundled.

These are not 53 new public APIs. `DesignOSCornerGeometry` returns geometry, and its route is
explicitly a visualization of that result. Token samples resolve existing runtime roles. Native
recipes call Apple's controls directly; their metadata enums have no rendered body. Support
profiles, metrics, configuration and environment types are not given invented standalone UI.

Seven internal/package primitive records cannot be directly instantiated from this app. Actual
containment evidence includes `DesignOSListRow` for `SymbolContent`, `SectionContentLayout` and
`AccessorySlotLayout`; `DesignOSSidebarRow` also uses `AccessorySlotLayout`. Semantic avatar/media
fixtures exercise editorial geometry and clipping; labeled-value/choice-row fixtures exercise
editorial adaptive layout. `SidebarToolbarContent` has no public wrapper call site in the current
runtime and remains an internal-source record without direct standalone visual evidence.

Home Screen quick actions, system/device chrome and both extension recipe anchors require their
real host targets or system UI. They are listed in the JSON manifest as host-required, not mocked
by a fake app screenshot. Material captures show the package-floor native material branch, not
availability-gated glass. Menu, sharing and picker resting captures do not establish presented
menus, sharing sheets or picker panels. The native presentation fixture separately includes a
real one-tap sheet-open capture.

## Stable routes and artifacts

- `LAYERED_KIT_COMPONENT`: exact manifest component ID, such as `semantic/media-frame`
- `LAYERED_KIT_COMPONENT_STATE`: `default`, or a specifically declared alternate case
- `LAYERED_KIT_APPEARANCE`: `light` or `dark`
- Ready identifier: `component-ready-{component ID}`
- Screenshot stem: `component--{layer}--{component}--{state}--{appearance}`
- Matching JSON attachment suffix: `--binding`
- `LAYERED_KIT_SOURCE_REVISION` on the test runner: optional full source commit; absent is
  explicitly recorded as `unrecorded`, never guessed

`docs/component-native-specimen-manifest.json` is the exact route/capture plan. Baseline is 106
captures per target (53 × light/dark). Eight explicit error/empty/increased-contrast captures,
eight reflow/RTL samples and two native-sheet captures bring the planned total to 124 per target.
Enabled/disabled actions, field modes, surface tones and incoming/outgoing message variants are
shown together and are not counted as separate API records. Accessibility and RTL captures only
certify the exact named samples, never all components or all reference states.

The fixture heading displays symbol, layer, source and exact ID. The shell owns its real native
container. The common surrounding fixture heading is app chrome, not part of the reusable API.
Captures are full native windows; long content can scroll and a resting viewport is not evidence
that every offscreen descendant was visually reviewed.

## Native verification and CI budget

Generate the example project using its existing XcodeGen manifest. Both new Swift files are
included automatically by the App/UITests folder source globs. The root launch integration keeps
the existing design-style and appearance environment modifiers around either route.

Run `ComponentInventoryUITests` separately from the screen-family suite. Do not silently append
124 new launches to a time-bounded 45-minute screen-family job. The test class has seventeen bounded
methods; shard by method for platforms/runners that need it. Each launch waits at most ten seconds
for the exact route, terminates after its capture, and each method has a 600-second allowance.
The native sheet case performs one real button tap and a five-second presentation wait. No
forced focus, test-only control repainting, repeated clicks or coordinate-hit workarounds exist.

Example selection for a macOS run (adapt target name for iOS/iPadOS):

    -only-testing:LayeredKitPreview-macOS-UITests/ComponentInventoryUITests/testSemanticMediaComponents

Suggested groups:

1. Semantic media/content/actions, resolved foundations, alternate and reflow states
2. Composite identity/media, input/selection, message/record, composite native recipes
3. List/scroll, task/conversation, navigation/host shells
4. Native recipe samples 1–3 and native sheet presentation

Retain `.xcresult`, exported screenshots, binding JSON, toolchain and CI commit. Join catalog
images by exact ID/state/appearance, then review screenshots at native size for clipping,
containment, type hierarchy, adaptive colors and native ownership before marking visual status
accepted. Keep source presence, compile success, test execution and visual acceptance separate.
