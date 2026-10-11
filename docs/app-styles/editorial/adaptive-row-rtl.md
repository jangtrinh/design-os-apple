# Adaptive row: framework-owned RTL placement

## Observed defect

The macOS native `rtl` / `dark` captures from the `db374fc75888a733f7c9b2d1f0690c7046f11440`
candidate retain left-to-right **slot order** in all three users of
`DesignOSEditorialAdaptiveRowLayout`:

- `component--semantic--labeled-value-row--rtl--dark.png`: the label remains leftmost.
- `component--composite--choice-row--rtl--dark.png`: the leading symbol remains leftmost
  and the native checkbox remains rightmost.
- `component--composite--conversation-composer--rtl--dark.png`: Attach remains leftmost
  and Send remains rightmost.

Their text alignment does respond to RTL. The control capture,
`component--composite--identity-header--rtl--dark.png`, uses a native stack and correctly
places the leading avatar on the right. These original 1024 × 768 images were inspected;
they are evidence of the existing defect, not renders of the correction. Capture bindings
record the tested merge revision `0f078cdbab22dd35da68c9afa0d64cd03fe51a09`.

## Platform contract and bounded correction

Apple's [LayoutDirection documentation](https://developer.apple.com/documentation/swiftui/layoutdirection)
states that the framework adapts child x positions for RTL. The
[WWDC22 custom layout session](https://developer.apple.com/videos/play/wwdc2022/10056/)
specifically explains that `Layout.placeSubviews` calculations use a top-left origin,
positive x to the right, and positive y downward in either direction. It also cautions
against assuming a zero origin.

The helper previously calculated `bounds.maxX - offset - childWidth` in RTL, then handed
that coordinate to SwiftUI. Applying both transformations explains the observed unchanged
slot order. This diagnosis combines the documented framework contract with native failure
evidence; successful native rendering of the correction remains **NOT VERIFIED**.

The correction supplies `bounds.minX + offset` in both directions and lets SwiftUI perform
its own RTL transformation. The existing `.topLeading` anchor, child proposals, vertical
source order, spacing, and centering are retained. The `layoutDirection` input remains at
the internal caller seam but intentionally does not transform coordinates. No callers,
public declarations, controls, accessibility modifiers, or child enumeration order change.

Measurement behavior is unchanged. The helper retains its finite natural-size fallback for
unspecified, negative, and non-finite width proposals, plus the existing finite-length
normalization for child widths, returned heights, and spacing. In particular, this placement
fix does not redefine how the layout responds to
[SwiftUI's special maximum-size proposal](https://developer.apple.com/documentation/swiftui/proposedviewsize).

## Regression coverage and remaining gates

`DesignOSEditorialRowPolicyTests` now exercises the **same measurement and placement
functions used by the production Layout**, rather than only constructing its view type:

- Unequal child widths and heights, flexible middle width, real gaps, and vertical centering.
- Identical logical placement points for LTR and RTL. These points precede SwiftUI's own
  RTL transformation; the test does not simulate a native renderer or claim native proof.
- Zero, positive, and negative origins; the final horizontal child ends at `bounds.maxX`.
- Narrow-width and accessibility vertical reflow, retaining child order and full-width slots.
- Unspecified, zero, negative, NaN, and infinite width proposals.
- Negative / non-finite child sizes and spacing, plus empty and single-child layouts.
- Compile fixtures with native `TextField` and `Button` in each layout-direction environment.

Swift test execution, strict compilation, and native recapture require an Apple/Xcode
environment and are **NOT VERIFIED** for this change. Portable registry or lexical checks
do not satisfy those gates. Keep native and visual evidence flags unchanged until verified.

Before acceptance, recapture all three affected callers in real LTR and RTL environments,
including unequal slots, narrow widths, and accessibility sizes. In horizontal RTL, the
label / leading symbol / Attach slot must be rightmost, with the accessory / checkbox / Send
slot leftmost. Retain the IdentityHeader control. Exercise the existing native controls and
verify focus, state retention through reflow, and accessibility traversal separately;
screenshots alone cannot prove those interaction or accessibility properties.
