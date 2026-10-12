# Compact outlined actions

Use the existing secondary button style for compact, content-sized category actions:

```swift
Button {
  selectCategory(category)
} label: {
  Label(category.title, systemImage: category.symbol)
}
.buttonStyle(DesignOSSecondaryButtonStyle(size: .compact, treatment: .outlined))
```

The style decorates a real native `Button`. Selection, activation, roles, disabled state,
accessibility labels, and navigation remain owned by the caller. An outlined category action
does not imply a toggle or a selected state. Add those semantics only when the product has them.

## Reusable contract

- `DesignOSSecondaryButtonStyle()` still delegates to the existing regular filled action.
  The editorial default remains full width with a 54-point minimum visual height.
- `size: .compact` uses natural content width, native body typography, `metrics.contentInset`
  horizontal padding, and half that inset vertically. It imposes no fixed visual height or
  line limit. Larger text and multiline labels grow the capsule.
- While enabled, `treatment: .outlined` uses the opaque `palette.canvas` surface and a one-point
  `palette.separator` outline. Both are adaptive semantic colors. `treatment: .filled` keeps
  `palette.subtleSurface`; either treatment can be used with either size. While disabled,
  both sizes and treatments use the shared `palette.disabledAction` background/foreground pair.
  An outlined action retains its adaptive separator border.
- All visible backgrounds, borders, and focus indicators use a continuous `Capsule`.
- A separate outer frame and rectangular content shape preserve a minimum 44-by-44-point
  interaction region. The visible compact capsule can be shorter. Do not add a fixed outer
  height, negative row spacing, clipping, or overlapping hit areas to compress this target.
- Foreground, native destructive-role color, pressed/hover feedback, and disabled behavior
  reuse the regular action's semantic policies. Keyboard focus draws the same ink outline.
  Decorative backgrounds and outlines do not intercept input or add accessibility elements.

Compact geometry adds no sealed design tokens, screenshot-derived point constants,
or fixture-only style overrides. Compact spacing is an explicit relationship to the existing
app content inset; a custom app style controls that relationship through its own metrics.

## Layout and accessibility

Let the parent propose a finite available width when text should wrap. A horizontal rail may
intentionally scroll at ordinary text sizes; its owning layout should reflow to a vertical
stack at accessibility sizes. The button style does not replace the rail's layout policy.
Do not force `.lineLimit(1)`, a fixed capsule height, or fixed chip widths at the call site.

Native body typography participates in Dynamic Type. Disabled actions use the subdued
disabled-only pair and suppress hover/pressed feedback. Increase Contrast restores the
previous readable subtle-surface/secondary-ink pair. An enabled destructive action retains
its native role and red text. Outline colors adopt the palette's increased-contrast values.
A custom palette remains responsible for its own contrast; omitting `disabledAction`
derives the pair from that palette's `subtleSurface` and `secondaryInk`.

## Observed reference and intentional adaptation

The inspected Luma [light category screen](https://mobbin.com/screens/656709f6-fa80-4ccf-87e6-fde374ebba26)
and [dark category screen](https://mobbin.com/screens/f8896c4c-e3e2-40e4-bb4f-4b02852abe31)
show compact outlined icon-and-label actions, natural label-dependent widths, two rows, and
fills visually matching the surrounding white or black canvas. The outlines are quiet gray
in both appearances; category icons have individual colors.

The reference chips have rounded-rectangle corners. Full capsule geometry is an intentional
adaptation to the requested all-pill button direction. Using SF Symbols instead of the source
icons, the caller's chosen icon colors, and a one-row rail instead of two source rows must be
identified as adaptations during visual comparison. No reference assets are copied here.

The source density is unconfirmed. Raster height and gap estimates are not logical point
measurements and do not establish pixel fidelity. The compact inset relationship and minimum
interaction size above are implementation choices, not recovered Luma measurements.

The disabled action colors follow the separately inspected
[light onboarding action](https://mobbin.com/screens/f2970c67-067b-4a43-9416-18f656d7e723)
and [dark ambient registration action](https://mobbin.com/screens/c79aae44-4f72-47b6-98ad-bb9171d6c783)
in pinned collection `0ae0e7e9-c7b7-4ef6-bc80-ddd7d4dfc040`. Applying that shared disabled
role to compact secondary categories is a kit consistency choice, not evidence that those
category screenshots show a disabled state. See the [disabled-action source study](../../luma-style-reference.md#disabled-actions)
for pixel context, cross-checks, and the explicit lower-contrast boundary.

## Verification boundary

Focused Swift tests cover backwards-compatible defaults, semantic compact geometry, palette
selection, unchanged enabled text contrast across appearances/roles/interaction states,
readable increased-contrast disabled fallbacks, and native button
composition at accessibility text size. Arithmetic or source checks do not prove a rendered
hit region, focus behavior, wrapping, or visual similarity.

Native Swift compilation, iOS/macOS rendering, interaction testing, VoiceOver, and side-by-side
visual acceptance are **NOT VERIFIED** by this source-only change. Capture compact outlined
buttons in light, dark, long-label/accessibility, disabled, pressed, hover, and keyboard-focus
states before making those claims. Confirm taps within the outer target activate the native
button and adjacent category actions do not overlap. Run native Increase Contrast separately;
do not attempt to set the read-only `colorSchemeContrast` environment value.
