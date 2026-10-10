# Reusable application style

The opt-in `DesignOSAppStyle.editorial` gives future Apple apps the same image-led, monochrome
design language. It is an additive runtime application style, separate from the sealed
management tokens and the existing native recipe/profile contracts. The public name is
unbranded; no affiliation with the reference app is implied.

The [reference study](luma-style-reference.md) records the exact Luma events collection, screen
links, inspected light/dark/composer states, and visual limitations. Reference screenshots,
wordmarks, event posters, and custom navigation icons are not distributed as app assets.

## Discover the shared kit

The [machine-readable editorial index](app-styles/editorial/manifest.json) lists the Swift
module, preset, environment modifier, component IDs and source paths, variants, required
states, compile-specimen reference, and native verification commands. Paths are repository-
relative. It contains requirements only, with no copied token values or verification claims.
Use the referenced Swift declarations and the examples below when composing another app.

The [organization guide](design-system-organization.md) explains design authority and
product ownership. The index does not change the sealed DESIGN:OS registry or admit new
release-catalog stories. Run `python3 scripts/verify-app-style-registry.py` for structural
drift checks; native compilation and rendered acceptance remain separate.

## Adopt once at the product boundary

```swift
import DesignOSApple
import SwiftUI

struct ProductRoot: View {
  var body: some View {
    NavigationStack {
      ProductContent()
    }
    .designOSAppStyle(.editorial)
  }
}
```

The modifier injects the app style and its existing `DesignOSProfile`. It does not force light
or dark mode, change app tint, replace navigation or presentations, or repaint native control
chrome. Existing clients that use only `DesignOSProfile` remain unchanged. The preset uses the
standard system font design and the unchanged default semantic profile.

Read app roles where the product owns its content:

```swift
@Environment(\.designOSAppStyle) private var style

// A caller-owned content canvas:
ScrollView {
  VStack(alignment: .leading, spacing: style.metrics.sectionSpacing) {
    DesignOSAppSectionHeader("Recent items")
    // Product-owned content and real actions go here.
  }
  .padding(.horizontal, style.metrics.pageInset)
}
.background(style.palette.canvas.color)
```

Use system roles for platform alerts and semantic warning/error states. App roles describe
canvas, surfaces, primary/supporting text, quiet separators, and primary actions. Do not use
a faint separator as the only indicator of control boundaries or state.

## Content composition, with native interaction

`DesignOSMediaRow` gives arbitrary media and arbitrary label content an aligned, flat row.
It does not create a card, separator, gesture, navigation destination, or accessibility label.
Wrap it in a real `NavigationLink` or `Button` when needed. Supply accessible media labels or
hide a decorative thumbnail from accessibility when adjacent text already describes it.

```swift
DesignOSMediaRow {
  image.resizable().scaledToFill().accessibilityHidden(true)
} content: {
  VStack(alignment: .leading, spacing: 4) {
    Text(item.title).font(.headline)
    Text(item.subtitle)
      .font(.subheadline)
      .foregroundStyle(style.palette.secondaryInk.color)
  }
}
```

`DesignOSAppSectionHeader("Title") { action }` provides a semantic heading with an optional
caller-owned accessory. Media rows and headings switch to vertical composition at accessibility
Dynamic Type sizes. Labels are not constrained to a fixed line count.

`DesignOSAppSurface(tone: .standard)` and `.subtle` are opaque content groupings, with profile
padding and a continuous rounded background. `.ambient` gives dark media forms a restrained
10% white lift, with an opaque fallback in light appearance or when Reduce Transparency,
Increase Contrast, or the profile's opaque-only policy applies. Host real native fields inside
these groups when a native scrolling content layout is appropriate. Use them sparingly for
meaningful groups. The
reference diary is a flat feed; wrapping each row in a card loses its visual structure. Do not
nest surfaces. These groups add appearance only; they do not implement scrolling, selection,
focus, validation, or input behavior. Compose them with a native `ScrollView` and real fields
when appropriate, or keep native `List`/`Form` composition where its behavior is needed. Sheets
and toolbar materials remain native.

`DesignOSPrimaryButtonStyle()` and `DesignOSSecondaryButtonStyle()` style actual `Button`s as
full continuous capsules. This follows the user's later full-pill direction, overriding the
reference's inferred 12-point rectangular action corners. Capsule geometry follows the actual
height, including multiline Dynamic Type labels; there is no fixed radius that can stop being
a pill. The legacy `metrics.actionRadius` remains source-compatible but has no effect on these
styles.

Both styles retain native activation, accessibility, keyboard interaction, and caller-owned
disabled state. They share a 54-point minimum height, visible keyboard-focus outline, and
distinct pressed/hover/disabled appearances, with no added animation. Secondary actions use a
quiet adaptive fill. A destructive `Button` keeps its native role and a readable red cue: a red
primary fill or red secondary label. The accessible danger pair (`#B42318` / `#FFB4AB`, with
stronger increased-contrast variants) is a semantic safety choice, not a measured Luma token.
System alerts and menus keep their native presentation and behavior.

```swift
Button("Continue", action: continueAction)
  .buttonStyle(DesignOSPrimaryButtonStyle())
  .disabled(!canContinue)

Button("Choose another", action: chooseAnother)
  .buttonStyle(DesignOSSecondaryButtonStyle())
```

## Continuous and nested image corners

Caller-owned images and surfaces use `RoundedRectangle(..., style: .continuous)` for a smooth
corner transition. This is our design rule; Apple does not mandate a universal radius value.
Standalone covers and sibling thumbnails keep the appropriate semantic radius for their size.

For a genuinely concentric image inside a rounded parent, derive the inner radius from the
parent's actual edge inset, including padding and any intervening border:

```swift
let innerRadius = DesignOSCornerGeometry.innerRadius(
  outerRadius: outerRadius,
  inset: actualInset
)

image.resizable().scaledToFill()
  .clipShape(RoundedRectangle(cornerRadius: innerRadius, style: .continuous))
  .padding(actualInset)
  .background(
    style.palette.surface.color,
    in: RoundedRectangle(cornerRadius: outerRadius, style: .continuous)
  )
```

The helper applies `max(0, outerRadius - inset)`. It returns zero for negative or non-finite
input to keep invalid geometry out of drawing. Use the same actual inset in the layout and
the calculation. Do not subtract a screen margin from a standalone photo radius, apply this
rule between siblings, or add an unnecessary card merely to create nesting. If per-corner
insets differ, derive each corresponding corner separately.

## Media atmosphere

`DesignOSMediaBackdrop { media }` accepts an app-owned image view. Use it as a background behind
a crisp foreground image, never as a data container. It cannot intercept input and is hidden
from accessibility. It does not fetch media or store photos.

```swift
content.background {
  DesignOSMediaBackdrop {
    image.resizable().scaledToFill()
  }
}
```

The decorative blur appears only in dark presentation. Light presentation, Reduce Transparency,
Increase Contrast, or the profile's `opaqueOnly` policy uses an opaque canvas. The component
does not force appearance; a product may opt a media composer into dark presentation to follow
the inspected reference. Without a photo, use a neutral opaque surface rather than inventing
image recognition or unrelated ambient artwork. Native form groups can use native material over
the backdrop with an opaque fallback for the same accessibility settings.

The blur radius of 64 points, image opacity of 0.5, and canvas scrim opacity of 0.5 are
reconstruction choices, not extracted source parameters. Together they cap a white image pixel
at approximately `#404040` over the editorial black canvas. Adding a 10% white ambient group
raises that bound to approximately `#535353`; the preset's `#CCCCCC` metadata still has a
computed contrast ratio of 4.79:1 against the combined bound. There is no animated blur, so Reduce
Motion does not require a different motion path. This calculation covers the backdrop and
preset text pair, not every material or control a consuming app may add.

## Provenance and reconstruction choices

The source images are 1179–1180 pixels wide. Geometry below assumes an approximately
393-point-wide screenshot; scale metadata was not supplied. Therefore point values are inferred
even where the corresponding raster distance is clear. Colors are JPEG pixel observations,
not recovered original source tokens.

| Runtime role | Values | Evidence status |
| --- | --- | --- |
| Canvas | light `#FFFFFF`, dark `#000000` | Measured broad areas in light/dark home |
| Primary ink | light `#161616`, dark `#FFFFFF` | Representative measured glyph cores |
| Secondary ink | light `#666666`, dark `#CCCCCC` | Representative measured metadata glyph cores |
| Separator | light `#F0F0F0`, dark `#252525` | Representative measured thin lines |
| Action / action ink | inverse `#161616` and `#FFFFFF` | White dark-detail action observed; adaptive inverse inferred |
| Opaque surface | light `#F7F7F7`, dark `#242424` | Accessible neutral fallback, inferred |
| Subtle surface | light `#F0F0F0`, dark `#181818` | Inferred reuse of observed neutral composites |
| Increased contrast | ink `#000000`; supporting ink `#454545` / `#F0F0F0`; separator `#767676` / `#808080` | Accessibility adaptation, not source measurements |
| Page inset / media / gap | 20 / 80 / 12 pt | Inferred from about 60 / 240 / 36 source pixels |
| Media radius | 8 pt | Inferred thumbnail geometry |
| Section spacing / content inset | 24 / 16 pt | Inferred native composition values |
| Surface radius | 24 pt | Inferred lower end of composer groups, approximately 24–28 pt |
| Content action | minimum 54 pt, full continuous capsule | Height inferred from reference; pill shape follows later user direction |
| Type | native semantic styles; section uses emphasized `.title3` | System sans visual equivalent, not recovered font specification |
| Backdrop | 64 pt blur, 0.5 image opacity, 0.5 scrim | Inferred optical recipe with a contrast bound |
| Ambient content group | 10% white in dark media presentation | Inferred midpoint of the observed 8–12% lift, opaque accessibility fallback |

The light tertiary `#999999` source label is not offered as a default body-text role because
it would fail 4.5:1 against white. Supporting text uses the stronger observed secondary role.
Native materials, SF Symbols, semantic fonts, and system controls are deliberate native
equivalents. There is no claim of 100% or pixel-identical fidelity.

## Extend without forking an app

Create a new immutable `DesignOSAppStyle` from a `DesignOSProfile`, `DesignOSAppPalette`, and
`DesignOSAppMetrics`. `DesignOSAdaptiveColor` accepts light/dark 24-bit RGB values and optional
increased-contrast variants; UIKit/AppKit resolve them from the actual rendering traits. Values
outside RGB range, non-finite/negative metrics, primary-action heights below 44 points, and
invalid thumbnail geometry are rejected.

The palette initializer does not guarantee contrast for arbitrary custom pairs. New presets
must verify every text/background pairing, native material context, focus state, disabled
appearance, and the worst-case media backdrop. The editorial contrast bound does not apply
unchanged when a custom palette changes its dark canvas or secondary ink.

Keep app data, user photos, titles, navigation destinations, selection, persistence, network
analysis, and health or other domain logic in the consuming app. Reuse the design language
and content geometry rather than copying product state into the library.

## Verification contract

Focused tests live in `Tests/DesignOSAppleTests/AppStyle/` and cover:

- Immutable design-only storage and unchanged existing default profile
- Color and metric validation, including the 44-point action floor
- Light/dark and increased-contrast resolution, including native platform adapters
- Normal text contrast across every opaque preset surface and primary action pair
- Dynamic Type reflow, disabled action feedback, and opaque backdrop fallbacks
- Worst-case ambient-media contrast and compile-time native composition

Calculated palette minima are 5.04:1 in light appearance and 9.67:1 in dark appearance. The
primary action pair is 18.10:1. These are color calculations, not rendered UI or VoiceOver
acceptance results. Rendered app screenshots, device accessibility, native keyboard focus,
and source comparisons must be checked separately by the consuming app's native test lane.
Deterministic tests always assert all four appearance/contrast RGB variants. Native AppKit
provider tests additionally check that the system actually supplies the requested appearance.
On the observed macOS 26.6 CI runner, requesting high-contrast appearance names returned ordinary
light/dark appearance objects instead. The high-contrast native test is therefore explicitly
skipped as NOT VERIFIED when genuine fixtures are unavailable, rather than treating the name
requested as evidence of the appearance supplied. Tests initialize `NSApplication` but never
change system accessibility preferences. Public SwiftUI high-contrast rendering remains a
separate native accessibility check with the real Increase Contrast system setting enabled.

Web HTML gates are not applicable to this SwiftUI runtime. On an Apple toolchain, run the
repository's `scripts/verify-swift-package.sh`, then the consuming app's native UI suite.
Screenshots must include both appearances, media and no-media states, large text, and
accessibility fallbacks before calling the visual implementation verified.

Platform implementation references: [UIKit dynamic colors](https://developer.apple.com/documentation/uikit/uicolor/init(dynamicprovider:)),
[AppKit dynamic colors](https://developer.apple.com/documentation/appkit/nscolor/init(name:dynamicprovider:)),
and [SwiftUI ButtonStyle](https://developer.apple.com/documentation/swiftui/buttonstyle).
