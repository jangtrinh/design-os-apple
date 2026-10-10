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
        for foreground in [palette.ink, palette.secondaryInk] {
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

@Test("Shared content reflows at every accessibility text size")
func applicationContentUsesAccessibleLayoutAxis() {
  for size in [DynamicTypeSize.xSmall, .large, .xxxLarge] {
    #expect(DesignOSAppContentLayout.axis(for: size) == .horizontal)
  }
  for size in [DynamicTypeSize.accessibility1, .accessibility2, .accessibility3,
    .accessibility4, .accessibility5]
  {
    #expect(DesignOSAppContentLayout.axis(for: size) == .vertical)
  }
}

@Test("Media backdrops fail closed for light appearance and accessibility preferences")
func mediaBackdropsHonorAppearanceAndAccessibility() {
  #expect(!DesignOSMediaBackdropPolicy.showsMedia(
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
  let intensity = DesignOSMediaBackdropPolicy.imageOpacity
    * (1 - DesignOSMediaBackdropPolicy.scrimOpacity)
  let channel = UInt32(ceil(intensity * 255))
  let brightestBackground = (channel << 16) | (channel << 8) | channel
  #expect(contrastRatio(DesignOSAppStyle.editorial.palette.secondaryInk.darkRGB,
    brightestBackground) >= 4.5)
}

@Test("Primary button hover and pressed feedback never changes disabled appearance")
func primaryButtonFeedbackHonorsDisabledState() {
  #expect(DesignOSPrimaryButtonAppearance.highlightOpacity(
    isEnabled: true, isPressed: false, isHovered: false) == 0)
  #expect(DesignOSPrimaryButtonAppearance.highlightOpacity(
    isEnabled: true, isPressed: true, isHovered: false) == 0.12)
  #expect(DesignOSPrimaryButtonAppearance.highlightOpacity(
    isEnabled: true, isPressed: false, isHovered: true) == 0.06)
  for pressed in [false, true] {
    for hovered in [false, true] {
      #expect(DesignOSPrimaryButtonAppearance.highlightOpacity(
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
  let action = Button("Continue") {}.buttonStyle(DesignOSPrimaryButtonStyle())
  let backdrop = DesignOSMediaBackdrop { Color.gray }
  let composed = VStack {
    header
    row
    surface
    action
  }
  .background { backdrop }
  .designOSAppStyle(.editorial)
  #expect(String(reflecting: type(of: composed)).contains("ModifiedContent"))
  #expect(String(reflecting: type(of: DesignOSAppSectionHeader("Items")))
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
    return normalized <= 0.04045 ? normalized / 12.92
      : pow((normalized + 0.055) / 1.055, 2.4)
  }
  return 0.2126 * linear((rgb >> 16) & 0xFF)
    + 0.7152 * linear((rgb >> 8) & 0xFF)
    + 0.0722 * linear(rgb & 0xFF)
}
