# Luma layout atlas: complete pinned-version visual review

Research date: 2026-10-10. Target: the **Luma events iOS app**, exact version `0ae0e7e9-c7b7-4ef6-bc80-ddd7d4dfc040`, for CalorieCam and a reusable native Apple kit. This expands the earlier [small reference profile](luma-style-reference.md) into a complete accessible, source-bound layout inventory. It does not add Luma assets or event features to the app.

## Coverage receipt and provenance

| Measure | Verified coverage |
| --- | ---: |
| Pinned-version flow records | 120 / 120 |
| Screen appearances across those flows | 533 / 533 |
| Distinct screen IDs and image files | 393 / 393 |
| Downloaded images visually inspected | 393 / 393 |
| Remaining images in the pinned catalog | 0 |
| Image SHA-256 matches to pinned catalog | 393 / 393 |
| Ordered flow screen-ID sequences matched | 120 / 120 |
| Older-version flow results excluded | 10 |

Sources:
- [Requested Mobbin collection](https://mobbin.com/apps/luma-ios-bead4230-994f-47c2-9311-5049bf7bcace/0ae0e7e9-c7b7-4ef6-bc80-ddd7d4dfc040/screens)
- Connected Mobbin MCP: `Luma` iOS flow search, pages 1–12, ten flows per page. Page 13 was checked and returned ten other-version flows; those were excluded.
- [Public pinned version catalog](https://github.com/Johnson-f/OpenMobbin/blob/master/catalog/apps/luma/versions/0ae0e7e9-c7b7-4ef6-bc80-ddd7d4dfc040.json): app `bead4230-994f-47c2-9311-5049bf7bcace`, publication 2026-09-14. Used to corroborate exact membership and image identity, not to infer visual appearance.
- [Complete per-screen inventory with observations](luma-layout-atlas.inventory.json). The appendix below links every distinct screen to Mobbin. Index numbers are first-appearance order in the pinned catalog, not Mobbin's own global screen ordering.

Every downloaded image was viewed in a labeled contact sheet; distinguishing complex states were additionally enlarged. The review covers all 393 unique images, not only the MCP's evenly spaced inline flow previews. All source files decode successfully and byte-for-byte SHA-256-match the catalog. Repeated screenshots across flows were reviewed once and retained in every flow's ordered mapping.

**Boundary:** the Mobbin collection webpage itself was not readable through the web reader. Exhaustiveness is established for all 393 images in the corroborated pinned-version catalog and all 120 matching Mobbin MCP flows. No claim is made about unpublished, unindexed or later-added content beyond this evidence. Still images establish visible states and the supplied flow order; they do not establish animation timing, gesture physics, exact implementation framework, accessibility behavior or source design tokens.

## What the complete collection changes

Luma is not one universal “rounded card” layout. It switches composition according to task:

1. **Browse:** flat white/black lists, compact header, small media, dates and quiet metadata.
2. **Inspect media:** large poster, ambient color, exposed prose/metadata, section rules and a small action cluster.
3. **Create media:** centered cover and grouped editable rows; deep editing moves into a dedicated focused surface.
4. **Manage:** pale canvas with white section groups, concise label/value rows, toggles and navigation rows.
5. **Perform one task:** spacious sheet or focused text editor with one primary action and keyboard-aware placement.
6. **Choose or confirm:** compact menus/sheets layered over retained context, rather than another full detail page.

The earlier profile's advice against heavy card stacks remains right for feeds and editorial detail. It is **not** a ban on grouped containers in management/settings: the full collection uses them extensively and deliberately.

## Observed layout families

These are reusable compositions, not claims about Luma's internal component names. Source-specific row/action variants are recorded in the full inventory.

| Family | Observed anatomy | Evidence | Native-kit boundary |
| --- | --- | --- | --- |
| Launch/onboarding | Centered mark or upper illustration, short prompt, generous whitespace, limited bottom action | [launch](https://mobbin.com/screens/a4f98553-c181-42b0-aabe-8557687f723c), [welcome](https://mobbin.com/screens/d9fb4b91-d669-49e0-8ca3-f8b19fb7a54b), [notification prompt](https://mobbin.com/screens/f8b9c208-0980-466d-a9f3-696fb4cd6876) | Domain owns illustration and copy; system permission prompt remains native |
| Flat feed/directory | Compact top chrome; dated or labeled sections; thumbnail/avatar + title + metadata; sparse separators; no enclosing row cards | [home](https://mobbin.com/screens/4e0f5ef3-de35-450a-b8b8-f8e7ac192e6a), [events](https://mobbin.com/screens/f959fe82-8c3e-4bc0-9ad1-6a289eac3845), [cities](https://mobbin.com/screens/f2bb3188-3b87-4cb4-abb1-4ec8048eebc6), [dark feed](https://mobbin.com/screens/9f3e1d45-f117-4ff5-9b72-46ba5273a2f6) | Native List and row composition; selection/scroll/safe areas native |
| Discovery hub | Flat list plus horizontal category/city/media rails; compact section headers | [discovery](https://mobbin.com/screens/41fc6d38-02bd-41c8-9270-244e373e08ad), [city rail](https://mobbin.com/screens/808ce2fa-247d-45c6-a033-9c91e7ce80df), [dark discovery](https://mobbin.com/screens/f8896c4c-e3e2-40e4-bb4f-4b02852abe31) | Optional composition recipe, not mandatory navigation architecture |
| Editorial/profile detail | Identity block and counts, action(s), then plain sections; cover profile has full-width banner + overlapping identity image | [ambient host profile](https://mobbin.com/screens/bfd3ee00-4aed-410e-b829-993ad1b10a22), [cover profile](https://mobbin.com/screens/a367d663-f55e-4206-bf4f-ee60ba0c2adb), [plain profile](https://mobbin.com/screens/81b8325a-b08d-4a15-b780-5275e02bec3b) | Separate identity and content slots; don't force a photo into every detail |
| Immersive media detail | Large crisp media, image-colored backdrop, title/time/status, compact actions, long open prose; content survives scroll under compact chrome | [event detail](https://mobbin.com/screens/1370090b-627d-4789-b36c-4665180a544b), [map/hosts section](https://mobbin.com/screens/2e0a1bcc-4a0e-415d-9f04-0e35a6973a66), [prose](https://mobbin.com/screens/633bd9c8-5d58-40db-a0ef-540f0718a941), [hosted detail](https://mobbin.com/screens/28c216de-6be2-42bf-8cac-265d32b201a0) | Backdrop, cover and content-section recipes; NavigationStack/toolbars native |
| Immersive hero → feed | Full-bleed city image, darkened title/prose, then abrupt return to white dated rows | [city hero](https://mobbin.com/screens/edd163db-5ae8-4f5d-9727-47843267e39f), [scrolled city](https://mobbin.com/screens/b6891245-d834-49c3-b75d-a6f9946eeeb9) | Specialized composition; no need in CalorieCam's current scope |
| Media composer | Centered square cover; editable name; grouped dates/location/options; secondary editors/pickers | [initial composer](https://mobbin.com/screens/5468c5bc-943d-4211-b2f0-1f14bbf2ecda), [changed media](https://mobbin.com/screens/bc829875-4790-42af-83c3-c05259f7be40), [location applied](https://mobbin.com/screens/7449f7d1-aa15-4f20-ab99-f0429cebf680) | Content scaffold around real controls; media is domain-owned |
| Grouped form/settings | Pale or ambient canvas; section headings/helper text; one rounded surface per semantic group; label/value/toggle rows and hairlines | [management](https://mobbin.com/screens/97fc81b7-4fed-46d0-a019-aa70a9a3ee02), [edit form](https://mobbin.com/screens/214dddc2-24bb-45c7-bd53-04463e9ad9c6), [settings](https://mobbin.com/screens/16c6d87f-6b55-40a5-aa6d-4cdc2a70922f), [preferences](https://mobbin.com/screens/3ef7d2d1-40cf-45e0-a90f-83749684d3c5) | Grouped section/row recipe. Do not wrap or replace every native control |
| Single-purpose form | Centered icon/title/short guidance; one input or compact input group; bottom pill above keyboard; disabled/valid/error states | [email input](https://mobbin.com/screens/f2970c67-067b-4a43-9416-18f656d7e723), [capacity](https://mobbin.com/screens/a5c932a1-b0c5-46dd-911e-9b9188faf5b6), [inline validation](https://mobbin.com/screens/46b79fb5-fa43-4bcf-8d4f-aa429d98f41a) | Native TextField/FocusState/keyboard; layout and validation slots only |
| Freeform editor | Text sits directly on canvas; compact cancel/accept top controls; keyboard and optional accessory toolbar | [ambient editor](https://mobbin.com/screens/55216a03-d6c2-4bb5-92b0-2a8b4ae8174b), [light editor](https://mobbin.com/screens/adc89d9f-a056-4064-860b-9c5df10ee581), [feedback](https://mobbin.com/screens/8a9033f2-a7df-4933-873d-63745044627f) | Native TextEditor or native rich-text surface; no mandatory outer input card |
| Search/select/reorder | Search field; dense plain or grouped rows; current choice/checks; selected-count pill; same shell for empty result | [multi-select](https://mobbin.com/screens/f46be2d3-9980-4fd3-a773-806141d5206b), [currency](https://mobbin.com/screens/8a0ca0a7-30b0-4dac-b017-76f9dd01fda1), [people selection](https://mobbin.com/screens/3c445308-cc7d-4692-910a-374022783faf), [drag state](https://mobbin.com/screens/af1548e3-2411-4dc7-82cc-334c80e29f36) | Native searchable/List/selection/reordering where possible |
| Compact sheet/confirmation | Parent dimmed but recognizable; symbol/title/copy; short field/choice group if needed; one clear bottom pill | [destructive sheet](https://mobbin.com/screens/db78c794-320c-4882-b6e4-e07c9492773f), [choice sheet](https://mobbin.com/screens/e387642e-b8d9-46cb-b81d-bca0083135c7), [block sheet](https://mobbin.com/screens/f5955690-f166-4c6a-89fd-459d490f4b05), [remove sheet](https://mobbin.com/screens/51c86f5a-3801-4c1e-b970-6ae4d87b0b94) | Prefer platform confirmationDialog/sheet; actual risk copy and semantics domain-owned |
| Anchored menu/system alert | Small choice/action menu beside invoker; checked/destructive rows; centered alert for concise blocking decision | [filter menu](https://mobbin.com/screens/25355146-cf9c-40a1-9558-a073775eb447), [nested camera menu](https://mobbin.com/screens/d5b5b94c-435b-4a1b-b8d7-060bebec13a1), [delete alert](https://mobbin.com/screens/493127ee-b16e-4fc5-ad70-2d0cf2a84545), [sign-out alert](https://mobbin.com/screens/ef9007c5-aa3c-4fad-849b-46dbfb9d7b23) | Native Menu, Picker, alert; do not imitate screenshot blur as a static component |
| Chat/messaging | Flat inbox or left/right bubble thread; compact identity chrome; expanding anchored composer; contextual reaction/reply overlays | [inbox](https://mobbin.com/screens/d344cda6-0073-40fd-b48d-ae3239115371), [thread](https://mobbin.com/screens/c3f1fbf1-0f92-4552-a55a-a1b514551bd1), [message menu](https://mobbin.com/screens/41cfb1fe-da3f-41c7-a3a0-c3d86788d430), [dark thread](https://mobbin.com/screens/e8eb6d85-bb28-4bee-a01e-b6f866be6b67) | Future app-specific recipe only; not an excuse to add chat to CalorieCam |
| Map/camera/media utilities | Edge-to-edge map/viewfinder; few floating controls; results/person sheet layered over canvas | [scanner](https://mobbin.com/screens/07fa77cb-8f6f-40e1-aba9-1eafb60954bf), [scan result](https://mobbin.com/screens/c79be8a7-a525-40ab-87d7-3167e2180b63), [map](https://mobbin.com/screens/fb378b19-93e3-4cac-b862-fd3208c4c59e), [expanded map list](https://mobbin.com/screens/d98f6edc-7efd-4130-9a2d-3fdcaf6fee63) | Use real camera/map/media APIs and system presentation |
| Platform/provider/media utilities | Contacts disclosure, crop utility, payment fields/scanner and platform alerts have specialized presentation | [cropper](https://mobbin.com/screens/38617a81-0bde-452e-8cfa-ebaf551d3cc8), [payment](https://mobbin.com/screens/a30ce39c-845d-4e4f-ac38-e3080a802c03), [card scanning](https://mobbin.com/screens/1ca2b03b-182a-4a41-87a2-e9b0d8d09fb8), [contacts permission](https://mobbin.com/screens/14cc8f7b-ba7a-474c-ae10-e2428e659eab) | Preserve platform/provider behavior; cropper ownership is not established by its still image; provider colors/fields are not Luma tokens |

### Cross-cutting states, not additional blank templates

- **Empty:** an inline feed module, centered symbol/message, or illustration with a short action, depending on task. [home empty module](https://mobbin.com/screens/4627bc13-1c46-480f-b7b0-309b33681a5d), [empty list](https://mobbin.com/screens/9f06708e-8653-47de-85b9-c6ec855beaf1), [empty chat](https://mobbin.com/screens/5572330d-1f5e-4f71-bc60-4e83b8bd403c), [empty profile](https://mobbin.com/screens/637a62fd-1a8c-46df-9a5b-d82c15e8773b), [empty blocked list](https://mobbin.com/screens/d618492a-cae4-4eb6-915f-458362526983).
- **Loading:** action-local spinner, avatar/media spinner or row-shaped search skeleton. [submitting input](https://mobbin.com/screens/5747a2ee-5fa8-4bcf-a084-c02f85572e7e), [avatar loading](https://mobbin.com/screens/4df3aaaf-0384-4877-a033-1954afa9d1e6), [search skeleton](https://mobbin.com/screens/567ac178-b443-4ca7-84b5-8a9d2d946f0d), [media loading](https://mobbin.com/screens/418f4293-3c26-4c68-ae18-594b26a7586d).
- **Validation:** preserve entered data and put explanatory error near the input; primary action may remain disabled. [payment validation](https://mobbin.com/screens/62ffd6a0-a62b-4d6f-8f18-b8d5d11aeff0), [username validation](https://mobbin.com/screens/46b79fb5-fa43-4bcf-8d4f-aa429d98f41a).
- **Success/status:** compact top capsule or a dedicated full-height status when the workflow warrants it. [registration result](https://mobbin.com/screens/46ddb20b-c920-4d16-a798-346424d64ccc), [small success](https://mobbin.com/screens/cb998221-82f4-400d-b3b9-73426113e5ee), [settings success](https://mobbin.com/screens/a4bd3683-17ce-4f91-b19b-3e341fbcae39).
- **Blocked action:** parent context and confirmation remain visible while explaining why the action failed. [blocked deletion](https://mobbin.com/screens/2cbaa890-89c2-457d-845a-938476f4eb4b). This is a recorded source state, not a recommendation to rely only on toast text for persistent failures.
- **Disabled:** selected/processed row styling and disabled completion controls reflect readiness; the screen does not restructure for each state. [already invited](https://mobbin.com/screens/55b83aa2-840f-4620-bbc7-8ffc93df6842), [unchanged profile](https://mobbin.com/screens/484bd454-399f-42f1-b76b-2a34ad4322de), [valid username](https://mobbin.com/screens/d47e937b-06af-4226-a1a0-ae6d287d2f17).
- **Appearance:** white/black canvas, semantic foregrounds and material changes preserve hierarchy. Only the shown dark-mode families are evidenced; do not claim a dark counterpart of every one of the 393 states was supplied.

## Reusable layout grammar for the native Apple kit

### 1. Define composition before styling

Use separate recipes with shared spacing/type/color/geometry roles:

- **FlatMediaListPage:** compact native toolbar + optional summary/section header + flat media rows + honest empty/error branch.
- **MediaDetailPage:** optional crisp cover + title/meta + optional local actions + flowing sections + backdrop chosen from the actual media.
- **MediaComposerPage:** compact modal toolbar + cover + primary editable fact + semantic field groups + inline validation.
- **GroupedManagementPage:** native title + section label/helper + grouped rows + optional dangerous-action group.
- **FocusedTaskSheet:** short task heading + one field or freeform editor + keyboard-aware primary action.
- **SearchSelectionPage:** native search + row selection + empty/loading state + bounded completion action.
- **ConfirmationPresentation:** native dialog/alert by default, with domain-supplied consequence copy and destructive roles.

These recipes should own layout slots and visual roles. They should not reimplement TextField, DatePicker, Toggle, Menu, PhotosPicker, camera permission, List selection, navigation, focus, keyboard avoidance or accessibility. Compose existing kit primitives rather than adding wrappers that merely rename Apple controls.

### 2. Keep three kinds of surface distinct

- **Flat adaptive canvas:** browsing, plain identity pages, sparse prompts and lists.
- **Grouped adaptive canvas:** administrative/preferences/editing rows whose grouping expresses a relationship.
- **Media-derived ambient canvas:** media inspection/composition where actual owned imagery supplies color, protected by a contrast layer and opaque accessibility fallback.

Ambient color is content-derived, not an app-wide green/blue brand palette. The full collection contains warm, green, blue, gray and black contexts. No media means no invented atmosphere or substituted reference artwork.

### 3. Geometry: explicit user requirements supersede literal copying

The user requests **continuous Apple-like corners**, **actual nested-radius logic**, and **full pill buttons**. These are implementation rules, not recovered Luma source parameters.

- Use continuous RoundedRectangle geometry for rounded surfaces/media. Clip the actual rendered image, not a larger transparent layout frame.
- For a genuinely inset rounded child, use `innerRadius = max(0, outerRadius - actualInset)`. Derive the inset from the actual layout edge gap; do not subtract a generic token that differs from rendered padding. For unequal insets, choose a documented per-corner treatment or keep inner content unframed.
- Do not apply nested-radius arithmetic to unrelated adjacent cards, an image that overlaps a banner, an independent floating toolbar, or controls merely sharing a page.
- Text action buttons use a continuous Capsule at their actual height, including secondary/destructive/disabled states. Circular icon-only native controls can remain circles. Source action tiles and rectangular payment fields do not override this user request.
- Let native sheets, alerts, menus, pickers and platform material containers own their geometry where the OS controls presentation.

Earlier pixel-derived estimates in [the reference profile](luma-style-reference.md) remain estimates for those specific screens. The full collection is not evidence that one fixed corner radius or 240-point hero fits every family.

### 4. Hierarchy and state grammar

- Large text belongs to screen identity or media title; metadata stays secondary and compact. Calorie totals need not become oversized dashboard numerals.
- Show one dominant action per step. Secondary sources and optional work belong to quieter rows, menus or another stage.
- Keep explanation near the relevant input/choice. Keep persistent failures readable until resolved; don't rely on fleeting feedback alone.
- When a sheet changes height for the keyboard, keep context, entry and primary action visible; verify real safe areas and native scroll/focus behavior.
- Preserve content when changing state: field entered → validating → result, selected row → submitted, or context → sheet → return. The evidence supports continuity, not custom transition choreography.
- Data/permission safety and accessibility outrank visual mimicry. System selection colors, Dynamic Type, Reduce Transparency, contrast, VoiceOver and keyboard access remain native and testable.

## CalorieCam: concrete screen-by-screen mapping

This is based on the current source structures, not a claim that every current rendering has been visually revalidated. File links identify where each recipe belongs. No app code was changed by this atlas.

| Existing surface | Reference composition | Bounded change / acceptance target |
| --- | --- | --- |
| [JournalView](../Examples/CalorieCam/App/JournalView.swift), populated | [flat home](https://mobbin.com/screens/4e0f5ef3-de35-450a-b8b8-f8e7ac192e6a), [dated list](https://mobbin.com/screens/f959fe82-8c3e-4bc0-9ad1-6a289eac3845), [dark list](https://mobbin.com/screens/9f3e1d45-f117-4ff5-9b72-46ba5273a2f6) | Keep current plain List, compact title and media/text alignment. Meal name leads; date/time, kcal and origin follow. Date control and day total remain compact. No new discovery/chat tabs or event states. |
| Journal, empty/loading/read failure | [empty list](https://mobbin.com/screens/9f06708e-8653-47de-85b9-c6ec855beaf1), [actionable empty state](https://mobbin.com/screens/5572330d-1f5e-4f71-bc60-4e83b8bd403c), [loading anatomy](https://mobbin.com/screens/567ac178-b443-4ca7-84b5-8a9d2d946f0d) | Native ContentUnavailableView is appropriate. One Add Meal action. Read failure must retain explicit recovery and block unsafe overwrite. Use a spinner only while work is real; don't show fabricated diary skeleton results. |
| [CaptureMealView](../Examples/CalorieCam/App/CaptureMealView.swift), no selected image | [bounded choices](https://mobbin.com/screens/501e618c-bd44-44cf-8ef6-57bbb2d03cb0), [focused prompt](https://mobbin.com/screens/4313d4e4-9fc6-4f3f-8f88-af2eb3e62a50), [composer hierarchy](https://mobbin.com/screens/5468c5bc-943d-4211-b2f0-1f14bbf2ecda) | Make this a sparse source-choice stage: clear heading, primary Take Photo where available, secondary Choose Photo, true Enter Manually. On macOS expose Import Image clearly. Sample/demo belongs to a quieter explicit demo route. Avoid equal-weight stacks of every future action. |
| Capture, image selected | [media changed](https://mobbin.com/screens/bc829875-4790-42af-83c3-c05259f7be40), [retained composer media](https://mobbin.com/screens/7449f7d1-aa15-4f20-ab99-f0429cebf680) | Center actual chosen image and derive atmosphere from it. Show one primary next action for the configured mode. Replace/retake/remove are quieter local photo actions. Manual entry remains reachable; choosing a photo must not trigger upload. |
| Capture, estimation consent | [contextual choice sheet](https://mobbin.com/screens/e387642e-b8d9-46cb-b81d-bca0083135c7), [consequence sheet](https://mobbin.com/screens/f5955690-f166-4c6a-89fd-459d490f4b05) | Preserve existing explicit recipient/purpose disclosure and cancel choice. Only the affirmative Send Photo action starts remote analysis; demo/manual never masquerade as remote AI success. Native confirmationDialog is preferable to a handmade replica. |
| Capture, busy/error/permission denied | [action-local loading](https://mobbin.com/screens/5747a2ee-5fa8-4bcf-a084-c02f85572e7e), [retained input/error](https://mobbin.com/screens/46b79fb5-fa43-4bcf-8d4f-aa429d98f41a), [blocked operation](https://mobbin.com/screens/2cbaa890-89c2-457d-845a-938476f4eb4b) | Keep selected photo and origin visible; truthful progress; disable duplicate starts. Explain error near primary task, provide another photo/manual recovery. Camera denial is a native permission issue, not an error illustration or dead-end. |
| [MealReviewView](../Examples/CalorieCam/App/MealReviewView.swift), photo review | [media composer](https://mobbin.com/screens/5468c5bc-943d-4211-b2f0-1f14bbf2ecda), [compact label/value rows](https://mobbin.com/screens/73948dc4-cc9b-4b8d-8231-9fcc4f8b7039), [structured editing](https://mobbin.com/screens/214dddc2-24bb-45c7-bd53-04463e9ad9c6) | Keep cover + toolbar Save + semantic input groups. Group date/origin, each food's name/portion/kcal, then notes/total. Use dividers and row alignment; avoid a repeated big heading/card for each field. Place item-removal as a quiet contextual destructive action, not a competing primary. |
| Review, manual/no-photo | [grouped creation form](https://mobbin.com/screens/9b49e532-286b-438b-aa7d-d6a2153e1735), [neutral grouped page](https://mobbin.com/screens/b83035f0-7cec-4920-bc66-aff9c29b77c7) | Use deliberate no-media form composition. Do not add a decorative Luma/event poster or pretend the selected photo was analyzed. Origin label and editable values remain explicit. |
| Review, invalid/save failure | [near-field validation](https://mobbin.com/screens/46b79fb5-fa43-4bcf-8d4f-aa429d98f41a), [invalid input retained](https://mobbin.com/screens/62ffd6a0-a62b-4d6f-8f18-b8d5d11aeff0) | Preserve incomplete numeric text; show error by affected field or its group plus a concise summary if needed. Save stays unavailable when invalid; failed persistence must leave editor open and avoid duplicate save. |
| [MealDetailView](../Examples/CalorieCam/App/MealDetailView.swift), demo media | [media detail](https://mobbin.com/screens/1370090b-627d-4789-b36c-4665180a544b), [sectioned facts](https://mobbin.com/screens/2e0a1bcc-4a0e-415d-9f04-0e35a6973a66), [unboxed prose](https://mobbin.com/screens/633bd9c8-5d58-40db-a0ef-540f0718a941) | Larger media than editor, title then metadata/facts, flowing notes. Keep bundled illustration explicitly labeled sample; prefer section rules to enclosing every read-only fact in its own card. |
| Detail, real manual/remote record with no stored photo | [plain detail](https://mobbin.com/screens/81b8325a-b08d-4a15-b780-5275e02bec3b), [structured text receipt](https://mobbin.com/screens/4324a04a-33d5-41fc-8162-e007ed4e9f91) | Use an honest adaptive neutral text-detail recipe. Current privacy behavior does not persist personal photos, so do not force an empty hero or substitute sample imagery. Consider letting no-media detail honor system appearance instead of always forcing dark ambient presentation. |
| Delete meal / remove food / discard draft | [native destructive alert](https://mobbin.com/screens/493127ee-b16e-4fc5-ad70-2d0cf2a84545), [short confirmation](https://mobbin.com/screens/2dd56a6b-2aa4-4711-9cbf-2dfe1e119b34), [consequence sheet](https://mobbin.com/screens/51c86f5a-3801-4c1e-b970-6ae4d87b0b94) | Preserve native destructive/cancel semantics and exact consequence wording. No custom slide-to-delete required. Full-pill styling applies where app-owned buttons are drawn, not through replacing OS safety UI. |
| [MealPhotoCover](../Examples/CalorieCam/App/MealPhotoCover.swift) and [MealPhotoBackdrop](../Examples/CalorieCam/App/MealPhotoBackdrop.swift) | [small composer media](https://mobbin.com/screens/5468c5bc-943d-4211-b2f0-1f14bbf2ecda), [wide detail media](https://mobbin.com/screens/1370090b-627d-4789-b36c-4665180a544b) | Distinct size roles; actual-image continuous clipping; backdrop derives only from available app/user media; safe opaque/neutral fallback. Nested radius uses actual inset only if another rounded frame is introduced. |

### Proposed staged capture, with bounded behavior

1. **Choose source:** camera/library/manual; platform-appropriate import; quietly labeled sample option. Nothing uploads.
2. **Review selected photo:** crisp preview; local replace/remove; one primary next action. If AI is configured, Estimate with AI opens existing explicit consent. If not, manual entry is primary and any demo remains explicitly labeled.
3. **Estimate only after consent:** real busy/error/cancel states. A failed request retains photo and offers manual entry; it must never substitute demo results silently.
4. **Review foods:** native editable fields, origin disclosure, validation, one Save. Save persists exactly what the user reviewed; cancel/discard does not commit.
5. **Saved detail:** show actual persisted facts. Where no personal image is retained, show a text-first detail and say so where useful.

This is a bounded restructuring of current functionality. It does not authorize new photo retention, networking, model capabilities, onboarding, accounts, tabs or analytics.

## Three highest-value corrections

1. **Simplify capture into stages.** The current view simultaneously contains source, import, remove, remote analysis, manual and demo paths. Separate source choice from selected-image actions; preserve explicit upload consent and a genuine manual escape route.
2. **Use compact semantic groups in review.** Keep one coherent form with aligned row controls, purposeful section gaps and inline validation. Remove unnecessary card-within-card/heading repetition; keep Save and item removal visually distinct.
3. **Create a deliberate no-media detail recipe.** Media detail and text-only detail are different supported compositions. Preserve the no-photo-retention promise; honor neutral adaptive appearance for a record without media rather than manufacturing atmosphere.

The journal is already directionally aligned with the flat-feed grammar. Prioritize verifying its row spacing, native selected foreground and dark/light contrast rather than redesigning its information architecture.

## Evidenced sequences versus inferred behavior

| Source flow | What the recorded ordered states support | What remains unknown |
| --- | --- | --- |
| [Creating an event](https://mobbin.com/flows/6ee14a90-2007-4007-9763-9f17f90cc315) | Home → composer → media picker/change → entered title → date choice → location search → description → created event/home | Exact gesture, dismissal animation, source implementation and durations |
| [Editing an event](https://mobbin.com/flows/39f76acb-e718-4e55-8e95-8190c4743fc0) | Management → light edit form → changed instructions/unsaved state → management | Whether every field autosaves or timing of the final write outside these captures |
| [Adding sales period](https://mobbin.com/flows/13f441e3-ac37-4845-b841-75bbf69ed2c1) | Disabled sales dates → toggles enabled → date/time selection → summarized values | Platform API/OS behavior outside recorded states |
| [Switching to map view](https://mobbin.com/flows/3bcf5bf0-c1ff-4058-a696-e094876caaf5) | City/list context → map → partial then expanded results sheet | Whether the expansion shown came from dragging, tapping or programmatic change |
| [Creating a group chat](https://mobbin.com/flows/62ce1bc3-f7df-4ab2-915f-59d0fe12ee47) | People picker → selection → group identity edit → empty then populated chat | Exact message/send animation or real-time latency |
| [Adding a username](https://mobbin.com/flows/fbafd06d-dd65-47a6-a2d4-12ebe028c993) | Empty username → inline unavailable error → valid value → updated account | Validation debounce/network mechanics |
| [Deleting an account](https://mobbin.com/flows/96db4c5e-aa19-4a68-9f19-4616390d082e) | Confirmation → slide-thumb change → blocked-action error → signed-out home appears later | Complete causal path between blocker and later signed-out state; don't infer bypass/success from adjacency alone |
| [Switching to dark mode](https://mobbin.com/flows/1bca8ed6-a4fa-4645-bfea-bd91ec846e32) | Appearance choice → dark home/discovery/chat/profile | Dark behavior for layouts not shown, automatic schedule behavior or every accessibility mode |

Sequences are evidence of the screenshots that exist and their ordering, not a specification to clone unobserved transitions.

## Shared-kit specimen recommendations

Start as **native gallery recipes using the existing primitives**, not new public wrappers or business-state engines. Promote a composition to public API only after a second independent app needs the same contract.

1. **Focused task sheet specimen:** a real native sheet/NavigationStack, optional icon/short guidance, caller-supplied native field/editor content, and one caller-supplied primary action. Demonstrate keyboard-visible, disabled, pending and inline-error variants with synthetic data. The recipe owns spacing/safe-area placement and continuous/pill styling; the caller owns validation, network consent, saving and dismissal decisions.
2. **Semantic grouped editor specimen:** section label/helper outside a single existing app surface; real LabeledContent/TextField/DatePicker/Toggle rows with separators; optional per-row supporting/error text. Demonstrate one-row, multi-row, long content and accessibility text sizes. Keep minimum hit area, labels and native focus semantics. It must not know about foods, calories, accounts, provider calls or persistence.
3. **Optional-media detail specimen:** one composition with a real cover slot and ambient backdrop when supplied; a deliberate adaptive neutral branch when no media exists. Title/metadata and flowing body sections are caller-provided. Demonstrate light/dark, opaque fallback and long prose. It must not invent fallback imagery or decide whether an app retains personal photos.

Use native dialogs/alerts, search and selection directly in these specimens. A useful shared abstraction is the visual layout contract; an extra layer around every Apple control would make the kit harder to adopt and less native.

## Implementation and visual-QA gates

- Apply recipes without changing the sealed design tokens or adding app/event-specific data to generic components.
- Keep continuous corners, actual nested-radius arithmetic and full pill actions consistent with the user's latest instruction.
- Check capture in no-photo, selected-photo, busy, denied-camera and failed-estimate states. Keep primary action visible on smaller native windows and with keyboard.
- Check review with one/multiple foods, long name/portion, blank/invalid kcal, long note, failed save, keyboard focus and largest supported text sizes.
- Check diary light/dark, empty/populated, selected row, date changes, delete cancel/confirm and load failure.
- Check demo-media versus real no-photo detail separately. Do not report a sample photo as the user's retained image.
- Check Reduce Transparency, increased contrast, VoiceOver, keyboard and pointer selection. Still-image matching cannot verify these.
- Keep reference media only as research evidence. Ship original/licensed domain media and native/SF Symbol equivalents; no Luma logos, custom tab icons or event posters.

## Complete distinct-screen index

Each line represents one image actually inspected. Family labels are descriptive and may include a state-specific subfamily; they are not one reusable component per screen. Full observations, first source flow and SHA-256 are in [the inventory](luma-layout-atlas.inventory.json).

| # | Screen ID and source | Observed family | Visible state |
| ---: | --- | --- | --- |
| 001 | [a4f98553-c181-42b0-aabe-8557687f723c](https://mobbin.com/screens/a4f98553-c181-42b0-aabe-8557687f723c) | splash | launch |
| 002 | [d9fb4b91-d669-49e0-8ca3-f8b19fb7a54b](https://mobbin.com/screens/d9fb4b91-d669-49e0-8ca3-f8b19fb7a54b) | sparse_onboarding | welcome_collage |
| 003 | [501e618c-bd44-44cf-8ef6-57bbb2d03cb0](https://mobbin.com/screens/501e618c-bd44-44cf-8ef6-57bbb2d03cb0) | sparse_onboarding | authentication_choices |
| 004 | [f2970c67-067b-4a43-9416-18f656d7e723](https://mobbin.com/screens/f2970c67-067b-4a43-9416-18f656d7e723) | sparse_auth_form | email_empty_focused |
| 005 | [5b0e502b-47ea-45a2-975b-0a70be09c657](https://mobbin.com/screens/5b0e502b-47ea-45a2-975b-0a70be09c657) | sparse_auth_form | email_filled |
| 006 | [5747a2ee-5fa8-4bcf-a084-c02f85572e7e](https://mobbin.com/screens/5747a2ee-5fa8-4bcf-a084-c02f85572e7e) | sparse_auth_form | email_submitting |
| 007 | [268b31c2-6fa2-4163-bba3-854dcad7e61d](https://mobbin.com/screens/268b31c2-6fa2-4163-bba3-854dcad7e61d) | sparse_auth_form | code_empty |
| 008 | [ce0ec04c-b302-4db1-862c-789c0d7f36b9](https://mobbin.com/screens/ce0ec04c-b302-4db1-862c-789c0d7f36b9) | sparse_auth_form | code_partial |
| 009 | [f07f7dcf-13fb-40ba-84d9-a23098f94e4a](https://mobbin.com/screens/f07f7dcf-13fb-40ba-84d9-a23098f94e4a) | sparse_auth_form | code_error |
| 010 | [eb3decb4-c7b5-4cb4-a1cb-65414e6156db](https://mobbin.com/screens/eb3decb4-c7b5-4cb4-a1cb-65414e6156db) | sparse_auth_form | phone_empty |
| 011 | [2296ab9c-979d-414e-8fba-4adbef48c42c](https://mobbin.com/screens/2296ab9c-979d-414e-8fba-4adbef48c42c) | sparse_auth_form | phone_filled |
| 012 | [2c355fa7-7de0-4951-9c17-f12d04057afa](https://mobbin.com/screens/2c355fa7-7de0-4951-9c17-f12d04057afa) | sparse_auth_form | phone_code_empty |
| 013 | [39682275-e394-4d81-8270-5a69ba766680](https://mobbin.com/screens/39682275-e394-4d81-8270-5a69ba766680) | sparse_auth_form | phone_code_partial |
| 014 | [ed8d87c9-f636-44e3-ba7c-b1469d3da90e](https://mobbin.com/screens/ed8d87c9-f636-44e3-ba7c-b1469d3da90e) | sparse_onboarding | passkey_prompt |
| 015 | [00b6b045-cdfd-446d-8cd5-b461c43b9548](https://mobbin.com/screens/00b6b045-cdfd-446d-8cd5-b461c43b9548) | profile_form | empty |
| 016 | [79867884-fd27-4c4a-8087-c2cea95bc108](https://mobbin.com/screens/79867884-fd27-4c4a-8087-c2cea95bc108) | popover | profile_photo_actions |
| 017 | [38617a81-0bde-452e-8cfa-ebaf551d3cc8](https://mobbin.com/screens/38617a81-0bde-452e-8cfa-ebaf551d3cc8) | media_cropper | photo_crop |
| 018 | [4df3aaaf-0384-4877-a033-1954afa9d1e6](https://mobbin.com/screens/4df3aaaf-0384-4877-a033-1954afa9d1e6) | profile_form | photo_loading |
| 019 | [3f2bc3cc-46e9-415e-a5a5-1ab696605fed](https://mobbin.com/screens/3f2bc3cc-46e9-415e-a5a5-1ab696605fed) | profile_form | photo_set |
| 020 | [dbc57f37-ea1c-4a10-9b97-eb4b68beed26](https://mobbin.com/screens/dbc57f37-ea1c-4a10-9b97-eb4b68beed26) | profile_form | complete |
| 021 | [f8b9c208-0980-466d-a9f3-696fb4cd6876](https://mobbin.com/screens/f8b9c208-0980-466d-a9f3-696fb4cd6876) | sparse_onboarding | notification_prompt |
| 022 | [656709f6-fa80-4ccf-87e6-fde374ebba26](https://mobbin.com/screens/656709f6-fa80-4ccf-87e6-fde374ebba26) | discovery_feed | popular_events_categories |
| 023 | [4627bc13-1c46-480f-b7b0-309b33681a5d](https://mobbin.com/screens/4627bc13-1c46-480f-b7b0-309b33681a5d) | plain_feed | home_empty_personal_events |
| 024 | [4e0f5ef3-de35-450a-b8b8-f8e7ac192e6a](https://mobbin.com/screens/4e0f5ef3-de35-450a-b8b8-f8e7ac192e6a) | plain_feed | home_populated |
| 025 | [73073983-e4eb-4274-a6b6-63305d3873ca](https://mobbin.com/screens/73073983-e4eb-4274-a6b6-63305d3873ca) | plain_feed | home_scrolled |
| 026 | [9f06708e-8653-47de-85b9-c6ec855beaf1](https://mobbin.com/screens/9f06708e-8653-47de-85b9-c6ec855beaf1) | plain_list | upcoming_empty |
| 027 | [f959fe82-8c3e-4bc0-9ad1-6a289eac3845](https://mobbin.com/screens/f959fe82-8c3e-4bc0-9ad1-6a289eac3845) | plain_list | upcoming_populated |
| 028 | [50a15c31-b0e5-481e-8093-26351c32d5b6](https://mobbin.com/screens/50a15c31-b0e5-481e-8093-26351c32d5b6) | plain_list | past_populated |
| 029 | [25355146-cf9c-40a1-9558-a073775eb447](https://mobbin.com/screens/25355146-cf9c-40a1-9558-a073775eb447) | popover | event_status_filter |
| 030 | [d57a0760-5c3a-4d4c-93fe-5037f0d7b071](https://mobbin.com/screens/d57a0760-5c3a-4d4c-93fe-5037f0d7b071) | plain_list | going_filter |
| 031 | [d4822396-cb10-4aa2-b6f5-509889761fed](https://mobbin.com/screens/d4822396-cb10-4aa2-b6f5-509889761fed) | plain_list | hosting_filter |
| 032 | [5bcd93a6-d4ee-41eb-b0aa-3ea0801d248c](https://mobbin.com/screens/5bcd93a6-d4ee-41eb-b0aa-3ea0801d248c) | plain_list | waitlisted_filter |
| 033 | [186b8984-2fb9-401f-be65-4c70d5a5b999](https://mobbin.com/screens/186b8984-2fb9-401f-be65-4c70d5a5b999) | plain_list | filtered_empty |
| 034 | [1370090b-627d-4789-b36c-4665180a544b](https://mobbin.com/screens/1370090b-627d-4789-b36c-4665180a544b) | media_detail | free_event |
| 035 | [9af424b7-5e7f-4619-af62-25a763624cee](https://mobbin.com/screens/9af424b7-5e7f-4619-af62-25a763624cee) | media_detail | paid_event |
| 036 | [fc225571-3761-4e53-96d8-ae3ad2d5ecd0](https://mobbin.com/screens/fc225571-3761-4e53-96d8-ae3ad2d5ecd0) | media_detail | capacity_limited |
| 037 | [0348988b-2412-466e-a0b2-afcb45ff215b](https://mobbin.com/screens/0348988b-2412-466e-a0b2-afcb45ff215b) | media_detail | invited_event |
| 038 | [1d7d5bbb-752e-4d23-93ef-f280fb51103c](https://mobbin.com/screens/1d7d5bbb-752e-4d23-93ef-f280fb51103c) | media_detail | waitlist_open |
| 039 | [ecba9251-4434-4c20-aadf-28d41ffe5398](https://mobbin.com/screens/ecba9251-4434-4c20-aadf-28d41ffe5398) | media_detail | registered |
| 040 | [2e0a1bcc-4a0e-415d-9f04-0e35a6973a66](https://mobbin.com/screens/2e0a1bcc-4a0e-415d-9f04-0e35a6973a66) | media_detail | location_hosts_scrolled |
| 041 | [633bd9c8-5d58-40db-a0ef-540f0718a941](https://mobbin.com/screens/633bd9c8-5d58-40db-a0ef-540f0718a941) | media_detail | prose_scrolled |
| 042 | [99fee7a8-08ba-45cb-ae89-f1ce204b492c](https://mobbin.com/screens/99fee7a8-08ba-45cb-ae89-f1ce204b492c) | media_detail | formatted_prose_scrolled |
| 043 | [a8facd4e-7215-4fac-aaaa-41f1fb5f017f](https://mobbin.com/screens/a8facd4e-7215-4fac-aaaa-41f1fb5f017f) | media_detail | conduct_prose_scrolled |
| 044 | [c79aae44-4f72-47b6-98ad-bb9171d6c783](https://mobbin.com/screens/c79aae44-4f72-47b6-98ad-bb9171d6c783) | grouped_form | free_registration_empty |
| 045 | [1ae2e047-7101-407c-b404-fe9c279c8512](https://mobbin.com/screens/1ae2e047-7101-407c-b404-fe9c279c8512) | grouped_form | free_registration_complete |
| 046 | [46ddb20b-c920-4d16-a798-346424d64ccc](https://mobbin.com/screens/46ddb20b-c920-4d16-a798-346424d64ccc) | status_confirmation | registration_success |
| 047 | [fd60dbd4-6f2f-43e8-a2a8-dbf6954b3f59](https://mobbin.com/screens/fd60dbd4-6f2f-43e8-a2a8-dbf6954b3f59) | ticket_detail | qr_ticket |
| 048 | [ef73f813-15ff-482a-b856-0c324bb96b65](https://mobbin.com/screens/ef73f813-15ff-482a-b856-0c324bb96b65) | popover | registered_event_more |
| 049 | [db78c794-320c-4882-b6e4-e07c9492773f](https://mobbin.com/screens/db78c794-320c-4882-b6e4-e07c9492773f) | confirmation_sheet | leave_event_idle |
| 050 | [0abf04e7-6e1c-4331-8973-ed1344e941a2](https://mobbin.com/screens/0abf04e7-6e1c-4331-8973-ed1344e941a2) | confirmation_sheet | leave_event_dragging |
| 051 | [3befd574-deef-4fdc-92d6-fbfbfbe5bbb3](https://mobbin.com/screens/3befd574-deef-4fdc-92d6-fbfbfbe5bbb3) | confirmation_sheet | leave_event_submitting |
| 052 | [ef222d28-3226-4437-b7d3-66bac22fa061](https://mobbin.com/screens/ef222d28-3226-4437-b7d3-66bac22fa061) | media_detail | registration_cancelled_toast |
| 053 | [bf18c512-4b99-41fa-a9c2-172241c068e7](https://mobbin.com/screens/bf18c512-4b99-41fa-a9c2-172241c068e7) | ambient_composer | contact_host_empty |
| 054 | [2e4d19ee-06a1-4a80-ae1c-36af31a048e5](https://mobbin.com/screens/2e4d19ee-06a1-4a80-ae1c-36af31a048e5) | ambient_composer | contact_host_filled |
| 055 | [d0f6cb30-04d6-40ac-9d11-54f3add802a9](https://mobbin.com/screens/d0f6cb30-04d6-40ac-9d11-54f3add802a9) | media_detail | host_message_sent_toast |
| 056 | [0237b28f-cc30-4d8a-9e30-c5613c10536d](https://mobbin.com/screens/0237b28f-cc30-4d8a-9e30-c5613c10536d) | popover | event_more_unregistered |
| 057 | [2cd0558c-af99-480d-96d1-546d31c2f1c8](https://mobbin.com/screens/2cd0558c-af99-480d-96d1-546d31c2f1c8) | action_sheet | add_to_calendar |
| 058 | [90abb4d5-e5e7-4026-afc6-d2f0c3831c20](https://mobbin.com/screens/90abb4d5-e5e7-4026-afc6-d2f0c3831c20) | form_sheet | report_event_empty |
| 059 | [986857a4-d390-4cb9-9c7e-f931df992920](https://mobbin.com/screens/986857a4-d390-4cb9-9c7e-f931df992920) | form_sheet | report_event_filled |
| 060 | [054f5624-ea8a-4bf5-a3eb-ecf64a11805c](https://mobbin.com/screens/054f5624-ea8a-4bf5-a3eb-ecf64a11805c) | media_detail | report_submitted_toast |
| 061 | [d57ffe57-0592-42de-9ff8-c2e0eeb97abe](https://mobbin.com/screens/d57ffe57-0592-42de-9ff8-c2e0eeb97abe) | ticket_selector | quantity_choices |
| 062 | [6490283f-b69b-459c-b8e0-ef95ec4ee1bc](https://mobbin.com/screens/6490283f-b69b-459c-b8e0-ef95ec4ee1bc) | grouped_form | checkout_apple_pay |
| 063 | [11699e61-fc0f-4cb6-9f16-5da4afd3b6e0](https://mobbin.com/screens/11699e61-fc0f-4cb6-9f16-5da4afd3b6e0) | selector_sheet | payment_method |
| 064 | [8f8dcbad-2056-4eba-ba2a-40ed8416612a](https://mobbin.com/screens/8f8dcbad-2056-4eba-ba2a-40ed8416612a) | grouped_form | checkout_new_card |
| 065 | [a30ce39c-845d-4e4f-ac38-e3080a802c03](https://mobbin.com/screens/a30ce39c-845d-4e4f-ac38-e3080a802c03) | embedded_payment_sheet | card_empty |
| 066 | [62ffd6a0-a62b-4d6f-8f18-b8d5d11aeff0](https://mobbin.com/screens/62ffd6a0-a62b-4d6f-8f18-b8d5d11aeff0) | embedded_payment_sheet | card_invalid |
| 067 | [2b87d56e-02ec-48c1-b0de-9630222bdbc3](https://mobbin.com/screens/2b87d56e-02ec-48c1-b0de-9630222bdbc3) | embedded_payment_sheet | card_filled |
| 068 | [7d8ed597-6376-4c45-b146-6ded1d80316c](https://mobbin.com/screens/7d8ed597-6376-4c45-b146-6ded1d80316c) | embedded_payment_sheet | card_processing |
| 069 | [67053625-fc89-4c2a-98ff-7d6e5cca1820](https://mobbin.com/screens/67053625-fc89-4c2a-98ff-7d6e5cca1820) | embedded_payment_sheet | payment_success |
| 070 | [551f36c2-b64d-4848-9df2-700f4ace69f0](https://mobbin.com/screens/551f36c2-b64d-4848-9df2-700f4ace69f0) | status_confirmation | paid_registration_success |
| 071 | [1e270e2e-30a4-4394-84cd-bf48223528c1](https://mobbin.com/screens/1e270e2e-30a4-4394-84cd-bf48223528c1) | media_detail | paid_event_registered |
| 072 | [1ca2b03b-182a-4a41-87a2-e9b0d8d09fb8](https://mobbin.com/screens/1ca2b03b-182a-4a41-87a2-e9b0d8d09fb8) | embedded_camera | card_scanner |
| 073 | [960fd6f0-1af8-4418-8d3c-4870d5c3f6ba](https://mobbin.com/screens/960fd6f0-1af8-4418-8d3c-4870d5c3f6ba) | ticket_selector | fixed_choice_standard |
| 074 | [51d03cab-be09-4ba6-bc11-34c007f9fed1](https://mobbin.com/screens/51d03cab-be09-4ba6-bc11-34c007f9fed1) | ticket_selector | fixed_choice_community |
| 075 | [ff8bd7fd-4a6e-4d7a-81b0-009dcc75c48f](https://mobbin.com/screens/ff8bd7fd-4a6e-4d7a-81b0-009dcc75c48f) | grouped_form | checkout_terms_unchecked |
| 076 | [efa77a29-7e68-4848-bf7f-8fd245f35fd5](https://mobbin.com/screens/efa77a29-7e68-4848-bf7f-8fd245f35fd5) | content_sheet | event_terms |
| 077 | [0d58b1a9-cc52-4d81-91c9-7e8367c18d8b](https://mobbin.com/screens/0d58b1a9-cc52-4d81-91c9-7e8367c18d8b) | grouped_form | checkout_terms_checked |
| 078 | [9d434fbd-38f6-4f9c-ac2c-09cb0d4e3b25](https://mobbin.com/screens/9d434fbd-38f6-4f9c-ac2c-09cb0d4e3b25) | invitation_sheet | invitation_minimal |
| 079 | [77d6c004-94c7-4e19-b458-756bcd35dec7](https://mobbin.com/screens/77d6c004-94c7-4e19-b458-756bcd35dec7) | invitation_sheet | invitation_message |
| 080 | [f810eb25-184f-41f2-999e-e5a3acd17037](https://mobbin.com/screens/f810eb25-184f-41f2-999e-e5a3acd17037) | confirmation_sheet | decline_invite_optional_note |
| 081 | [dd23a717-c1a8-4586-b4f5-d501f5302fb5](https://mobbin.com/screens/dd23a717-c1a8-4586-b4f5-d501f5302fb5) | form_sheet | decline_note_empty |
| 082 | [a951f57f-8626-4f11-82e5-456c0a93a9f8](https://mobbin.com/screens/a951f57f-8626-4f11-82e5-456c0a93a9f8) | form_sheet | decline_note_filled |
| 083 | [5830e4a6-ceae-4573-b67b-9cc034f238b8](https://mobbin.com/screens/5830e4a6-ceae-4573-b67b-9cc034f238b8) | media_detail | invitation_declined_toast |
| 084 | [7bffdd43-e47c-4345-a8e4-3e78ae61ad66](https://mobbin.com/screens/7bffdd43-e47c-4345-a8e4-3e78ae61ad66) | registration_confirmation | invite_accept_review |
| 085 | [d690f48e-ff83-444a-88b8-2f0d4b7fc17e](https://mobbin.com/screens/d690f48e-ff83-444a-88b8-2f0d4b7fc17e) | status_confirmation | invitation_registered |
| 086 | [48182692-f883-454f-8a78-112eb49c8240](https://mobbin.com/screens/48182692-f883-454f-8a78-112eb49c8240) | grouped_form | waitlist_questions_empty |
| 087 | [572df11c-e77a-4b15-8dda-2aaea71bb0ab](https://mobbin.com/screens/572df11c-e77a-4b15-8dda-2aaea71bb0ab) | grouped_form | waitlist_questions_filled |
| 088 | [e9a81099-2204-4c55-8296-7364e90947f1](https://mobbin.com/screens/e9a81099-2204-4c55-8296-7364e90947f1) | grouped_form | waitlist_lower_questions_empty |
| 089 | [fbac8eac-b349-45f8-bac4-18fb28ee7df6](https://mobbin.com/screens/fbac8eac-b349-45f8-bac4-18fb28ee7df6) | grouped_form | waitlist_ready |
| 090 | [a1c672f9-d4d3-4326-bc8d-26f867e223b3](https://mobbin.com/screens/a1c672f9-d4d3-4326-bc8d-26f867e223b3) | status_confirmation | waitlist_joined |
| 091 | [3fa03c62-92d7-4913-8e49-ea5bea6be281](https://mobbin.com/screens/3fa03c62-92d7-4913-8e49-ea5bea6be281) | media_detail | waitlisted |
| 092 | [f46be2d3-9980-4fd3-a773-806141d5206b](https://mobbin.com/screens/f46be2d3-9980-4fd3-a773-806141d5206b) | multi_select_list | registration_choices_none_selected |
| 093 | [2fbfa2de-44b3-444b-b2ee-5b3dc459facf](https://mobbin.com/screens/2fbfa2de-44b3-444b-b2ee-5b3dc459facf) | multi_select_list | registration_choice_selected |
| 094 | [bfd3ee00-4aed-410e-b829-993ad1b10a22](https://mobbin.com/screens/bfd3ee00-4aed-410e-b829-993ad1b10a22) | profile_detail | individual_host |
| 095 | [2cbe9585-2ae8-4bb8-a49d-ce14a1335ffc](https://mobbin.com/screens/2cbe9585-2ae8-4bb8-a49d-ce14a1335ffc) | profile_detail | organization_host |
| 096 | [f270db28-f299-4ca2-b73d-906ff7441466](https://mobbin.com/screens/f270db28-f299-4ca2-b73d-906ff7441466) | profile_detail | host_profile_scrolled |
| 097 | [d2c8239e-8508-4926-9914-bea1e654ea3b](https://mobbin.com/screens/d2c8239e-8508-4926-9914-bea1e654ea3b) | popover | profile_more |
| 098 | [e37bcb83-0b99-49fc-8fcc-b9551d6ebe62](https://mobbin.com/screens/e37bcb83-0b99-49fc-8fcc-b9551d6ebe62) | confirmation_sheet | block_user |
| 099 | [04a4467c-cd8c-480e-ba63-ec9769fb25b6](https://mobbin.com/screens/04a4467c-cd8c-480e-ba63-ec9769fb25b6) | profile_detail | blocked_user |
| 100 | [074423fd-6063-4f5d-a1a1-21d338ba1e77](https://mobbin.com/screens/074423fd-6063-4f5d-a1a1-21d338ba1e77) | form_sheet | report_user_empty_block_on |
| 101 | [706ea925-32ca-4e4e-9b83-f72b301d45c3](https://mobbin.com/screens/706ea925-32ca-4e4e-9b83-f72b301d45c3) | form_sheet | report_user_filled_block_off |
| 102 | [d81032fe-9539-467e-aed2-4ce180d05e93](https://mobbin.com/screens/d81032fe-9539-467e-aed2-4ce180d05e93) | profile_detail | user_reported_toast |
| 103 | [28e51141-1eb1-46f6-8159-cf20fd99a303](https://mobbin.com/screens/28e51141-1eb1-46f6-8159-cf20fd99a303) | access_gate_sheet | guest_list_registration_required |
| 104 | [63b62ea3-d066-4674-8619-36520bbf5ecd](https://mobbin.com/screens/63b62ea3-d066-4674-8619-36520bbf5ecd) | people_list | guest_list |
| 105 | [6a0275b3-c1f4-40c5-8541-6712d410b11b](https://mobbin.com/screens/6a0275b3-c1f4-40c5-8541-6712d410b11b) | people_search | guest_search_focused |
| 106 | [62d5b671-19b5-4322-b133-6f22c9276155](https://mobbin.com/screens/62d5b671-19b5-4322-b133-6f22c9276155) | people_search | guest_search_empty_result |
| 107 | [884844ac-ce99-4626-925e-c33f9333d35a](https://mobbin.com/screens/884844ac-ce99-4626-925e-c33f9333d35a) | people_search | guest_search_results |
| 108 | [e24988fc-1a87-404c-90ca-a59597c5e7d5](https://mobbin.com/screens/e24988fc-1a87-404c-90ca-a59597c5e7d5) | share_sheet | share_preview |
| 109 | [20efb33d-995e-418a-a15a-df9e3528c694](https://mobbin.com/screens/20efb33d-995e-418a-a15a-df9e3528c694) | share_sheet | share_copied |
| 110 | [5468c5bc-943d-4211-b2f0-1f14bbf2ecda](https://mobbin.com/screens/5468c5bc-943d-4211-b2f0-1f14bbf2ecda) | ambient_composer | event_create_initial |
| 111 | [e0c7671f-8b47-4807-95fa-7dcffffa8a98](https://mobbin.com/screens/e0c7671f-8b47-4807-95fa-7dcffffa8a98) | media_picker | cover_categories |
| 112 | [89fc7b20-9813-4028-98b5-2c13913b8476](https://mobbin.com/screens/89fc7b20-9813-4028-98b5-2c13913b8476) | media_picker | cover_grid |
| 113 | [bc829875-4790-42af-83c3-c05259f7be40](https://mobbin.com/screens/bc829875-4790-42af-83c3-c05259f7be40) | ambient_composer | cover_selected_empty_title |
| 114 | [3f460684-6afa-4787-acee-a529754d4a11](https://mobbin.com/screens/3f460684-6afa-4787-acee-a529754d4a11) | ambient_composer | event_title_filled |
| 115 | [d05ce40a-de15-49ca-8c34-84f817d39f27](https://mobbin.com/screens/d05ce40a-de15-49ca-8c34-84f817d39f27) | popover | start_date_picker_open |
| 116 | [f12cfaab-8902-45af-b741-1098fdb4857f](https://mobbin.com/screens/f12cfaab-8902-45af-b741-1098fdb4857f) | popover | start_date_changed |
| 117 | [4e1e7204-ddd2-4836-b464-978187ef725e](https://mobbin.com/screens/4e1e7204-ddd2-4836-b464-978187ef725e) | ambient_composer | schedule_set |
| 118 | [61e0ef6d-c8c4-4bf8-b4e7-e48876cdb850](https://mobbin.com/screens/61e0ef6d-c8c4-4bf8-b4e7-e48876cdb850) | location_search | location_empty_focused |
| 119 | [9316b7b9-5dc7-466f-b743-67b67c66235e](https://mobbin.com/screens/9316b7b9-5dc7-466f-b743-67b67c66235e) | location_search | location_results |
| 120 | [7449f7d1-aa15-4f20-ab99-f0429cebf680](https://mobbin.com/screens/7449f7d1-aa15-4f20-ab99-f0429cebf680) | ambient_composer | location_set |
| 121 | [71384102-1aa3-4118-b880-e30a166f733b](https://mobbin.com/screens/71384102-1aa3-4118-b880-e30a166f733b) | grouped_form | event_options_scrolled |
| 122 | [041aea5f-25e3-4507-b610-13bec319f81a](https://mobbin.com/screens/041aea5f-25e3-4507-b610-13bec319f81a) | grouped_form | location_privacy_on |
| 123 | [55216a03-d6c2-4bb5-92b0-2a8b4ae8174b](https://mobbin.com/screens/55216a03-d6c2-4bb5-92b0-2a8b4ae8174b) | ambient_composer | description_empty |
| 124 | [afc1b6d3-f94f-4a07-812d-517c1b35ee6a](https://mobbin.com/screens/afc1b6d3-f94f-4a07-812d-517c1b35ee6a) | ambient_composer | description_filled |
| 125 | [4aa6442a-6db4-4e3b-b123-fbfcda382aa6](https://mobbin.com/screens/4aa6442a-6db4-4e3b-b123-fbfcda382aa6) | grouped_form | event_ready_scrolled |
| 126 | [8f9dc2c6-c9a6-43d6-8a93-bb15606f9c74](https://mobbin.com/screens/8f9dc2c6-c9a6-43d6-8a93-bb15606f9c74) | status_confirmation | event_created |
| 127 | [571bccaf-ded6-4ff9-818b-1a00356d7e85](https://mobbin.com/screens/571bccaf-ded6-4ff9-818b-1a00356d7e85) | plain_feed | home_created_event |
| 128 | [88faa85c-c417-4cef-958e-44a72049d711](https://mobbin.com/screens/88faa85c-c417-4cef-958e-44a72049d711) | selector_sheet | calendar_choice |
| 129 | [fcf37b06-8622-4238-9f2b-abf386cb0bd9](https://mobbin.com/screens/fcf37b06-8622-4238-9f2b-abf386cb0bd9) | form_sheet | add_link_empty |
| 130 | [2f671c8f-b154-4f75-8d18-6e75dc8b60fc](https://mobbin.com/screens/2f671c8f-b154-4f75-8d18-6e75dc8b60fc) | form_sheet | add_link_filled |
| 131 | [3caaa6a0-e03a-4341-b7d4-a8448cda1c8a](https://mobbin.com/screens/3caaa6a0-e03a-4341-b7d4-a8448cda1c8a) | ambient_composer | link_inserted |
| 132 | [2e817125-c398-4796-892a-459baf96c18a](https://mobbin.com/screens/2e817125-c398-4796-892a-459baf96c18a) | ambient_composer | bullet_style_active |
| 133 | [6d2c60ff-e78c-48e0-a2e2-3761b6724807](https://mobbin.com/screens/6d2c60ff-e78c-48e0-a2e2-3761b6724807) | ambient composer | rich-text editing with keyboard |
| 134 | [899a87ce-43b6-4b19-bded-b875524110f2](https://mobbin.com/screens/899a87ce-43b6-4b19-bded-b875524110f2) | sheet | AI description input, empty |
| 135 | [ead28b22-5809-4b5e-b958-c42c02840d1b](https://mobbin.com/screens/ead28b22-5809-4b5e-b958-c42c02840d1b) | sheet | AI description input, filled |
| 136 | [9bd81451-bb74-49fe-8cd9-f447155f4900](https://mobbin.com/screens/9bd81451-bb74-49fe-8cd9-f447155f4900) | sheet | generated-description review |
| 137 | [28a12c18-ca17-4ac5-8a63-55bb6128844d](https://mobbin.com/screens/28a12c18-ca17-4ac5-8a63-55bb6128844d) | ambient composer | accepted AI description editing |
| 138 | [523d4c78-fe42-490f-a76a-b1aaa2dd3e06](https://mobbin.com/screens/523d4c78-fe42-490f-a76a-b1aaa2dd3e06) | sparse prompt | ticket payments setup |
| 139 | [8326b33e-d074-4de7-83bd-3906be0bbfe1](https://mobbin.com/screens/8326b33e-d074-4de7-83bd-3906be0bbfe1) | grouped form/settings | free-ticket choice |
| 140 | [73948dc4-cc9b-4b8d-8231-9fcc4f8b7039](https://mobbin.com/screens/73948dc4-cc9b-4b8d-8231-9fcc4f8b7039) | grouped form/settings | paid fixed-price ticket |
| 141 | [1ecff26e-e95f-4561-94e1-aa91e4fd3b6a](https://mobbin.com/screens/1ecff26e-e95f-4561-94e1-aa91e4fd3b6a) | grouped form/settings | flexible pricing enabled |
| 142 | [36ed922f-beb1-4319-824e-75e35e644fd4](https://mobbin.com/screens/36ed922f-beb1-4319-824e-75e35e644fd4) | grouped form/settings | flexible pricing values edited |
| 143 | [8a0ca0a7-30b0-4dac-b017-76f9dd01fda1](https://mobbin.com/screens/8a0ca0a7-30b0-4dac-b017-76f9dd01fda1) | selector | currency picker sheet |
| 144 | [7e469cd2-203e-4f34-a7c0-dcc3170d45d7](https://mobbin.com/screens/7e469cd2-203e-4f34-a7c0-dcc3170d45d7) | grouped form/settings | currency changed to euro |
| 145 | [9ad2f094-5389-4cfc-89a7-133d6f71739a](https://mobbin.com/screens/9ad2f094-5389-4cfc-89a7-133d6f71739a) | ambient composer | event creation, lower form with paid ticket |
| 146 | [e544b3ed-1306-4daf-948e-a29d5f9e8497](https://mobbin.com/screens/e544b3ed-1306-4daf-948e-a29d5f9e8497) | sheet | payment-provider setup |
| 147 | [e387642e-b8d9-46cb-b81d-bca0083135c7](https://mobbin.com/screens/e387642e-b8d9-46cb-b81d-bca0083135c7) | sheet | event visibility, public selected |
| 148 | [ada550e5-4c5f-4b3a-8f94-9ccdfb9ebb8e](https://mobbin.com/screens/ada550e5-4c5f-4b3a-8f94-9ccdfb9ebb8e) | sheet | event visibility, private selected |
| 149 | [cbff9b3b-04fd-4283-9da1-ddd28b30f231](https://mobbin.com/screens/cbff9b3b-04fd-4283-9da1-ddd28b30f231) | ambient composer | event creation, private visibility applied |
| 150 | [a5c932a1-b0c5-46dd-911e-9b9188faf5b6](https://mobbin.com/screens/a5c932a1-b0c5-46dd-911e-9b9188faf5b6) | sheet | capacity numeric editing, 50 |
| 151 | [9e36cfee-f1f3-44dc-9c31-aefa6574d291](https://mobbin.com/screens/9e36cfee-f1f3-44dc-9c31-aefa6574d291) | sheet | capacity numeric editing, 25 |
| 152 | [658104d3-3dad-4916-9d21-6e2cab3362df](https://mobbin.com/screens/658104d3-3dad-4916-9d21-6e2cab3362df) | ambient composer | event creation, capacity applied |
| 153 | [28c216de-6be2-42bf-8cac-265d32b201a0](https://mobbin.com/screens/28c216de-6be2-42bf-8cac-265d32b201a0) | media detail | hosted event top, future event |
| 154 | [70967148-29b2-46aa-b4ec-15063f3bf5c8](https://mobbin.com/screens/70967148-29b2-46aa-b4ec-15063f3bf5c8) | media detail | hosted event top, check-in available |
| 155 | [81b8f834-de64-40a6-9b10-e7498adcbb9a](https://mobbin.com/screens/81b8f834-de64-40a6-9b10-e7498adcbb9a) | media detail | hosted event middle, zero guests |
| 156 | [4cc6eeaa-6e30-42fe-b492-f21ec5784f36](https://mobbin.com/screens/4cc6eeaa-6e30-42fe-b492-f21ec5784f36) | media detail | hosted event middle, guests present |
| 157 | [288239d1-2866-433a-83a1-e1f1263a20e3](https://mobbin.com/screens/288239d1-2866-433a-83a1-e1f1263a20e3) | media detail | hosted event middle, check-in progress |
| 158 | [9f0db80b-bcd1-49bf-bd25-53ea2e3a2217](https://mobbin.com/screens/9f0db80b-bcd1-49bf-bd25-53ea2e3a2217) | media detail | hosted event lower, blast preview |
| 159 | [1f7b726f-4b1f-433e-9cfc-a50dd6ef4411](https://mobbin.com/screens/1f7b726f-4b1f-433e-9cfc-a50dd6ef4411) | selector | invite people, no selection |
| 160 | [a57ee01f-d575-4076-b9ed-2fb51c24ae1c](https://mobbin.com/screens/a57ee01f-d575-4076-b9ed-2fb51c24ae1c) | selector | invite people, two selected |
| 161 | [70e41b21-68b3-4569-9e47-625cb4883baf](https://mobbin.com/screens/70e41b21-68b3-4569-9e47-625cb4883baf) | selector | invite events empty state |
| 162 | [03d85c9c-010c-4791-a20e-d442de4adebf](https://mobbin.com/screens/03d85c9c-010c-4791-a20e-d442de4adebf) | sheet | invite message preview |
| 163 | [ec0dd672-8efa-43f0-aa91-3f1ef9f4f692](https://mobbin.com/screens/ec0dd672-8efa-43f0-aa91-3f1ef9f4f692) | sheet | invite message preview with optional copy |
| 164 | [900835d1-2340-42ad-8c66-efaca8a27eac](https://mobbin.com/screens/900835d1-2340-42ad-8c66-efaca8a27eac) | media detail | invitation success feedback |
| 165 | [55b83aa2-840f-4620-bbc7-8ffc93df6842](https://mobbin.com/screens/55b83aa2-840f-4620-bbc7-8ffc93df6842) | selector | people already invited |
| 166 | [f3fe47f2-52c0-4b72-955f-c629cc8b85e2](https://mobbin.com/screens/f3fe47f2-52c0-4b72-955f-c629cc8b85e2) | sheet | event-blast explanation |
| 167 | [fb2ccbd7-04a5-432f-aadd-2718fdd60c4c](https://mobbin.com/screens/fb2ccbd7-04a5-432f-aadd-2718fdd60c4c) | ambient composer | new blast, empty keyboard state |
| 168 | [29ac75d5-0985-4764-83a3-d83f337f3714](https://mobbin.com/screens/29ac75d5-0985-4764-83a3-d83f337f3714) | ambient composer | new blast, filled keyboard state |
| 169 | [09d61e3f-9820-4fd3-b89d-f3b392464513](https://mobbin.com/screens/09d61e3f-9820-4fd3-b89d-f3b392464513) | message detail | posted event blast |
| 170 | [97fc81b7-4fed-46d0-a019-aa70a9a3ee02](https://mobbin.com/screens/97fc81b7-4fed-46d0-a019-aa70a9a3ee02) | grouped form/settings | manage-event menu, upper portion |
| 171 | [d2774c50-d77d-4ca1-a28b-54e747c0cef2](https://mobbin.com/screens/d2774c50-d77d-4ca1-a28b-54e747c0cef2) | grouped form/settings | manage-event menu, lower portion |
| 172 | [214dddc2-24bb-45c7-bd53-04463e9ad9c6](https://mobbin.com/screens/214dddc2-24bb-45c7-bd53-04463e9ad9c6) | grouped form/settings | edit-event form, top |
| 173 | [8a1a88c8-f4bd-486a-b3e3-074efea19a11](https://mobbin.com/screens/8a1a88c8-f4bd-486a-b3e3-074efea19a11) | grouped form/settings | edit-event form, location/details |
| 174 | [142dbdee-2b54-4be4-aa5d-cc76911eeff5](https://mobbin.com/screens/142dbdee-2b54-4be4-aa5d-cc76911eeff5) | grouped form/settings | edit-event unsaved changes |
| 175 | [1ff63143-9abc-4ad9-a323-9e351ba8500c](https://mobbin.com/screens/1ff63143-9abc-4ad9-a323-9e351ba8500c) | grouped form/settings | returned management menu |
| 176 | [adc89d9f-a056-4064-860b-9c5df10ee581](https://mobbin.com/screens/adc89d9f-a056-4064-860b-9c5df10ee581) | sheet | location-instructions editor, empty |
| 177 | [a981e492-f6a5-4acd-9fed-c5122921efe6](https://mobbin.com/screens/a981e492-f6a5-4acd-9fed-c5122921efe6) | sheet | location-instructions editor, filled |
| 178 | [66ceefae-9c3f-4a91-bb84-40d7ed83ab72](https://mobbin.com/screens/66ceefae-9c3f-4a91-bb84-40d7ed83ab72) | plain list | guest list empty |
| 179 | [bd574eac-7241-4cb6-b69f-1d2e671a4846](https://mobbin.com/screens/bd574eac-7241-4cb6-b69f-1d2e671a4846) | plain list | guest list populated |
| 180 | [e1c3b363-22f2-4301-b5a1-60a82646f4d3](https://mobbin.com/screens/e1c3b363-22f2-4301-b5a1-60a82646f4d3) | plain list | guest list checked-in filter |
| 181 | [07fa77cb-8f6f-40e1-aba9-1eafb60954bf](https://mobbin.com/screens/07fa77cb-8f6f-40e1-aba9-1eafb60954bf) | camera | QR check-in scanner, idle |
| 182 | [9dd54074-60d0-4ca4-8723-fc41ad08b5ef](https://mobbin.com/screens/9dd54074-60d0-4ca4-8723-fc41ad08b5ef) | sheet | guest detail before manual check-in |
| 183 | [e02a3aa3-e02c-4019-82cf-163fa8b1eafd](https://mobbin.com/screens/e02a3aa3-e02c-4019-82cf-163fa8b1eafd) | plain list | manual check-in success |
| 184 | [a13a3b9d-f6e1-414f-aad3-433c4b469bae](https://mobbin.com/screens/a13a3b9d-f6e1-414f-aad3-433c4b469bae) | sheet | guest detail with checked-in history |
| 185 | [e5ec52a0-6134-4aec-bf98-e531243e8b5f](https://mobbin.com/screens/e5ec52a0-6134-4aec-bf98-e531243e8b5f) | popover | guest action menu over detail sheet |
| 186 | [44fc60d9-f628-44a8-a3a0-40c2f0d7a9ab](https://mobbin.com/screens/44fc60d9-f628-44a8-a3a0-40c2f0d7a9ab) | sheet | guest marked not going |
| 187 | [dcc1e158-4cd0-40f4-ac72-ffe9eb3b1ee2](https://mobbin.com/screens/dcc1e158-4cd0-40f4-ac72-ffe9eb3b1ee2) | plain list | guest list after status update |
| 188 | [24c6bdde-eb8c-4024-bd8b-150a1f05ca21](https://mobbin.com/screens/24c6bdde-eb8c-4024-bd8b-150a1f05ca21) | popover | guest sorting options |
| 189 | [714cff52-5dbc-4a9b-82da-fb910da4e4dc](https://mobbin.com/screens/714cff52-5dbc-4a9b-82da-fb910da4e4dc) | plain list | guest list sorted by name |
| 190 | [c79be8a7-a525-40ab-87d7-3167e2180b63](https://mobbin.com/screens/c79be8a7-a525-40ab-87d7-3167e2180b63) | sheet | scanned guest ready to check in |
| 191 | [6f2ca8bd-8c6a-4bf5-9ac7-7e2336d30ef9](https://mobbin.com/screens/6f2ca8bd-8c6a-4bf5-9ac7-7e2336d30ef9) | camera | QR check-in success |
| 192 | [b3855634-4b60-47a1-bb1e-e22354345480](https://mobbin.com/screens/b3855634-4b60-47a1-bb1e-e22354345480) | sheet | scanner options, standard mode |
| 193 | [6a894c30-4039-4fef-b440-0e537b4ea7d4](https://mobbin.com/screens/6a894c30-4039-4fef-b440-0e537b4ea7d4) | sheet | scanner options, express mode |
| 194 | [d5b5b94c-435b-4a1b-b8d7-060bebec13a1](https://mobbin.com/screens/d5b5b94c-435b-4a1b-b8d7-060bebec13a1) | popover | camera selector over options sheet |
| 195 | [476f6569-78af-4b5d-b614-cc63df1ae78a](https://mobbin.com/screens/476f6569-78af-4b5d-b614-cc63df1ae78a) | sheet | scanner options, front camera |
| 196 | [7ac776b3-dea8-4952-8af4-16b9b847c669](https://mobbin.com/screens/7ac776b3-dea8-4952-8af4-16b9b847c669) | grouped form/settings | hosts list, creator only |
| 197 | [ca45dd1e-4879-4f29-9714-5b7a49087aad](https://mobbin.com/screens/ca45dd1e-4879-4f29-9714-5b7a49087aad) | grouped form/settings | hosts list, two people |
| 198 | [0340b1bc-5a77-4416-a778-6eac3abb59c2](https://mobbin.com/screens/0340b1bc-5a77-4416-a778-6eac3abb59c2) | grouped form/settings | hosts list, creator-only variant |
| 199 | [13bd70cb-f355-4d13-81b7-221ee05e212d](https://mobbin.com/screens/13bd70cb-f355-4d13-81b7-221ee05e212d) | selector | add-host person picker |
| 200 | [54c36968-7daa-4e8c-ba87-db5507d96aca](https://mobbin.com/screens/54c36968-7daa-4e8c-ba87-db5507d96aca) | sheet | add-host confirmation, manager |
| 201 | [a8b0c3b5-01e6-4018-b0fa-2657153b856e](https://mobbin.com/screens/a8b0c3b5-01e6-4018-b0fa-2657153b856e) | sheet | add-host confirmation, non-manager |
| 202 | [80615145-f8f6-4e0c-80a0-6ee8e38bd1f0](https://mobbin.com/screens/80615145-f8f6-4e0c-80a0-6ee8e38bd1f0) | sortable list | reorder hosts, ready |
| 203 | [af1548e3-2411-4dc7-82cc-334c80e29f36](https://mobbin.com/screens/af1548e3-2411-4dc7-82cc-334c80e29f36) | sortable list | reorder hosts, drag in progress |
| 204 | [d26a9817-e7cf-4446-8b58-8e4f4412611c](https://mobbin.com/screens/d26a9817-e7cf-4446-8b58-8e4f4412611c) | sortable list | reorder hosts, reordered preview |
| 205 | [a19eef6b-882a-4665-9e90-e9574cbb9ff2](https://mobbin.com/screens/a19eef6b-882a-4665-9e90-e9574cbb9ff2) | grouped form/settings | hosts reordered, settled |
| 206 | [644ad2bd-7f76-494b-9352-ed614fc4edb5](https://mobbin.com/screens/644ad2bd-7f76-494b-9352-ed614fc4edb5) | popover | host permission and removal menu |
| 207 | [cf93c92d-0835-4882-8a3e-68e8e4971d1b](https://mobbin.com/screens/cf93c92d-0835-4882-8a3e-68e8e4971d1b) | sheet | remove-host destructive confirmation |
| 208 | [eeccb082-0e2b-4646-a7e1-19b80d01b334](https://mobbin.com/screens/eeccb082-0e2b-4646-a7e1-19b80d01b334) | grouped form/settings | check-in options, top |
| 209 | [b9d46a51-fcbd-47a0-8e08-c362963829a4](https://mobbin.com/screens/b9d46a51-fcbd-47a0-8e08-c362963829a4) | grouped form/settings | check-in options, lower scroll |
| 210 | [e301dd54-aeed-4048-9677-eb498fbf0745](https://mobbin.com/screens/e301dd54-aeed-4048-9677-eb498fbf0745) | grouped form/settings | access and ticketing, default |
| 211 | [1cd518e1-511f-4a9f-a9c4-225a75fca3a6](https://mobbin.com/screens/1cd518e1-511f-4a9f-a9c4-225a75fca3a6) | grouped form/settings | group registration enabled |
| 212 | [31952f6c-2f6b-445c-8e53-efccdd0e0670](https://mobbin.com/screens/31952f6c-2f6b-445c-8e53-efccdd0e0670) | grouped form/settings | access and ticketing, two ticket types |
| 213 | [9b49e532-286b-438b-aa7d-d6a2153e1735](https://mobbin.com/screens/9b49e532-286b-438b-aa7d-d6a2153e1735) | grouped form/settings | new ticket type, empty |
| 214 | [8c826e22-11c5-48f3-aacd-bd3a4a441687](https://mobbin.com/screens/8c826e22-11c5-48f3-aacd-bd3a4a441687) | grouped form/settings | new ticket type, filled |
| 215 | [927265c2-820b-430b-ab39-1f0544b25b1d](https://mobbin.com/screens/927265c2-820b-430b-ab39-1f0544b25b1d) | grouped form/settings | sales period disabled |
| 216 | [6fec916d-65a7-4c35-a7c4-2778239c1a90](https://mobbin.com/screens/6fec916d-65a7-4c35-a7c4-2778239c1a90) | grouped form/settings | sales period enabled |
| 217 | [950f9d3f-7a52-4f5c-b26a-037c7bdff49b](https://mobbin.com/screens/950f9d3f-7a52-4f5c-b26a-037c7bdff49b) | popover | sales-end inline calendar open |
| 218 | [cc6f97e5-9fcd-40ff-9d4f-43ddbf72af2a](https://mobbin.com/screens/cc6f97e5-9fcd-40ff-9d4f-43ddbf72af2a) | grouped form/settings | sales-end date applied |
| 219 | [12809356-69fc-49ae-a22f-865c7d255454](https://mobbin.com/screens/12809356-69fc-49ae-a22f-865c7d255454) | sortable list | ticket types, initial order |
| 220 | [cdb57153-00a2-4cb4-a717-4acaaef4a533](https://mobbin.com/screens/cdb57153-00a2-4cb4-a717-4acaaef4a533) | sortable list | ticket type drag in progress |
| 221 | [4ac07c85-5d78-4f2a-b057-35ee37d94595](https://mobbin.com/screens/4ac07c85-5d78-4f2a-b057-35ee37d94595) | sortable list | ticket types, reordered |
| 222 | [bb223e32-3a2d-4fc4-84cc-13bdcee1f2a2](https://mobbin.com/screens/bb223e32-3a2d-4fc4-84cc-13bdcee1f2a2) | grouped form/settings | ticket order reflected in management |
| 223 | [8e1b84e7-3d37-46f9-883e-63ef8d24789a](https://mobbin.com/screens/8e1b84e7-3d37-46f9-883e-63ef8d24789a) | sparse prompt | coupons empty state |
| 224 | [578f40fb-dd16-4c53-8149-3cc7a2919f22](https://mobbin.com/screens/578f40fb-dd16-4c53-8149-3cc7a2919f22) | grouped form/settings | coupons populated |
| 225 | [59e7cbdd-ab25-4395-9b12-b2d334f61279](https://mobbin.com/screens/59e7cbdd-ab25-4395-9b12-b2d334f61279) | grouped form/settings | create coupon, unlimited free type |
| 226 | [56d08edc-41ff-4c38-a383-28be48308fb6](https://mobbin.com/screens/56d08edc-41ff-4c38-a383-28be48308fb6) | grouped form/settings | create coupon, usage limit enabled |
| 227 | [57dfda66-0ef5-4f78-a345-2064a7d313f1](https://mobbin.com/screens/57dfda66-0ef5-4f78-a345-2064a7d313f1) | grouped form/settings | create coupon, percentage amount empty |
| 228 | [092a8476-ebca-4cd2-8ceb-bdc4c0161db5](https://mobbin.com/screens/092a8476-ebca-4cd2-8ceb-bdc4c0161db5) | grouped form/settings | create coupon, percentage completed |
| 229 | [b2e4218a-27bf-475f-97b9-b2ffaaa19cc0](https://mobbin.com/screens/b2e4218a-27bf-475f-97b9-b2ffaaa19cc0) | grouped form/settings | coupon redemptions, one row |
| 230 | [983dd0e0-bb5f-4df0-9a8d-09fc9df8659d](https://mobbin.com/screens/983dd0e0-bb5f-4df0-9a8d-09fc9df8659d) | grouped form/settings | coupon details, active |
| 231 | [26b4f2e6-471d-41f1-9167-11f1d0760bab](https://mobbin.com/screens/26b4f2e6-471d-41f1-9167-11f1d0760bab) | sheet | coupon-limit editing |
| 232 | [cd06a0dd-e06c-494c-8d15-b5ec90b88092](https://mobbin.com/screens/cd06a0dd-e06c-494c-8d15-b5ec90b88092) | popover | ticket applicability selector |
| 233 | [7d561221-2e95-4904-a145-b950ccf93f50](https://mobbin.com/screens/7d561221-2e95-4904-a145-b950ccf93f50) | sheet | coupon limit scoped to standard |
| 234 | [3400ad02-fca9-481c-a598-838a7fd84abd](https://mobbin.com/screens/3400ad02-fca9-481c-a598-838a7fd84abd) | grouped form/settings | coupon scope applied |
| 235 | [52b1991a-db45-4a0f-91b6-eb8a094f67a8](https://mobbin.com/screens/52b1991a-db45-4a0f-91b6-eb8a094f67a8) | sheet | coupon invalidation confirmation |
| 236 | [e504986c-a20c-44d4-a1a3-53d9d286ef45](https://mobbin.com/screens/e504986c-a20c-44d4-a1a3-53d9d286ef45) | grouped form/settings | coupon invalidated, success toast |
| 237 | [a5c18bda-a7ae-4fc5-9baa-7792ba66a77f](https://mobbin.com/screens/a5c18bda-a7ae-4fc5-9baa-7792ba66a77f) | grouped form/settings | coupon invalidated, settled |
| 238 | [dcd259ea-e8b7-4ffa-b827-97086035ea3e](https://mobbin.com/screens/dcd259ea-e8b7-4ffa-b827-97086035ea3e) | grouped form/settings | registration questions, default fields |
| 239 | [16c852b1-3869-49b4-8321-e74cd6a8a14b](https://mobbin.com/screens/16c852b1-3869-49b4-8321-e74cd6a8a14b) | grouped form/settings | registration questions, custom questions added |
| 240 | [ebe893f3-b8a8-4c0b-8ffc-e1786accb77d](https://mobbin.com/screens/ebe893f3-b8a8-4c0b-8ffc-e1786accb77d) | grouped form/settings | registration questions, lower scroll |
| 241 | [997552cd-de09-42d3-9872-965bdcfe35ef](https://mobbin.com/screens/997552cd-de09-42d3-9872-965bdcfe35ef) | selector | question-type menu, upper |
| 242 | [ea9d6745-3169-4448-b3f2-a11bb759ba2a](https://mobbin.com/screens/ea9d6745-3169-4448-b3f2-a11bb759ba2a) | grouped form/settings | multi-select question, empty |
| 243 | [cfe5f398-3097-4da3-bfec-ddf2be7c8ed7](https://mobbin.com/screens/cfe5f398-3097-4da3-bfec-ddf2be7c8ed7) | grouped form/settings | multi-select question, filled |
| 244 | [2008ed58-4d10-456c-8fcd-32bd961f29fc](https://mobbin.com/screens/2008ed58-4d10-456c-8fcd-32bd961f29fc) | selector | question-type menu, lower |
| 245 | [ec9c47b0-d314-41ed-8a48-b43e61e511f9](https://mobbin.com/screens/ec9c47b0-d314-41ed-8a48-b43e61e511f9) | grouped form/settings | terms question, empty text mode |
| 246 | [7f550c7d-779b-4d4b-93e6-f6794fd1ae5f](https://mobbin.com/screens/7f550c7d-779b-4d4b-93e6-f6794fd1ae5f) | grouped form/settings | terms question, filled text mode |
| 247 | [23fef9fe-8e7a-48f3-a620-153c0f365a4b](https://mobbin.com/screens/23fef9fe-8e7a-48f3-a620-153c0f365a4b) | grouped form/settings | terms question, empty link mode |
| 248 | [7445d9a5-85db-4268-96d1-b8cd58b6bc04](https://mobbin.com/screens/7445d9a5-85db-4268-96d1-b8cd58b6bc04) | grouped form/settings | terms question, link and signature enabled |
| 249 | [9f86c9da-5a6c-48b2-81d8-deac5c6553f9](https://mobbin.com/screens/9f86c9da-5a6c-48b2-81d8-deac5c6553f9) | sheet | create event chat confirmation |
| 250 | [a49cc835-9fb8-4e42-b0f0-790a4ac3cdb4](https://mobbin.com/screens/a49cc835-9fb8-4e42-b0f0-790a4ac3cdb4) | chat | new event chat empty |
| 251 | [76f2537d-46cf-4fb7-83c4-232f316619eb](https://mobbin.com/screens/76f2537d-46cf-4fb7-83c4-232f316619eb) | chat | message composed, not sent |
| 252 | [a31f604d-49a0-4827-8590-7ec1eb9f4806](https://mobbin.com/screens/a31f604d-49a0-4827-8590-7ec1eb9f4806) | chat | outgoing message sent |
| 253 | [a01372cf-4ca3-43fb-a68a-a737fc11032f](https://mobbin.com/screens/a01372cf-4ca3-43fb-a68a-a737fc11032f) | chat | conversation with replies |
| 254 | [ac297cba-fcbc-4083-a53b-e65be4725d58](https://mobbin.com/screens/ac297cba-fcbc-4083-a53b-e65be4725d58) | grouped form/settings | event-chat info, top |
| 255 | [918f1996-dfcf-469c-81c2-a051fb8c0d92](https://mobbin.com/screens/918f1996-dfcf-469c-81c2-a051fb8c0d92) | grouped form/settings | event-chat info, lower scroll |
| 256 | [874762b7-06b1-4eb0-b657-94b4cb4f14b3](https://mobbin.com/screens/874762b7-06b1-4eb0-b657-94b4cb4f14b3) | plain list | event-chat members |
| 257 | [7443c032-8365-4079-9f60-7495ffd03a24](https://mobbin.com/screens/7443c032-8365-4079-9f60-7495ffd03a24) | sheet | clone event configuration |
| 258 | [2298c76f-f04c-4d06-8495-a513ffe416b2](https://mobbin.com/screens/2298c76f-f04c-4d06-8495-a513ffe416b2) | sheet | clone event success |
| 259 | [0a9f2ce4-946b-45fa-b0ab-b928b0ea9f49](https://mobbin.com/screens/0a9f2ce4-946b-45fa-b0ab-b928b0ea9f49) | sheet | transfer calendar, no eligible destination |
| 260 | [3b8c4f96-7cfe-44a4-9b1f-0f18ccc678ce](https://mobbin.com/screens/3b8c4f96-7cfe-44a4-9b1f-0f18ccc678ce) | sheet | cancel event, ready to slide |
| 261 | [802758d0-1ab0-40fd-a7f2-d0e2b40499f5](https://mobbin.com/screens/802758d0-1ab0-40fd-a7f2-d0e2b40499f5) | sheet | cancel event, slide in progress |
| 262 | [27972474-3d1a-4e0b-b74e-d7e3fac5bf5d](https://mobbin.com/screens/27972474-3d1a-4e0b-b74e-d7e3fac5bf5d) | sheet | cancel event, processing |
| 263 | [f225c9e1-02ae-4bc7-a67d-9ef187bc7c79](https://mobbin.com/screens/f225c9e1-02ae-4bc7-a67d-9ef187bc7c79) | sparse prompt | notifications empty |
| 264 | [6fa303e6-c330-410c-a676-b248fa51df6a](https://mobbin.com/screens/6fa303e6-c330-410c-a676-b248fa51df6a) | plain feed | notifications populated |
| 265 | [41fc6d38-02bd-41c8-9270-244e373e08ad](https://mobbin.com/screens/41fc6d38-02bd-41c8-9270-244e373e08ad) | discovery_hub | default |
| 266 | [808ce2fa-247d-45c6-a033-9c91e7ce80df](https://mobbin.com/screens/808ce2fa-247d-45c6-a033-9c91e7ce80df) | discovery_hub | scrolled |
| 267 | [b0488ee9-a546-4bcc-bd1b-43b25ecfce10](https://mobbin.com/screens/b0488ee9-a546-4bcc-bd1b-43b25ecfce10) | discovery_hub | horizontal-scroll |
| 268 | [9d13468b-b8f3-49dc-9a41-73f271f3ab74](https://mobbin.com/screens/9d13468b-b8f3-49dc-9a41-73f271f3ab74) | category_detail | default |
| 269 | [fd7a7128-2c46-4574-9d0f-dbd8213ef7c2](https://mobbin.com/screens/fd7a7128-2c46-4574-9d0f-dbd8213ef7c2) | category_detail | default |
| 270 | [01d72d7c-c4bf-465a-8f53-59683c8108e1](https://mobbin.com/screens/01d72d7c-c4bf-465a-8f53-59683c8108e1) | category_detail | horizontal-scroll |
| 271 | [ab2c9692-bb86-45f1-90a1-8bf7cdc16db0](https://mobbin.com/screens/ab2c9692-bb86-45f1-90a1-8bf7cdc16db0) | category_detail | scrolled |
| 272 | [1d486e8f-045e-46f6-8a37-b4236d6bef54](https://mobbin.com/screens/1d486e8f-045e-46f6-8a37-b4236d6bef54) | category_detail | subscribed |
| 273 | [148a0b4e-f61e-4b8a-9093-840d723fcf71](https://mobbin.com/screens/148a0b4e-f61e-4b8a-9093-840d723fcf71) | cover_profile | coming-soon |
| 274 | [a367d663-f55e-4206-bf4f-ee60ba0c2adb](https://mobbin.com/screens/a367d663-f55e-4206-bf4f-ee60ba0c2adb) | cover_profile | default |
| 275 | [1b35f53f-75e6-48d0-9822-4d9d6f08e17a](https://mobbin.com/screens/1b35f53f-75e6-48d0-9822-4d9d6f08e17a) | cover_profile | scrolled |
| 276 | [8980d3b1-7174-40a2-bd41-7260b304198d](https://mobbin.com/screens/8980d3b1-7174-40a2-bd41-7260b304198d) | cover_profile | filtered |
| 277 | [75a324f0-248c-4f15-a53f-07dee8fff1f3](https://mobbin.com/screens/75a324f0-248c-4f15-a53f-07dee8fff1f3) | cover_profile | following |
| 278 | [d67dc77c-290c-420b-bcb3-c4f403dde6b3](https://mobbin.com/screens/d67dc77c-290c-420b-bcb3-c4f403dde6b3) | anchored_menu | unfollow |
| 279 | [ad442caf-2171-4c61-b62e-e63af3f221ca](https://mobbin.com/screens/ad442caf-2171-4c61-b62e-e63af3f221ca) | anchored_menu | calendar-actions |
| 280 | [f5955690-f166-4c6a-89fd-459d490f4b05](https://mobbin.com/screens/f5955690-f166-4c6a-89fd-459d490f4b05) | confirmation_sheet | block-calendar |
| 281 | [a53611b6-267f-4973-8a73-7764a7744846](https://mobbin.com/screens/a53611b6-267f-4973-8a73-7764a7744846) | cover_profile | blocked |
| 282 | [f2bb3188-3b87-4cb4-abb1-4ec8048eebc6](https://mobbin.com/screens/f2bb3188-3b87-4cb4-abb1-4ec8048eebc6) | directory_list | cities |
| 283 | [edd163db-5ae8-4f5d-9727-47843267e39f](https://mobbin.com/screens/edd163db-5ae8-4f5d-9727-47843267e39f) | immersive_hero_feed | city |
| 284 | [b6891245-d834-49c3-b75d-a6f9946eeeb9](https://mobbin.com/screens/b6891245-d834-49c3-b75d-a6f9946eeeb9) | immersive_hero_feed | scrolled |
| 285 | [fb378b19-93e3-4cac-b862-fd3208c4c59e](https://mobbin.com/screens/fb378b19-93e3-4cac-b862-fd3208c4c59e) | map_canvas | pins |
| 286 | [52ce8173-ab47-4234-b4d0-6d08299e324f](https://mobbin.com/screens/52ce8173-ab47-4234-b4d0-6d08299e324f) | map_canvas | partial-results-sheet |
| 287 | [d98f6edc-7efd-4130-9a2d-3fdcaf6fee63](https://mobbin.com/screens/d98f6edc-7efd-4130-9a2d-3fdcaf6fee63) | map_canvas | expanded-results-sheet |
| 288 | [0831841b-7895-42c6-9190-9a9bb774b08e](https://mobbin.com/screens/0831841b-7895-42c6-9190-9a9bb774b08e) | search_results | focused-empty |
| 289 | [567ac178-b443-4ca7-84b5-8a9d2d946f0d](https://mobbin.com/screens/567ac178-b443-4ca7-84b5-8a9d2d946f0d) | search_results | loading |
| 290 | [a47c5a27-2ccb-4e83-871f-9a3fa5f4b1ce](https://mobbin.com/screens/a47c5a27-2ccb-4e83-871f-9a3fa5f4b1ce) | search_results | populated |
| 291 | [5572330d-1f5e-4f71-bc60-4e83b8bd403c](https://mobbin.com/screens/5572330d-1f5e-4f71-bc60-4e83b8bd403c) | chat_inbox | empty |
| 292 | [d344cda6-0073-40fd-b48d-ae3239115371](https://mobbin.com/screens/d344cda6-0073-40fd-b48d-ae3239115371) | chat_inbox | populated |
| 293 | [be600965-b4a5-4523-b73b-272ed7fbe9ab](https://mobbin.com/screens/be600965-b4a5-4523-b73b-272ed7fbe9ab) | people_picker | start-chat |
| 294 | [7fdd1dba-5f15-407e-9a6f-9413e47e9fbb](https://mobbin.com/screens/7fdd1dba-5f15-407e-9a6f-9413e47e9fbb) | people_picker | multi-select-empty |
| 295 | [3c445308-cc7d-4692-910a-374022783faf](https://mobbin.com/screens/3c445308-cc7d-4692-910a-374022783faf) | people_picker | multi-select-selected |
| 296 | [c295913b-a85e-4359-8a81-98997235a6e9](https://mobbin.com/screens/c295913b-a85e-4359-8a81-98997235a6e9) | identity_editor | group-default |
| 297 | [7270fba2-748f-47d0-b240-2e49a261a355](https://mobbin.com/screens/7270fba2-748f-47d0-b240-2e49a261a355) | identity_editor | group-filled |
| 298 | [0fb79312-1426-40f2-b078-b02918038d37](https://mobbin.com/screens/0fb79312-1426-40f2-b078-b02918038d37) | chat_thread | empty |
| 299 | [c3f1fbf1-0f92-4552-a55a-a1b514551bd1](https://mobbin.com/screens/c3f1fbf1-0f92-4552-a55a-a1b514551bd1) | chat_thread | populated-group |
| 300 | [f382312d-6d37-49a1-a8bc-674636b022de](https://mobbin.com/screens/f382312d-6d37-49a1-a8bc-674636b022de) | grouped_settings | group-info |
| 301 | [6c1bbecd-f3c3-481b-a32a-17e9eade9fbb](https://mobbin.com/screens/6c1bbecd-f3c3-481b-a32a-17e9eade9fbb) | grouped_settings | group-info-multiple-admins |
| 302 | [63059f29-60a3-4510-952f-36df10b4f95d](https://mobbin.com/screens/63059f29-60a3-4510-952f-36df10b4f95d) | grouped_settings | members |
| 303 | [37a6fc15-8cf3-409c-b139-08fc597ae076](https://mobbin.com/screens/37a6fc15-8cf3-409c-b139-08fc597ae076) | anchored_menu | mute-duration |
| 304 | [c527e0aa-9425-4bfd-a4eb-b6e1a47c29fa](https://mobbin.com/screens/c527e0aa-9425-4bfd-a4eb-b6e1a47c29fa) | grouped_settings | muted |
| 305 | [2dd56a6b-2aa4-4711-9cbf-2dfe1e119b34](https://mobbin.com/screens/2dd56a6b-2aa4-4711-9cbf-2dfe1e119b34) | confirmation_sheet | close-chat |
| 306 | [f0f8e0f3-6cb9-4c41-8bc9-05122ff973ac](https://mobbin.com/screens/f0f8e0f3-6cb9-4c41-8bc9-05122ff973ac) | chat_thread | closed |
| 307 | [9c9b7f35-fcdc-474a-a868-721ba29f66ea](https://mobbin.com/screens/9c9b7f35-fcdc-474a-a868-721ba29f66ea) | confirmation_sheet | leave-chat |
| 308 | [a7e17e05-eacd-4631-a36d-2ed62004cabb](https://mobbin.com/screens/a7e17e05-eacd-4631-a36d-2ed62004cabb) | chat_inbox | after-leaving |
| 309 | [0b988efc-b74b-4630-9451-15c6ba7e1cb8](https://mobbin.com/screens/0b988efc-b74b-4630-9451-15c6ba7e1cb8) | anchored_menu | member-actions |
| 310 | [cb998221-82f4-400d-b3b9-73426113e5ee](https://mobbin.com/screens/cb998221-82f4-400d-b3b9-73426113e5ee) | grouped_settings | promotion-success |
| 311 | [dc58daef-9b4a-4f48-ad99-5c04cd240ed6](https://mobbin.com/screens/dc58daef-9b4a-4f48-ad99-5c04cd240ed6) | chat_thread | empty-individual |
| 312 | [655ecebd-4c40-4caa-9d67-27a450e810b6](https://mobbin.com/screens/655ecebd-4c40-4caa-9d67-27a450e810b6) | chat_thread | draft |
| 313 | [2cdb27e6-b5d3-4d54-8710-252f08145060](https://mobbin.com/screens/2cdb27e6-b5d3-4d54-8710-252f08145060) | chat_thread | sent |
| 314 | [c0336929-b466-4123-8f52-f7b95a947eb3](https://mobbin.com/screens/c0336929-b466-4123-8f52-f7b95a947eb3) | chat_thread | media-conversation |
| 315 | [6ab80c24-77bf-4bf9-941d-a742fd42af29](https://mobbin.com/screens/6ab80c24-77bf-4bf9-941d-a742fd42af29) | chat_thread | reply-result |
| 316 | [81de1a62-d113-45d8-bc92-ec20b138760b](https://mobbin.com/screens/81de1a62-d113-45d8-bc92-ec20b138760b) | chat_thread | attachment-draft |
| 317 | [659ce146-66ef-4a8d-b002-72a3b835990a](https://mobbin.com/screens/659ce146-66ef-4a8d-b002-72a3b835990a) | chat_thread | attachment-caption |
| 318 | [418f4293-3c26-4c68-ae18-594b26a7586d](https://mobbin.com/screens/418f4293-3c26-4c68-ae18-594b26a7586d) | chat_thread | media-loading |
| 319 | [41cfb1fe-da3f-41c7-a3a0-c3d86788d430](https://mobbin.com/screens/41cfb1fe-da3f-41c7-a3a0-c3d86788d430) | message_context_menu | incoming |
| 320 | [be455adf-809d-4348-9c0e-3eaa56e42b8c](https://mobbin.com/screens/be455adf-809d-4348-9c0e-3eaa56e42b8c) | chat_thread | reaction-result |
| 321 | [f3f64064-5241-446c-b47a-0888554f6f1b](https://mobbin.com/screens/f3f64064-5241-446c-b47a-0888554f6f1b) | chat_thread | reply-draft |
| 322 | [3457a8c7-46da-4f3f-b453-d3932e4001e9](https://mobbin.com/screens/3457a8c7-46da-4f3f-b453-d3932e4001e9) | chat_thread | reply-filled |
| 323 | [25309edd-e586-41f9-a8d8-dcdacedb1a26](https://mobbin.com/screens/25309edd-e586-41f9-a8d8-dcdacedb1a26) | message_context_menu | outgoing |
| 324 | [493127ee-b16e-4fc5-ad70-2d0cf2a84545](https://mobbin.com/screens/493127ee-b16e-4fc5-ad70-2d0cf2a84545) | native_alert | delete-message |
| 325 | [72500ce0-f688-4e92-8204-63f37a4a5d56](https://mobbin.com/screens/72500ce0-f688-4e92-8204-63f37a4a5d56) | chat_thread | message-deleted |
| 326 | [c4a84b7e-61bc-442c-b912-b5adfcb5e90d](https://mobbin.com/screens/c4a84b7e-61bc-442c-b912-b5adfcb5e90d) | grouped_settings | person-info |
| 327 | [54b363d8-9282-4e8f-a247-dd06db7e2470](https://mobbin.com/screens/54b363d8-9282-4e8f-a247-dd06db7e2470) | media_grid | person-media |
| 328 | [5f8959ac-7a43-4a26-8d9d-fa984f8f722b](https://mobbin.com/screens/5f8959ac-7a43-4a26-8d9d-fa984f8f722b) | chat_inbox | closed-list |
| 329 | [16c6d87f-6b55-40a5-aa6d-4cdc2a70922f](https://mobbin.com/screens/16c6d87f-6b55-40a5-aa6d-4cdc2a70922f) | grouped_settings | root |
| 330 | [be04d683-b6f3-4e54-86fa-519a5735fa0a](https://mobbin.com/screens/be04d683-b6f3-4e54-86fa-519a5735fa0a) | grouped_settings | root-scrolled |
| 331 | [637a62fd-1a8c-46df-9a5b-d82c15e8773b](https://mobbin.com/screens/637a62fd-1a8c-46df-9a5b-d82c15e8773b) | plain_profile | empty |
| 332 | [81b8325a-b08d-4a15-b780-5275e02bec3b](https://mobbin.com/screens/81b8325a-b08d-4a15-b780-5275e02bec3b) | plain_profile | populated |
| 333 | [484bd454-399f-42f1-b76b-2a34ad4322de](https://mobbin.com/screens/484bd454-399f-42f1-b76b-2a34ad4322de) | identity_editor | profile-unchanged |
| 334 | [95d845d7-f96a-4638-87b2-ef11549ca3a9](https://mobbin.com/screens/95d845d7-f96a-4638-87b2-ef11549ca3a9) | identity_editor | profile-changed |
| 335 | [9c280804-6c03-46ca-becd-fad82251e0fd](https://mobbin.com/screens/9c280804-6c03-46ca-becd-fad82251e0fd) | identity_editor | profile-scrolled |
| 336 | [7eac5a7e-1563-4ef8-979e-e548f2c7b73c](https://mobbin.com/screens/7eac5a7e-1563-4ef8-979e-e548f2c7b73c) | grouped_settings | profile-saved |
| 337 | [b83035f0-7cec-4920-bc66-aff9c29b77c7](https://mobbin.com/screens/b83035f0-7cec-4920-bc66-aff9c29b77c7) | grouped_settings | account |
| 338 | [9d0be205-bcc6-4c0e-af02-eb867a94f1bd](https://mobbin.com/screens/9d0be205-bcc6-4c0e-af02-eb867a94f1bd) | grouped_settings | emails-one |
| 339 | [bf9cc2c5-bc03-4211-8d51-3f8787a2f600](https://mobbin.com/screens/bf9cc2c5-bc03-4211-8d51-3f8787a2f600) | grouped_settings | emails-two |
| 340 | [4313d4e4-9fc6-4f3f-8f88-af2eb3e62a50](https://mobbin.com/screens/4313d4e4-9fc6-4f3f-8f88-af2eb3e62a50) | single_purpose_form | email-empty |
| 341 | [7046320b-c787-47d6-b121-e123d0d8e6b4](https://mobbin.com/screens/7046320b-c787-47d6-b121-e123d0d8e6b4) | single_purpose_form | email-filled-focused |
| 342 | [e4f08e63-81c9-42a5-aca9-636ccfe5225b](https://mobbin.com/screens/e4f08e63-81c9-42a5-aca9-636ccfe5225b) | single_purpose_form | verification-partial |
| 343 | [a5518661-29ba-4aa7-8d2d-9da21eb925d7](https://mobbin.com/screens/a5518661-29ba-4aa7-8d2d-9da21eb925d7) | anchored_menu | email-actions |
| 344 | [9b36bcb4-beed-4307-9ff2-bddb908aed39](https://mobbin.com/screens/9b36bcb4-beed-4307-9ff2-bddb908aed39) | grouped_settings | email-primary-success |
| 345 | [51c86f5a-3801-4c1e-b970-6ae4d87b0b94](https://mobbin.com/screens/51c86f5a-3801-4c1e-b970-6ae4d87b0b94) | confirmation_sheet | remove-email |
| 346 | [a4bd3683-17ce-4f91-b19b-3e341fbcae39](https://mobbin.com/screens/a4bd3683-17ce-4f91-b19b-3e341fbcae39) | grouped_settings | email-removed |
| 347 | [25ce1767-1232-4e6d-be99-c1289c2ffb50](https://mobbin.com/screens/25ce1767-1232-4e6d-be99-c1289c2ffb50) | single_purpose_form | username-empty |
| 348 | [46b79fb5-fa43-4bcf-8d4f-aa429d98f41a](https://mobbin.com/screens/46b79fb5-fa43-4bcf-8d4f-aa429d98f41a) | single_purpose_form | username-error |
| 349 | [d47e937b-06af-4226-a1a0-ae6d287d2f17](https://mobbin.com/screens/d47e937b-06af-4226-a1a0-ae6d287d2f17) | single_purpose_form | username-valid |
| 350 | [830c0e1f-12e3-49e2-8f37-48f2b4b4fc16](https://mobbin.com/screens/830c0e1f-12e3-49e2-8f37-48f2b4b4fc16) | grouped_settings | account-updated |
| 351 | [a6a79bcc-f4e7-480f-926f-8b77e2bae390](https://mobbin.com/screens/a6a79bcc-f4e7-480f-926f-8b77e2bae390) | permission_explainer | passkey |
| 352 | [e2742927-5f12-4f85-954c-92f2feede697](https://mobbin.com/screens/e2742927-5f12-4f85-954c-92f2feede697) | grouped_settings | passkey-success |
| 353 | [18e1e560-f9eb-4aa4-ab15-c25a0095f11a](https://mobbin.com/screens/18e1e560-f9eb-4aa4-ab15-c25a0095f11a) | grouped_settings | passkey-list |
| 354 | [d12d0c47-b4aa-4246-9a52-b7fce10dc4eb](https://mobbin.com/screens/d12d0c47-b4aa-4246-9a52-b7fce10dc4eb) | confirmation_sheet | delete-account |
| 355 | [c79d5455-65ca-43ae-a2f6-aeaabf7ee004](https://mobbin.com/screens/c79d5455-65ca-43ae-a2f6-aeaabf7ee004) | confirmation_sheet | delete-account-slide-state |
| 356 | [2cbaa890-89c2-457d-845a-938476f4eb4b](https://mobbin.com/screens/2cbaa890-89c2-457d-845a-938476f4eb4b) | confirmation_sheet | delete-account-blocked |
| 357 | [fcb58dd5-1680-40d8-bbb1-aa116e22aae8](https://mobbin.com/screens/fcb58dd5-1680-40d8-bbb1-aa116e22aae8) | empty_state | signed-out-home |
| 358 | [30ff6415-b628-4203-96a3-b8a10f0f2fcd](https://mobbin.com/screens/30ff6415-b628-4203-96a3-b8a10f0f2fcd) | grouped_settings | payment-empty |
| 359 | [5c36e191-5710-4a5f-8a47-91fa83c2314b](https://mobbin.com/screens/5c36e191-5710-4a5f-8a47-91fa83c2314b) | grouped_settings | payment-saved |
| 360 | [7aa8a24f-6b0c-45a0-9a70-4a9f64d0a2ad](https://mobbin.com/screens/7aa8a24f-6b0c-45a0-9a70-4a9f64d0a2ad) | transaction_list | single-record |
| 361 | [4324a04a-33d5-41fc-8162-e007ed4e9f91](https://mobbin.com/screens/4324a04a-33d5-41fc-8162-e007ed4e9f91) | transaction_detail | receipt |
| 362 | [3ef7d2d1-40cf-45e0-a90f-83749684d3c5](https://mobbin.com/screens/3ef7d2d1-40cf-45e0-a90f-83749684d3c5) | grouped_settings | notifications |
| 363 | [122dddc4-7c06-49ba-bcd1-ab88b1241c2a](https://mobbin.com/screens/122dddc4-7c06-49ba-bcd1-ab88b1241c2a) | anchored_menu | notification-multi-select |
| 364 | [e1e4f64f-2cce-4667-bd8a-2993e9079227](https://mobbin.com/screens/e1e4f64f-2cce-4667-bd8a-2993e9079227) | grouped_settings | notification-off |
| 365 | [3b8d855c-bfca-4f52-84a0-4628a4306d2e](https://mobbin.com/screens/3b8d855c-bfca-4f52-84a0-4628a4306d2e) | anchored_menu | notification-warning |
| 366 | [1d742a81-f255-46a1-a15b-98909225f4a9](https://mobbin.com/screens/1d742a81-f255-46a1-a15b-98909225f4a9) | anchored_menu | notification-selection-changed |
| 367 | [6f539edf-22ff-48af-bf62-62df18993972](https://mobbin.com/screens/6f539edf-22ff-48af-bf62-62df18993972) | grouped_settings | notification-push-only |
| 368 | [157eb5f9-b10c-4b19-b170-7eaef5b28efd](https://mobbin.com/screens/157eb5f9-b10c-4b19-b170-7eaef5b28efd) | grouped_settings | permissions |
| 369 | [14cc8f7b-ba7a-474c-ae10-e2428e659eab](https://mobbin.com/screens/14cc8f7b-ba7a-474c-ae10-e2428e659eab) | system_permission | contacts |
| 370 | [c5b816f3-8fa7-4105-ab33-caf4d887a1cd](https://mobbin.com/screens/c5b816f3-8fa7-4105-ab33-caf4d887a1cd) | grouped_settings | contacts-enabled |
| 371 | [d618492a-cae4-4eb6-915f-458362526983](https://mobbin.com/screens/d618492a-cae4-4eb6-915f-458362526983) | empty_state | blocked-users-empty |
| 372 | [90d60cfd-c5ec-466a-b9cc-e6a787721b05](https://mobbin.com/screens/90d60cfd-c5ec-466a-b9cc-e6a787721b05) | grouped_settings | blocked-users-populated |
| 373 | [cacf68b7-914d-4892-9ec7-492d255dc1a0](https://mobbin.com/screens/cacf68b7-914d-4892-9ec7-492d255dc1a0) | grouped_settings | blocked-calendars |
| 374 | [0f00c063-af72-4d1b-8490-62c90ba937d9](https://mobbin.com/screens/0f00c063-af72-4d1b-8490-62c90ba937d9) | grouped_settings | review-invites-pending |
| 375 | [bb24f28d-5941-4eb2-8b8b-4ee725f44dcc](https://mobbin.com/screens/bb24f28d-5941-4eb2-8b8b-4ee725f44dcc) | grouped_settings | review-invites-accepted |
| 376 | [5fc094ff-37a1-4a60-935b-f13d5903bb30](https://mobbin.com/screens/5fc094ff-37a1-4a60-935b-f13d5903bb30) | visual_selector | appearance-light |
| 377 | [70d7304c-573b-464f-8d71-119be65c750b](https://mobbin.com/screens/70d7304c-573b-464f-8d71-119be65c750b) | visual_selector | appearance-dark |
| 378 | [9f3e1d45-f117-4ff5-9b72-46ba5273a2f6](https://mobbin.com/screens/9f3e1d45-f117-4ff5-9b72-46ba5273a2f6) | flat_feed | dark |
| 379 | [f8896c4c-e3e2-40e4-bb4f-4b02852abe31](https://mobbin.com/screens/f8896c4c-e3e2-40e4-bb4f-4b02852abe31) | discovery_hub | dark |
| 380 | [e8eb6d85-bb28-4bee-a01e-b6f866be6b67](https://mobbin.com/screens/e8eb6d85-bb28-4bee-a01e-b6f866be6b67) | chat_thread | dark |
| 381 | [286415b2-54e1-40d7-a2b6-b6a3ff9e519a](https://mobbin.com/screens/286415b2-54e1-40d7-a2b6-b6a3ff9e519a) | plain_profile | dark |
| 382 | [777ffac0-b2c2-4ca2-b435-37af867a057c](https://mobbin.com/screens/777ffac0-b2c2-4ca2-b435-37af867a057c) | native_alert | app-icon-changed |
| 383 | [6c24fa4f-dc45-4737-945f-c469268d8b54](https://mobbin.com/screens/6c24fa4f-dc45-4737-945f-c469268d8b54) | visual_selector | alternate-icon-selected |
| 384 | [f0c62417-b481-4e7b-80be-2f3ca76cd473](https://mobbin.com/screens/f0c62417-b481-4e7b-80be-2f3ca76cd473) | freeform_editor | feedback-empty |
| 385 | [8a9033f2-a7df-4933-873d-63745044627f](https://mobbin.com/screens/8a9033f2-a7df-4933-873d-63745044627f) | freeform_editor | feedback-filled |
| 386 | [6956e251-bbec-4777-8fdb-cb1fec19fcc1](https://mobbin.com/screens/6956e251-bbec-4777-8fdb-cb1fec19fcc1) | grouped_settings | feedback-sent |
| 387 | [ef9007c5-aa3c-4fad-849b-46dbfb9d7b23](https://mobbin.com/screens/ef9007c5-aa3c-4fad-849b-46dbfb9d7b23) | native_alert | sign-out |
| 388 | [13886985-5f7f-4b05-96fd-d50539886b99](https://mobbin.com/screens/13886985-5f7f-4b05-96fd-d50539886b99) | choice_sheet | sign-in-method |
| 389 | [b57476eb-37e0-4ddb-acd6-490b592d7afa](https://mobbin.com/screens/b57476eb-37e0-4ddb-acd6-490b592d7afa) | single_purpose_form | login-email-empty |
| 390 | [922a6c0f-702a-4dee-8d91-30d53d8f8079](https://mobbin.com/screens/922a6c0f-702a-4dee-8d91-30d53d8f8079) | single_purpose_form | login-email-filled |
| 391 | [e537e982-8156-4280-a304-76a55d60ff65](https://mobbin.com/screens/e537e982-8156-4280-a304-76a55d60ff65) | single_purpose_form | login-otp-empty |
| 392 | [13b0f8d3-4f7b-44dd-9a55-7942b34c0f1d](https://mobbin.com/screens/13b0f8d3-4f7b-44dd-9a55-7942b34c0f1d) | single_purpose_form | login-otp-partial |
| 393 | [8cd131e5-0b8b-498c-9d6f-7fb23e0966d9](https://mobbin.com/screens/8cd131e5-0b8b-498c-9d6f-7fb23e0966d9) | flat_feed | logged-in |
