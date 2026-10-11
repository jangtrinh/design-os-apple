import Foundation
import SwiftUI
import Testing

@testable import DesignOSApple

@Test("Secondary buttons preserve the existing regular filled default")
@MainActor
func secondaryButtonDefaultIsSourceCompatible() {
  let style = DesignOSSecondaryButtonStyle()
  #expect(style.size == .regular)
  #expect(style.treatment == .filled)
  let layout = DesignOSSecondaryButtonLayout(
    metrics: DesignOSAppStyle.editorial.metrics, size: .regular
  )
  #expect(layout.horizontalInset == 20)
  #expect(layout.verticalInset == 12)
  #expect(layout.maximumWidth == .infinity)
  #expect(layout.minimumVisualHeight == 54)
  #expect(layout.typography == .headline)
}

@Test("Compact capsules separate content-sized artwork from the minimum interaction target")
func compactSecondaryButtonUsesSemanticMetrics() throws {
  for inset in [CGFloat(0), 16, 24] {
    let metrics = try DesignOSAppMetrics(
      pageInset: 28, sectionSpacing: 24, contentInset: inset, itemSpacing: 14,
      surfaceRadius: 24, actionMinHeight: 60, mediaSize: 80, mediaRadius: 8
    )
    let layout = DesignOSSecondaryButtonLayout(metrics: metrics, size: .compact)
    #expect(layout.horizontalInset == inset)
    #expect(layout.verticalInset == inset / 2)
    #expect(layout.maximumWidth == nil)
    #expect(layout.minimumVisualHeight == nil)
    #expect(layout.typography == .body)
    #expect(DesignOSSecondaryButtonLayout.minimumInteractionSize == 44)
  }
}

@Test("Outlined capsules use the app canvas and filled capsules retain the secondary surface")
func secondaryButtonTreatmentsUseSemanticPalette() {
  let palette = DesignOSAppStyle.editorial.palette
  #expect(
    DesignOSSecondaryButtonAppearance.background(
      palette: palette, treatment: .outlined, isEnabled: true
    ) == palette.canvas
  )
  #expect(
    DesignOSSecondaryButtonAppearance.background(
      palette: palette, treatment: .filled, isEnabled: true
    ) == palette.subtleSurface
  )
}

@Test("Every disabled secondary treatment shares the regular action color pair")
func secondaryButtonDisabledTreatmentsShareActionPair() {
  let palette = DesignOSAppStyle.editorial.palette
  for treatment in [DesignOSSecondaryButtonStyle.Treatment.filled, .outlined] {
    #expect(
      DesignOSSecondaryButtonAppearance.background(
        palette: palette, treatment: treatment, isEnabled: false
      ) == palette.disabledAction.background
    )
    for destructive in [false, true] {
      #expect(
        DesignOSPrimaryButtonAppearance.foreground(
          palette: palette, prominence: .secondary, isEnabled: false,
          isDestructive: destructive
        ) == palette.disabledAction.foreground
      )
    }
  }
}

@Test("Enabled secondary treatments and increased-contrast disabled actions retain readable labels")
func secondaryButtonVariantsRetainTextContrast() {
  let palette = DesignOSAppStyle.editorial.palette
  for treatment in [DesignOSSecondaryButtonStyle.Treatment.filled, .outlined] {
    for destructive in [false, true] {
      for enabled in [false, true] {
        let background = DesignOSSecondaryButtonAppearance.background(
          palette: palette, treatment: treatment, isEnabled: enabled
        )
        let foreground = DesignOSPrimaryButtonAppearance.foreground(
          palette: palette, prominence: .secondary, isEnabled: enabled,
          isDestructive: destructive
        )
        for dark in [false, true] {
          // Keep every enabled contrast assertion; subdued disabled colors are a separate role.
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
              #expect(secondaryButtonContrastRatio(ink, blended) >= 4.5)
            }
          }
        }
      }
    }
  }
}

@Test("All secondary variants compose with caller-owned native button semantics")
@MainActor
func secondaryButtonVariantsCompose() {
  for size in [DesignOSSecondaryButtonStyle.Size.regular, .compact] {
    for treatment in [DesignOSSecondaryButtonStyle.Treatment.filled, .outlined] {
      let button = Button(role: .destructive) {} label: {
        Label("Remove this unusually long caller-owned category", systemImage: "trash")
      }
      .buttonStyle(DesignOSSecondaryButtonStyle(size: size, treatment: treatment))
      .disabled(true)
      .environment(\.dynamicTypeSize, .accessibility3)
      #expect(String(reflecting: type(of: button)).contains("ModifiedContent"))
    }
  }
}

private func secondaryButtonContrastRatio(_ first: UInt32, _ second: UInt32) -> Double {
  func luminance(_ rgb: UInt32) -> Double {
    func linear(_ channel: UInt32) -> Double {
      let value = Double(channel) / 255
      return value <= 0.04045 ? value / 12.92 : pow((value + 0.055) / 1.055, 2.4)
    }
    return 0.2126 * linear((rgb >> 16) & 0xFF)
      + 0.7152 * linear((rgb >> 8) & 0xFF)
      + 0.0722 * linear(rgb & 0xFF)
  }
  let firstLuminance = luminance(first)
  let secondLuminance = luminance(second)
  return (max(firstLuminance, secondLuminance) + 0.05)
    / (min(firstLuminance, secondLuminance) + 0.05)
}
