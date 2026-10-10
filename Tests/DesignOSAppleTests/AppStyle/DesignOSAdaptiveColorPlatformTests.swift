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

  @Test("App color providers and public bridge preserve native standard appearances")
  @MainActor
  func applicationColorsResolveAppKitAppearance() throws {
    try expectAppKitVariant(.aqua, dark: false, increased: false)
    try expectAppKitVariant(.darkAqua, dark: true, increased: false)
  }

  @Test(
    "App color providers preserve genuine native high-contrast appearances",
    .enabled(
      "NOT VERIFIED: high-contrast appearance fixtures require the system accessibility setting"
    ) {
      await MainActor.run {
        appKitCanConstructAppearances([
          .accessibilityHighContrastAqua, .accessibilityHighContrastDarkAqua,
        ])
      }
    }
  )
  @MainActor
  func applicationColorsResolveAppKitHighContrastAppearance() throws {
    try expectAppKitVariant(.accessibilityHighContrastAqua, dark: false, increased: true)
    try expectAppKitVariant(.accessibilityHighContrastDarkAqua, dark: true, increased: true)
  }

  @MainActor
  private func appKitCanConstructAppearances(_ names: [NSAppearance.Name]) -> Bool {
    // Construct a real app context, but never change the user's accessibility preferences.
    _ = NSApplication.shared
    return names.allSatisfy { name in
      guard let appearance = NSAppearance(named: name) else { return false }
      let match = appearance.bestMatch(from: appKitAppearanceNames)
      let available = appearance.name == name && match == name
      if !available {
        print(
          "AppKit appearance fixture unavailable: requested=\(name.rawValue), "
            + "actual=\(appearance.name.rawValue), bestMatch=\(match?.rawValue ?? "nil")"
        )
      }
      return available
    }
  }

  private let appKitAppearanceNames: [NSAppearance.Name] = [
    .accessibilityHighContrastDarkAqua, .accessibilityHighContrastAqua,
    .darkAqua, .aqua,
  ]

  @MainActor
  private func expectAppKitVariant(
    _ name: NSAppearance.Name,
    dark: Bool,
    increased: Bool
  ) throws {
    let adaptive = try DesignOSAdaptiveColor(
      lightRGB: 0x16_1616, darkRGB: 0xCC_CCCC,
      increasedContrastLightRGB: 0x00_0000, increasedContrastDarkRGB: 0xFF_FFFF
    )
    let appearance = try #require(NSAppearance(named: name))
    let match = appearance.bestMatch(from: appKitAppearanceNames)
    let context =
      "requested=\(name.rawValue), actual=\(appearance.name.rawValue), "
      + "dark=\(dark), increased=\(increased), bestMatch=\(match?.rawValue ?? "nil")"
    #expect(appearance.name == name, "\(context)")
    #expect(match == name, "\(context)")
    appearance.performAsCurrentDrawingAppearance {
      let expected = adaptive.resolvedRGB(dark: dark, increasedContrast: increased)
      expectAppKitColor(adaptive.nativeColor, rgb: expected, context: "provider: \(context)")
      if !increased {
        // Standard public bridge coverage. High-contrast SwiftUI rendering additionally
        // requires the real system accessibility setting and a native rendering check.
        expectAppKitColor(
          NSColor(adaptive.color), rgb: expected, context: "public bridge: \(context)"
        )
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
