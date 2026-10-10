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
        for (source, color) in [
          ("provider", adaptive.nativeColor), ("public bridge", UIColor(adaptive.color)),
        ] {
          let context = "\(source), dark=\(dark), increased=\(increased)"
          let native = color.resolvedColor(with: traits)
          var red: CGFloat = 0
          var green: CGFloat = 0
          var blue: CGFloat = 0
          var alpha: CGFloat = 0
          #expect(native.getRed(&red, green: &green, blue: &blue, alpha: &alpha), "\(context)")
          let expected = adaptive.resolvedRGB(dark: dark, increasedContrast: increased)
          #expect(abs(red - CGFloat((expected >> 16) & 0xFF) / 255) < 0.001, "red: \(context)")
          #expect(abs(green - CGFloat((expected >> 8) & 0xFF) / 255) < 0.001, "green: \(context)")
          #expect(abs(blue - CGFloat(expected & 0xFF) / 255) < 0.001, "blue: \(context)")
          #expect(alpha == 1, "alpha: \(context)")
        }
      }
    }
  }
#elseif os(macOS)
  import AppKit

  @Test("App color providers preserve all supplied AppKit appearance and contrast variants")
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
      let match = appearance.bestMatch(from: [
        .accessibilityHighContrastDarkAqua, .accessibilityHighContrastAqua,
        .darkAqua, .aqua,
      ])
      let context = "name=\(name.rawValue), dark=\(dark), increased=\(increased), "
        + "bestMatch=\(match?.rawValue ?? "nil")"
      #expect(match == name, "\(context)")
      appearance.performAsCurrentDrawingAppearance {
        let expected = adaptive.resolvedRGB(dark: dark, increasedContrast: increased)
        expectAppKitColor(adaptive.nativeColor, rgb: expected, context: "provider: \(context)")
        if !increased {
          // A Color -> NSColor round trip resolves SwiftUI's system-owned contrast value;
          // an AppKit drawing scope cannot override that read-only SwiftUI environment.
          // Test all four exact variants at the production provider seam above, and retain
          // public bridge coverage where drawing and SwiftUI environments agree.
          expectAppKitColor(
            NSColor(adaptive.color), rgb: expected, context: "public bridge: \(context)"
          )
        }
      }
    }
  }

  @MainActor
  private func expectAppKitColor(_ color: NSColor, rgb: UInt32, context: String) {
    let native = color.usingColorSpace(.sRGB)
    #expect(native != nil, "\(context)")
    if let native {
      #expect(
        abs(native.redComponent - CGFloat((rgb >> 16) & 0xFF) / 255) < 0.001,
        "red: \(context)"
      )
      #expect(
        abs(native.greenComponent - CGFloat((rgb >> 8) & 0xFF) / 255) < 0.001,
        "green: \(context)"
      )
      #expect(
        abs(native.blueComponent - CGFloat(rgb & 0xFF) / 255) < 0.001,
        "blue: \(context)"
      )
      #expect(native.alphaComponent == 1, "alpha: \(context)")
    }
  }
#endif
