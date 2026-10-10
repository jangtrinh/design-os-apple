import SwiftUI
import Testing

@testable import DesignOSApple

#if os(iOS)
  import UIKit

  @Test("App colors follow supplied UIKit appearance and accessibility traits")
  @MainActor
  func applicationColorsResolveUIKitTraits() throws {
    let adaptive = try DesignOSAdaptiveColor(
      lightRGB: 0x16_1616, darkRGB: 0xCC_CCCC,
      increasedContrastLightRGB: 0x00_0000, increasedContrastDarkRGB: 0xFF_FFFF
    )
    for dark in [false, true] {
      for increased in [false, true] {
        let traits = UITraitCollection(traitsFrom: [
          UITraitCollection(userInterfaceStyle: dark ? .dark : .light),
          UITraitCollection(accessibilityContrast: increased ? .high : .normal),
        ])
        let native = UIColor(adaptive.color).resolvedColor(with: traits)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        #expect(native.getRed(&red, green: &green, blue: &blue, alpha: &alpha))
        let expected = adaptive.resolvedRGB(dark: dark, increasedContrast: increased)
        #expect(abs(red - CGFloat((expected >> 16) & 0xFF) / 255) < 0.001)
        #expect(abs(green - CGFloat((expected >> 8) & 0xFF) / 255) < 0.001)
        #expect(abs(blue - CGFloat(expected & 0xFF) / 255) < 0.001)
        #expect(alpha == 1)
      }
    }
  }
#elseif os(macOS)
  import AppKit

  @Test("App colors follow supplied AppKit appearance and accessibility variants")
  @MainActor
  func applicationColorsResolveAppKitAppearance() throws {
    let adaptive = try DesignOSAdaptiveColor(
      lightRGB: 0x16_1616, darkRGB: 0xCC_CCCC,
      increasedContrastLightRGB: 0x00_0000, increasedContrastDarkRGB: 0xFF_FFFF
    )
    let appearances: [(NSAppearance.Name, Bool, Bool)] = [
      (.aqua, false, false), (.darkAqua, true, false),
      (.accessibilityHighContrastAqua, false, true),
      (.accessibilityHighContrastDarkAqua, true, true),
    ]
    for (name, dark, increased) in appearances {
      let appearance = try #require(NSAppearance(named: name))
      appearance.performAsCurrentDrawingAppearance {
        let native = NSColor(adaptive.color).usingColorSpace(.sRGB)
        let expected = adaptive.resolvedRGB(dark: dark, increasedContrast: increased)
        #expect(native != nil)
        if let native {
          #expect(abs(native.redComponent - CGFloat((expected >> 16) & 0xFF) / 255) < 0.001)
          #expect(abs(native.greenComponent - CGFloat((expected >> 8) & 0xFF) / 255) < 0.001)
          #expect(abs(native.blueComponent - CGFloat(expected & 0xFF) / 255) < 0.001)
          #expect(native.alphaComponent == 1)
        }
      }
    }
  }
#endif
