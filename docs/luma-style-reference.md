# Luma reference profile for native Apple apps

Research date: 2026-10-10. This document describes the specific Luma **events** app reference supplied for CalorieCam. It is not Luma AI and does not use another app as a substitute.

**Expanded coverage:** [The complete layout atlas](luma-layout-atlas.md) now records visual review of all 393 distinct images across 120 corroborated pinned-version flows, with [per-screen observations](luma-layout-atlas.inventory.json). Use that atlas for whole-app layout families and state coverage; this document retains the initial visual measurements. The user’s latest continuous-corner, actual nested-radius and full-pill requirements are explicit implementation overrides, detailed in the atlas.

## Source identity and evidence

- [Requested Mobbin collection](https://mobbin.com/apps/luma-ios-bead4230-994f-47c2-9311-5049bf7bcace/0ae0e7e9-c7b7-4ef6-bc80-ddd7d4dfc040/screens)
- App ID: `bead4230-994f-47c2-9311-5049bf7bcace`; collection/version ID: `0ae0e7e9-c7b7-4ef6-bc80-ddd7d4dfc040`.
- Mobbin MCP supplied the actual screenshots and ordered flows below. Both inline previews and downloaded high-resolution images were visually inspected.
- The collection page could not be opened by the web reader. Exact collection membership was separately corroborated against this [public version catalog](https://github.com/Johnson-f/OpenMobbin/blob/master/catalog/apps/luma/versions/0ae0e7e9-c7b7-4ef6-bc80-ddd7d4dfc040.json), which pins the same app/version IDs, includes every main reference screen below, and reports publication on 2026-09-14. This catalog is provenance corroboration, not the source of visual observations.
- Search also returned an older Luma creation flow with different tab navigation. It was excluded. Mixing those versions would produce an inaccurate reconstruction.

### Inspected reference set

| Reference | What it establishes |
| --- | --- |
| [Home, light](https://mobbin.com/screens/4e0f5ef3-de35-450a-b8b8-f8e7ac192e6a) | White canvas, compact header, thumbnail-led flat list, status chips, metadata hierarchy, floating navigation |
| [Discover, light](https://mobbin.com/screens/41fc6d38-02bd-41c8-9270-244e373e08ad) | Horizontal event discovery, category chips, image-led city cards |
| [Event detail](https://mobbin.com/screens/9af424b7-5e7f-4619-af62-25a763624cee) | Wide cover art, image-colored dark ambient canvas, title hierarchy, three action tiles |
| [Create event, initial](https://mobbin.com/screens/5468c5bc-943d-4211-b2f0-1f14bbf2ecda) | Centered cover, immersive color, grouped translucent fields, toolbar completion control |
| [Create event, changed cover](https://mobbin.com/screens/bc829875-4790-42af-83c3-c05259f7be40) | Ambient background changes with the media; green is not a global brand accent |
| [Create event, date picker](https://mobbin.com/screens/d05ce40a-de15-49ca-8c34-84f817d39f27) | Native-looking wheel date popover over the composer; selected values remain in the form |
| [Home, dark](https://mobbin.com/screens/9f3e1d45-f117-4ff5-9b72-46ba5273a2f6) | Black canvas, white foreground, lighter gray metadata, restrained separators |
| [Discover, dark](https://mobbin.com/screens/f8896c4c-e3e2-40e4-bb4f-4b02852abe31) | Same adaptive structure and content-derived transparent navigation treatment |
| [Chat, dark](https://mobbin.com/screens/e8eb6d85-bb28-4bee-a01e-b6f866be6b67) | Domain-specific blue message accent; not justification for blue CTAs throughout other surfaces |

## Visual grammar

The strongest recognizable combination is **flat, monochrome editorial browsing plus immersive, image-colored detail and creation surfaces**. Dense content comes from thumbnail, title, and metadata alignment rather than nested elevated cards. Navigation floats above the content with a rounded, translucent treatment. Cover imagery contributes most of the color and personality.

Avoid turning the entire app into tinted panels, orange buttons, cream backgrounds, oversized dashboard numerals, or a stack of heavy rounded cards. Those treatments are not established by this reference.

## Color and materials

The following values were sampled from downloaded JPEG raster images, excluding the Mobbin footer. They are **measured rendered pixel values**, not recovered source tokens. Compression, antialiasing, display composition, opacity, and color management create small variation. Treat text values as representative clusters.

| Role | Light reference | Dark reference | Confidence / use |
| --- | --- | --- | --- |
| Flat screen canvas | `#FFFFFF` | `#000000` | High; broad uniform areas |
| Primary text | approximately `#161616` | `#FFFFFF` | High visual confidence; light glyph cores vary around 20–24 RGB |
| Row metadata | approximately `#666666` | approximately `#CCCCCC` | High; dominant interior glyph samples |
| Tertiary label / subtitle | approximately `#999999` | approximately `#999999` | Visual and raster estimate; context varies |
| Quiet row separator | approximately `#F0F0F0` | approximately `#252525` | Raster measurement; thin, low contrast |
| Toolbar capsule over flat canvas | white/translucent | approximately `#121212` | Rendered composite, not a fixed material color |
| Floating tab background | white/translucent | approximately `#181818` | Rendered composite; changes over imagery |
| Selected tab background | pale neutral gray | approximately `#3A3A3A` | Rendered composite; native selection material should own it |
| Primary action on immersive detail | white surface, black icon/text | same visual treatment | Directly observed on detail |

Status chips use distinct semantic colors: green for Going/price, amber for Waitlisted/limited availability, violet for Invited, magenta for Hosting. Their light backgrounds are pale and low-area. Dark mode uses deep tinted backgrounds and brighter text. Do not promote these local states into an app-wide accent. Label each state in text as well as color.

### Ambient media surface

The event cover contributes a broad, very soft color field behind the content. The first composer is rich green because its image is green. Replacing the cover with black/red art yields charcoal with a red glow. The inspected detail has muted blue/green regions over charcoal.

These are not flat hex colors. Recommended native implementation: render the app-owned cover as an oversized, blurred decorative backdrop; add a darkening/contrast layer; keep the foreground image crisp. Do not infer an exact blur radius, opacity, or color-extraction algorithm from a still screenshot. Expose those as bounded profile parameters and tune against reference captures. Supply a neutral charcoal fallback without an image, and an opaque fallback for Reduce Transparency. The background should never reduce input readability.

Translucent field groups visually resemble a small white lift over the ambient image. Roughly 8–12% white is a starting estimate, not a source measurement. Native material/availability behavior should govern toolbars, popovers, sheets, and tab bars; do not simulate glass with static screenshots.

## Geometry and typography

High-resolution downloads are 1180 or 1179 pixels wide by 2676 pixels high, including a Mobbin footer that is not part of the app. The estimates below assume an approximately 393-point-wide, 3× screenshot. That device/scale inference is not confirmed by Mobbin metadata. Pixel distances were inspected, then rounded to plausible native point values.

| Element | Reference estimate |
| --- | --- |
| Main horizontal content inset | 20 pt (about 60 source pixels) |
| Header avatar and circular toolbar control | 44 pt |
| Header title | about 22 pt, semibold; the Luma wordmark itself is an asset |
| Section title | 20 pt, semibold |
| List thumbnail | 80 × 80 pt, approximately 8 pt corner radius |
| Thumbnail-to-text gap | 12 pt |
| Text column origin | about 112 pt from screen edge |
| Organizer/eyebrow line | about 13 pt, regular, secondary |
| Row title | about 17 pt, medium; wraps to two lines where needed |
| Time/location metadata | about 15–17 pt, regular, secondary; small quiet icons |
| Status chip text | about 12 pt, medium; capsule shape |
| Major section spacing | approximately 24–32 pt, content-dependent |
| List row vertical gap | approximately 16 pt plus the preceding content height |
| Detail hero | available width, approximately 353 pt; roughly 16 pt corner radius |
| Detail title | about 22 pt, semibold, natural wrapping |
| Detail action tiles | roughly 54 pt high, 12 pt radius, 6–8 pt gaps |
| Composer cover | 240 pt square, approximately 16–20 pt radius |
| Composer cover-to-first-field gap | about 28 pt |
| Composer name row | approximately 54 pt high, capsule; semibold text |
| Composer grouped row | approximately 50–54 pt high; group radius 24–28 pt |
| Composer field/group spacing | about 12 pt |

Typography looks consistent with an iOS system sans-serif. The screenshots do not prove the exact font family, optical size, weight, tracking, or whether Luma uses SwiftUI. Use the system font and Dynamic Type, with semantic roles corresponding to this hierarchy; do not claim to have recovered a proprietary type specification. The wordmark and custom smiling navigation icons are not system font glyphs.

The browsing list is visually flat: separators start at the text column, not the thumbnail edge. A small status capsule overlaps the lower edge of the thumbnail. Organizer avatar(s) are tiny and secondary. The main title, not the calorie/event metadata, owns the text hierarchy.

## Navigation, actions, and controls

- Root header: a circular profile image and short title on the left; compact icon actions grouped in a trailing capsule. No oversized large-title screen header is visible in the inspected home state.
- Three-item root navigation: Home, Discover, Chat, with icons and small text. A rounded selection sits inside a floating translucent capsule. This is an observation of the reference information architecture, not a requirement to create three irrelevant tabs in CalorieCam.
- Detail: circular Back and Share controls over the ambient background; a wide cover, title, date, state/price, then Register, Contact, More actions. Register is white and most prominent. The other two tiles are translucent and quieter.
- Composer: modal presentation with a drag indicator, centered title, account switcher at left, circular completion control at right. Completion is visibly disabled while required content is absent and becomes high contrast when valid.
- Form controls: compact label/value rows, normal system keyboard, date picker, switch, and secondary modal search. Native focus, dismissal, VoiceOver, keyboard insets, and validation remain mandatory.
- Iconography: simple monochrome symbols for navigation/actions and outlined quiet metadata symbols. Use SF Symbols with corresponding meaning; do not claim the custom Luma tab glyphs are stock symbols or redistribute Luma branding.

## Ordered flows and native interpretation

### Create and review

The inspected [Creating an event flow](https://mobbin.com/flows/6ee14a90-2007-4007-9763-9f17f90cc315) contains 19 ordered screenshots. Visible states show home → composer → cover choice/change → entered title → date selection → location search → description editor → return to home with the new event. Only shown states establish behavior; stills do not establish exact transition timing or gesture physics.

Native adaptation: present a real sheet containing editable fields and retained media. Use `PhotosPicker`, platform camera where supported, `TextField`, `DatePicker`, and native toolbar actions. Validate before Save. Save updates the diary and dismisses; Cancel must not commit partial data. Native components determine their actual modal and keyboard behavior.

### Browse and inspect

The source detail screen and collection Event detail flow establish thumbnail-led browsing into a much larger image and richer metadata. CalorieCam should similarly preserve the selected meal photo and title when moving between diary and review, rather than switching into an unrelated visual language.

### Appearance

The inspected [Switching to dark mode flow](https://mobbin.com/flows/1bca8ed6-a4fa-4645-bfea-bd91ec846e32) shows System, Light, and Dark appearance choices and the resulting home/discovery/profile/chat surfaces. Honor system appearance by default. The flat canvas changes from white to black; typography and metadata adapt. Ambient media surfaces retain their content-derived character.

## Reusable kit boundary

Create an **additive, opt-in visual profile**. Keep the repository's sealed design-token files unchanged. A source profile should define adaptive color roles, typography roles, geometry, separator behavior, and ambient-media treatment; it must not bake CalorieCam wording, event-specific data, or Luma brand assets into generic components.

Useful reusable composition primitives:

1. Flat adaptive screen canvas with profile insets.
2. Compact section heading with optional secondary line/action.
3. Thumbnail-led row with eyebrow, title, metadata, and optional state slot.
4. Semantic status chip with readable text.
5. Crisp media cover with rounded clipping and optional corner action.
6. Decorative ambient-media backdrop with contrast/accessibility fallbacks.
7. Translucent field group that hosts real native controls.
8. Prominent/quiet action styling for real Buttons, without replacing button semantics.

Keep `NavigationStack`, native toolbar placements, sheets, menus, tab behavior when genuinely needed, photo access, focus, safe areas, and accessibility in native recipes. Avoid a handmade pill tab bar solely to match a still. Its appearance depends on OS version, device, scroll state, and user accessibility settings.

## CalorieCam mapping

| CalorieCam surface | Apply from reference | Preserve domain behavior |
| --- | --- | --- |
| Diary | Flat light/dark canvas, compact header, section hierarchy, photo thumbnail rows, quiet secondary metadata | Date selection, correct total, saved meals only, edit/delete |
| Capture / source choice | Media-centered composer, ambient image once available, clearly labeled native source actions | Camera/library/manual paths; permission and hardware fallback |
| Review / edit | Large crisp photo, strong meal title, translucent grouped editable facts, monochrome Save | Name, portion, calories, time; validation; Cancel without saving |
| Empty state | Same insets/type hierarchy, one clear native Add action, restrained domain-owned visual | Honest empty diary; no fabricated meals or AI recognition |
| Settings, if present | Flat adaptive canvas and native grouped controls | Actual preferences only; do not add reference-only event features |

Nutrition facts must remain editable and honest. Styling does not create an AI nutrition model. Do not imply photo recognition is configured when the app only stores a photo with manual input. Do not invent event-like states or unnecessary discovery/chat tabs to fill a reference layout.

## Fidelity acceptance and limitations

“100%” is not established by these references. Pixel-identical reproduction would need the exact fonts/assets, original layout and material parameters, matching content, device/OS state, and side-by-side rendered verification. The goal is a closely source-matched visual profile with native Apple behavior, with deviations recorded rather than hidden.

Before calling the implementation visually verified:

1. Compare light diary, dark diary, media composer, and populated review captures at matched logical widths.
2. Check 20 pt inset, 80 pt list imagery, title hierarchy, grouping, and image/text balance before tuning subtle colors.
3. Confirm the media backdrop changes with the actual chosen image and does not wash out fields.
4. Exercise Dynamic Type, Reduce Transparency, VoiceOver labels, keyboard focus, Save/Cancel, camera denial, and empty content.
5. Keep reference screenshots as research evidence, not shipped app assets. Use original or licensed meal imagery and the app's own name/branding.

No exact source font, custom icon pack, motion specification, or reusable rights to event posters were supplied. Native SF Symbols and system type are intentional equivalents, not recovered Luma assets.
