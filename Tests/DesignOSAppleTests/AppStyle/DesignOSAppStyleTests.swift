import CoreGraphics
import Foundation
import SwiftUI
import Testing

@testable import DesignOSApple

@Test("Application styles keep product state out of the shared runtime")
func applicationStyleContainsOnlyDesignLanguage() {
  let labels = Set(Mirror(reflecting: DesignOSAppStyle.editorial).children.compactMap(\.label))
  #expect(labels == ["profile", "palette", "metrics"])
  #expect(DesignOSAppStyle.editorial.profile == .default)
  #expect(DesignOSProfile.default.customContentCornerRadius == 12)
}

@Test("Editorial content geometry follows documented reference estimates")
func editorialGeometryMatchesDocumentedEstimates() {
  let metrics = DesignOSAppStyle.editorial.metrics
  #expect(metrics.pageInset == 20)
  #expect(metrics.itemSpacing == 12)
  #expect(metrics.mediaSize == 80)
  #expect(metrics.mediaRadius == 8)
  #expect(metrics.actionMinHeight == 54)
  #expect(metrics.surfaceRadius == 24)
  #expect(metrics.actionRadius == 12)
}

@Test("Application metrics reject every invalid axis independently")
func applicationMetricsValidateEachAxis() {
  for invalid in [CGFloat.nan, -1, .infinity] {
    for index in 0..<8 {
      var values: [CGFloat] = [20, 24, 16, 12, 24, 54, 80, 8]
      values[index] = invalid
      #expect(throws: DesignOSAppStyleError.invalidMetric) {
        try makeAppMetrics(values)
      }
    }
  }
  #expect(throws: DesignOSAppStyleError.invalidMetric) {
    try makeAppMetrics([20, 24, 16, 12, 24, 43, 80, 8])
  }
  #expect(throws: DesignOSAppStyleError.invalidMetric) {
    try makeAppMetrics([20, 24, 16, 12, 24, 54, 0, 0])
  }
  #expect(throws: DesignOSAppStyleError.invalidMetric) {
    try makeAppMetrics([20, 24, 16, 12, 24, 54, 80, 41])
  }
  for invalid in [CGFloat.nan, -1, .infinity] {
    #expect(throws: DesignOSAppStyleError.invalidMetric) {
      try DesignOSAppMetrics(
        pageInset: 20, sectionSpacing: 24, contentInset: 16, itemSpacing: 12,
        surfaceRadius: 24, actionMinHeight: 54, mediaSize: 80, mediaRadius: 8,
        actionRadius: invalid
      )
    }
  }
}

@Test("Adaptive colors resolve all appearance and contrast combinations")
func adaptiveColorsResolveAllVariants() throws {
  let color = try DesignOSAdaptiveColor(
    lightRGB: 0x12_3456,
    darkRGB: 0x65_4321,
    increasedContrastLightRGB: 0x00_0000,
    increasedContrastDarkRGB: 0xFF_FFFF
  )
  #expect(color.resolvedRGB(dark: false, increasedContrast: false) == 0x12_3456)
  #expect(color.resolvedRGB(dark: true, increasedContrast: false) == 0x65_4321)
  #expect(color.resolvedRGB(dark: false, increasedContrast: true) == 0x00_0000)
  #expect(color.resolvedRGB(dark: true, increasedContrast: true) == 0xFF_FFFF)
  let inherited = try DesignOSAdaptiveColor(lightRGB: 0x12_3456, darkRGB: 0x65_4321)
  #expect(inherited.increasedContrastLightRGB == inherited.lightRGB)
  #expect(inherited.increasedContrastDarkRGB == inherited.darkRGB)
}

@Test("Adaptive color construction rejects non-RGB values in every variant")
func adaptiveColorsRejectValuesOutsideRGB() {
  for index in 0..<4 {
    var values: [UInt32] = [0xFF_FFFF, 0x00_0000, 0xFF_FFFF, 0x00_0000]
    values[index] = 0x100_0000
    #expect(throws: DesignOSAppStyleError.invalidColor) {
      try DesignOSAdaptiveColor(
        lightRGB: values[0], darkRGB: values[1],
        increasedContrastLightRGB: values[2], increasedContrastDarkRGB: values[3]
      )
    }
  }
}

@Test("Editorial text and action pairs meet normal-text contrast in every appearance")
func editorialPaletteMeetsTextContrast() {
  let palette = DesignOSAppStyle.editorial.palette
  for dark in [false, true] {
    for increased in [false, true] {
      for background in [palette.canvas, palette.surface, palette.subtleSurface] {
        for foreground in [palette.ink, palette.secondaryInk, palette.dangerInk] {
          #expect(
            contrastRatio(
              foreground.resolvedRGB(dark: dark, increasedContrast: increased),
              background.resolvedRGB(dark: dark, increasedContrast: increased)
            ) >= 4.5
          )
        }
      }
      #expect(
        contrastRatio(
          palette.actionInk.resolvedRGB(dark: dark, increasedContrast: increased),
          palette.action.resolvedRGB(dark: dark, increasedContrast: increased)
        ) >= 4.5
      )
    }
  }
}

@Test("Semantic danger preserves the existing destructive colors in all four variants")
func defaultDangerInkPreservesExistingColors() {
  let danger = DesignOSAppPalette.defaultDangerInk
  #expect(DesignOSAppStyle.editorial.palette.dangerInk == danger)
  #expect(danger.resolvedRGB(dark: false, increasedContrast: false) == 0xB4_2318)
  #expect(danger.resolvedRGB(dark: true, increasedContrast: false) == 0xFF_B4AB)
  #expect(danger.resolvedRGB(dark: false, increasedContrast: true) == 0x8C_0D05)
  #expect(danger.resolvedRGB(dark: true, increasedContrast: true) == 0xFF_DAD6)
}

@Test("Existing custom palette initializers preserve destructive, message, and disabled defaults")
func customPalettePreservesDefaultDangerInk() throws {
  let base = DesignOSAppStyle.editorial.palette
  let surface = try DesignOSAdaptiveColor(lightRGB: 0xFF_F8E1, darkRGB: 0x10_2233)
  let ink = try DesignOSAdaptiveColor(lightRGB: 0x22_1100, darkRGB: 0xEE_FFFF)
  let subtleSurface = try DesignOSAdaptiveColor(lightRGB: 0xEE_E0CD, darkRGB: 0x20_3040)
  let secondaryInk = try DesignOSAdaptiveColor(lightRGB: 0x44_3322, darkRGB: 0xCC_DDEE)
  // This original initializer call must continue to compile without the optional roles.
  let palette = DesignOSAppPalette(
    canvas: base.canvas, surface: surface, subtleSurface: subtleSurface,
    ink: ink, secondaryInk: secondaryInk, separator: base.separator,
    action: base.action, actionInk: base.actionInk
  )
  #expect(palette.dangerInk == DesignOSAppPalette.defaultDangerInk)
  #expect(palette.outgoingMessage == DesignOSAppColorPair(background: surface, foreground: ink))
  #expect(
    palette.disabledAction == DesignOSAppColorPair(
      background: subtleSurface, foreground: secondaryInk
    )
  )
  for prominence in [DesignOSActionButtonProminence.primary, .secondary] {
    for destructive in [false, true] {
      #expect(
        DesignOSPrimaryButtonAppearance.foreground(
          palette: palette, prominence: prominence, isEnabled: false, isDestructive: destructive
        ) == secondaryInk
      )
      #expect(
        DesignOSPrimaryButtonAppearance.background(
          palette: palette, prominence: prominence, isEnabled: false, isDestructive: destructive
        ) == subtleSurface
      )
    }
  }
  for treatment in [DesignOSSecondaryButtonStyle.Treatment.filled, .outlined] {
    #expect(
      DesignOSSecondaryButtonAppearance.background(
        palette: palette, treatment: treatment, isEnabled: false
      ) == subtleSurface
    )
  }
  #expect(
    DesignOSPrimaryButtonAppearance.background(
      palette: palette, prominence: .primary, isEnabled: true, isDestructive: true
    ) == base.dangerInk
  )
  #expect(
    DesignOSPrimaryButtonAppearance.foreground(
      palette: palette, prominence: .secondary, isEnabled: true, isDestructive: true
    ) == base.dangerInk
  )
}

@Test("Editorial disabled actions use subdued reference colors and readable contrast fallbacks")
func editorialDisabledActionResolvesOnlyItsOwnPair() {
  let palette = DesignOSAppStyle.editorial.palette
  let disabled = palette.disabledAction
  #expect(disabled.background.lightRGB == 0xCE_CED0)
  #expect(disabled.foreground.lightRGB == 0xFF_FFFF)
  #expect(disabled.background.darkRGB == 0x26_2626)
  #expect(disabled.foreground.darkRGB == 0x4E_4E4E)
  for dark in [false, true] {
    // This deliberate exception applies only to actually disabled native actions.
    // Active content remains covered by editorialPaletteMeetsTextContrast.
    #expect(
      contrastRatio(
        disabled.foreground.resolvedRGB(dark: dark, increasedContrast: false),
        disabled.background.resolvedRGB(dark: dark, increasedContrast: false)
      ) < 4.5
    )
    #expect(
      disabled.background.resolvedRGB(dark: dark, increasedContrast: true)
        == palette.subtleSurface.resolvedRGB(dark: dark, increasedContrast: true)
    )
    #expect(
      disabled.foreground.resolvedRGB(dark: dark, increasedContrast: true)
        == palette.secondaryInk.resolvedRGB(dark: dark, increasedContrast: true)
    )
    #expect(
      contrastRatio(
        disabled.foreground.resolvedRGB(dark: dark, increasedContrast: true),
        disabled.background.resolvedRGB(dark: dark, increasedContrast: true)
      ) >= 4.5
    )
  }
}

@Test("A custom disabled pair never changes enabled action colors or active content roles")
func customDisabledActionDoesNotLeakIntoEnabledContent() throws {
  let base = DesignOSAppStyle.editorial.palette
  let disabled = DesignOSAppColorPair(
    background: try DesignOSAdaptiveColor(lightRGB: 0xAB_CDEF, darkRGB: 0x12_3456),
    foreground: try DesignOSAdaptiveColor(lightRGB: 0xFE_DCBA, darkRGB: 0x65_4321)
  )
  let palette = DesignOSAppPalette(
    canvas: base.canvas, surface: base.surface, subtleSurface: base.subtleSurface,
    ink: base.ink, secondaryInk: base.secondaryInk, separator: base.separator,
    action: base.action, actionInk: base.actionInk,
    outgoingMessage: base.outgoingMessage, dangerInk: base.dangerInk, disabledAction: disabled
  )
  #expect(palette.disabledAction == disabled)
  #expect(palette.ink == base.ink)
  #expect(palette.secondaryInk == base.secondaryInk)
  #expect(palette.dangerInk == base.dangerInk)
  #expect(palette.subtleSurface == base.subtleSurface)
  #expect(palette.outgoingMessage == base.outgoingMessage)
  for prominence in [DesignOSActionButtonProminence.primary, .secondary] {
    for destructive in [false, true] {
      let enabledForeground =
        prominence == .primary ? base.actionInk : (destructive ? base.dangerInk : base.ink)
      let enabledBackground =
        prominence == .primary ? (destructive ? base.dangerInk : base.action) : base.subtleSurface
      for enabled in [false, true] {
        #expect(
          DesignOSPrimaryButtonAppearance.foreground(
            palette: palette, prominence: prominence, isEnabled: enabled,
            isDestructive: destructive
          ) == (enabled ? enabledForeground : disabled.foreground)
        )
        #expect(
          DesignOSPrimaryButtonAppearance.background(
            palette: palette, prominence: prominence, isEnabled: enabled,
            isDestructive: destructive
          ) == (enabled ? enabledBackground : disabled.background)
        )
      }
    }
  }
  for treatment in [DesignOSSecondaryButtonStyle.Treatment.filled, .outlined] {
    #expect(
      DesignOSSecondaryButtonAppearance.background(
        palette: palette, treatment: treatment, isEnabled: true
      ) == (treatment == .filled ? base.subtleSurface : base.canvas)
    )
    #expect(
      DesignOSSecondaryButtonAppearance.background(
        palette: palette, treatment: treatment, isEnabled: false
      ) == disabled.background
    )
  }
}

@Test("Custom semantic danger is shared by destructive actions without changing other roles")
func customDangerInkFlowsToDestructiveActions() throws {
  let base = DesignOSAppStyle.editorial.palette
  let danger = try DesignOSAdaptiveColor(
    lightRGB: 0x80_0000, darkRGB: 0xFF_CCCC,
    increasedContrastLightRGB: 0x60_0000, increasedContrastDarkRGB: 0xFF_EEEE
  )
  let palette = DesignOSAppPalette(
    canvas: base.canvas, surface: base.surface, subtleSurface: base.subtleSurface,
    ink: base.ink, secondaryInk: base.secondaryInk, separator: base.separator,
    action: base.action, actionInk: base.actionInk,
    outgoingMessage: base.outgoingMessage, dangerInk: danger
  )
  #expect(palette.dangerInk == danger)
  #expect(palette.outgoingMessage == base.outgoingMessage)
  for enabled in [false, true] {
    for destructive in [false, true] {
      #expect(
        DesignOSPrimaryButtonAppearance.background(
          palette: palette, prominence: .primary, isEnabled: enabled, isDestructive: destructive
        ) == (enabled ? (destructive ? danger : base.action) : base.subtleSurface)
      )
      #expect(
        DesignOSPrimaryButtonAppearance.foreground(
          palette: palette, prominence: .secondary, isEnabled: enabled, isDestructive: destructive
        ) == (enabled ? (destructive ? danger : base.ink) : base.secondaryInk)
      )
      #expect(
        DesignOSPrimaryButtonAppearance.foreground(
          palette: palette, prominence: .primary, isEnabled: enabled, isDestructive: destructive
        ) == (enabled ? base.actionInk : base.secondaryInk)
      )
      #expect(
        DesignOSPrimaryButtonAppearance.background(
          palette: palette, prominence: .secondary, isEnabled: enabled, isDestructive: destructive
        ) == base.subtleSurface
      )
    }
  }
}

@Test("Shared content reflows at every accessibility text size")
func applicationContentUsesAccessibleLayoutAxis() {
  for size in [DynamicTypeSize.xSmall, .large, .xxxLarge] {
    #expect(DesignOSAppContentLayout.axis(for: size) == .horizontal)
  }
  for size in [
    DynamicTypeSize.accessibility1, .accessibility2, .accessibility3,
    .accessibility4, .accessibility5,
  ] {
    #expect(DesignOSAppContentLayout.axis(for: size) == .vertical)
  }
}

@Test("Media backdrops fail closed for light appearance and accessibility preferences")
func mediaBackdropsHonorAppearanceAndAccessibility() {
  #expect(
    !DesignOSMediaBackdropPolicy.showsMedia(
      dark: true, reduceTransparency: false, increasedContrast: false, allowsTranslucency: false))
  for dark in [false, true] {
    for reduceTransparency in [false, true] {
      for increasedContrast in [false, true] {
        #expect(
          DesignOSMediaBackdropPolicy.showsMedia(
            dark: dark, reduceTransparency: reduceTransparency,
            increasedContrast: increasedContrast
          ) == (dark && !reduceTransparency && !increasedContrast)
        )
      }
    }
  }
}

@Test("Editorial ambient media maintains text contrast even over a white source image")
func ambientBackdropBoundsWorstCaseContrast() {
  let intensity =
    DesignOSMediaBackdropPolicy.imageOpacity
    * (1 - DesignOSMediaBackdropPolicy.scrimOpacity)
  let channel = UInt32(ceil(intensity * 255))
  let brightestBackground = (channel << 16) | (channel << 8) | channel
  #expect(
    contrastRatio(
      DesignOSAppStyle.editorial.palette.secondaryInk.darkRGB,
      brightestBackground) >= 4.5)
}

@Test("Ambient content groups fall back to opaque surfaces for accessibility preferences")
func ambientGroupsHonorAccessibilityPreferences() {
  for dark in [false, true] {
    for reduced in [false, true] {
      for increased in [false, true] {
        for allowed in [false, true] {
          #expect(
            DesignOSAppSurfacePolicy.usesAmbientFill(
              dark: dark, reduceTransparency: reduced,
              increasedContrast: increased, allowsTranslucency: allowed
            ) == (dark && !reduced && !increased && allowed)
          )
        }
      }
    }
  }
}

@Test("Ambient content groups preserve metadata contrast over the brightest backdrop")
func ambientGroupsBoundWorstCaseTextContrast() {
  let backdropIntensity =
    DesignOSMediaBackdropPolicy.imageOpacity
    * (1 - DesignOSMediaBackdropPolicy.scrimOpacity)
  let groupOpacity = DesignOSAppSurfacePolicy.ambientFillOpacity
  let compositeIntensity = backdropIntensity * (1 - groupOpacity) + groupOpacity
  let channel = UInt32(ceil(compositeIntensity * 255))
  let brightestBackground = (channel << 16) | (channel << 8) | channel
  #expect(
    contrastRatio(
      DesignOSAppStyle.editorial.palette.secondaryInk.darkRGB,
      brightestBackground) >= 4.5
  )
}

@Test("Primary button hover and pressed feedback never changes disabled appearance")
func primaryButtonFeedbackHonorsDisabledState() {
  #expect(
    DesignOSPrimaryButtonAppearance.highlightOpacity(
      isEnabled: true, isPressed: false, isHovered: false) == 0)
  #expect(
    DesignOSPrimaryButtonAppearance.highlightOpacity(
      isEnabled: true, isPressed: true, isHovered: false) == 0.12)
  #expect(
    DesignOSPrimaryButtonAppearance.highlightOpacity(
      isEnabled: true, isPressed: false, isHovered: true) == 0.06)
  for pressed in [false, true] {
    for hovered in [false, true] {
      #expect(
        DesignOSPrimaryButtonAppearance.highlightOpacity(
          isEnabled: false, isPressed: pressed, isHovered: hovered) == 0)
    }
  }
}

@Test("Primary button hover and pressed fills retain normal-text contrast")
func primaryButtonInteractionStatesRetainContrast() {
  let palette = DesignOSAppStyle.editorial.palette
  for dark in [false, true] {
    for increased in [false, true] {
      let foreground = palette.actionInk.resolvedRGB(dark: dark, increasedContrast: increased)
      let background = palette.action.resolvedRGB(dark: dark, increasedContrast: increased)
      for opacity in [0.0, 0.06, 0.12] {
        var blended: UInt32 = 0
        for shift in [16, 8, 0] {
          let top = Double((foreground >> shift) & 0xFF)
          let bottom = Double((background >> shift) & 0xFF)
          blended |= UInt32((top * opacity + bottom * (1 - opacity)).rounded()) << shift
        }
        #expect(contrastRatio(foreground, blended) >= 4.5)
      }
    }
  }
}

@Test("Primary and secondary content buttons preserve destructive and disabled cues")
func contentButtonStylesPreserveSemanticCues() {
  let palette = DesignOSAppStyle.editorial.palette
  #expect(
    DesignOSPrimaryButtonAppearance.background(
      palette: palette, prominence: .primary, isEnabled: true, isDestructive: true
    ) == palette.dangerInk
  )
  #expect(
    DesignOSPrimaryButtonAppearance.foreground(
      palette: palette, prominence: .secondary, isEnabled: true, isDestructive: true
    ) == palette.dangerInk
  )
  for prominence in [DesignOSActionButtonProminence.primary, .secondary] {
    for destructive in [false, true] {
      #expect(
        DesignOSPrimaryButtonAppearance.foreground(
          palette: palette, prominence: prominence, isEnabled: false,
          isDestructive: destructive
        ) == palette.disabledAction.foreground
      )
      #expect(
        DesignOSPrimaryButtonAppearance.background(
          palette: palette, prominence: prominence, isEnabled: false,
          isDestructive: destructive
        ) == palette.disabledAction.background
      )
    }
  }
}

@Test("Both enabled pill styles and increased-contrast disabled actions retain readable labels")
func contentButtonStylesMeetContrastAcrossStates() {
  let palette = DesignOSAppStyle.editorial.palette
  for prominence in [DesignOSActionButtonProminence.primary, .secondary] {
    for destructive in [false, true] {
      for enabled in [false, true] {
        let foreground = DesignOSPrimaryButtonAppearance.foreground(
          palette: palette, prominence: prominence, isEnabled: enabled,
          isDestructive: destructive
        )
        let background = DesignOSPrimaryButtonAppearance.background(
          palette: palette, prominence: prominence, isEnabled: enabled,
          isDestructive: destructive
        )
        for dark in [false, true] {
          // Active contrast gates are unchanged. Only standard-contrast disabled actions
          // use the separate subdued role tested by editorialDisabledActionResolvesOnlyItsOwnPair.
          for increased in enabled ? [false, true] : [true] {
            let ink = foreground.resolvedRGB(dark: dark, increasedContrast: increased)
            let fill = background.resolvedRGB(dark: dark, increasedContrast: increased)
            for opacity in enabled ? [0.0, 0.06, 0.12] : [0.0] {
              var blended: UInt32 = 0
              for shift in [16, 8, 0] {
                let top = Double((ink >> shift) & 0xFF)
                let bottom = Double((fill >> shift) & 0xFF)
                blended |= UInt32((top * opacity + bottom * (1 - opacity)).rounded()) << shift
              }
              #expect(contrastRatio(ink, blended) >= 4.5)
            }
          }
        }
      }
    }
  }
}

@Test("App-style components retain caller-owned views and native buttons")
@MainActor
func appStyleCompositionsCompile() {
  let row = DesignOSMediaRow {
    Image(systemName: "photo").resizable().scaledToFit().accessibilityHidden(true)
  } content: {
    Text("A caller-owned item")
  }
  let header = DesignOSAppSectionHeader("Items") {
    Button("See all") {}
  }
  let surface = DesignOSAppSurface { Text("Details") }
  let ambient = DesignOSAppSurface(tone: .ambient) { Text("Media details") }
  let action = Button("Continue") {}.buttonStyle(DesignOSPrimaryButtonStyle())
  let secondary = Button("Choose another") {}.buttonStyle(DesignOSSecondaryButtonStyle())
  let field = TextField("Name", text: .constant("Local fixture"))
    .modifier(DesignOSAppTextFieldModifier())
  let backdrop = DesignOSMediaBackdrop { Color.gray }
  let composed = VStack {
    header
    row
    surface
    ambient
    action
    secondary
    field
  }
  .background { backdrop }
  .designOSAppStyle(.editorial)
  #expect(String(reflecting: type(of: composed)).contains("ModifiedContent"))
  #expect(
    String(reflecting: type(of: DesignOSAppSectionHeader("Items")))
      .contains("DesignOSAppSectionHeader"))
}

private func makeAppMetrics(_ values: [CGFloat]) throws -> DesignOSAppMetrics {
  try DesignOSAppMetrics(
    pageInset: values[0], sectionSpacing: values[1], contentInset: values[2],
    itemSpacing: values[3], surfaceRadius: values[4], actionMinHeight: values[5],
    mediaSize: values[6], mediaRadius: values[7]
  )
}

private func contrastRatio(_ first: UInt32, _ second: UInt32) -> Double {
  let firstLuminance = relativeLuminance(first)
  let secondLuminance = relativeLuminance(second)
  return (max(firstLuminance, secondLuminance) + 0.05)
    / (min(firstLuminance, secondLuminance) + 0.05)
}

private func relativeLuminance(_ rgb: UInt32) -> Double {
  func linear(_ value: UInt32) -> Double {
    let normalized = Double(value) / 255
    return normalized <= 0.04045
      ? normalized / 12.92
      : pow((normalized + 0.055) / 1.055, 2.4)
  }
  return 0.2126 * linear((rgb >> 16) & 0xFF)
    + 0.7152 * linear((rgb >> 8) & 0xFF)
    + 0.0722 * linear(rgb & 0xFF)
}
