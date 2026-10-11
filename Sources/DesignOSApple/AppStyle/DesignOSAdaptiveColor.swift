import Foundation
import SwiftUI

#if os(iOS)
  import UIKit
#elseif os(macOS)
  import AppKit
#endif

/// Validation failures for an opt-in application style.
public enum DesignOSAppStyleError: String, Error, Equatable, Sendable {
  case invalidColor = "E_APP_STYLE_COLOR"
  case invalidMetric = "E_APP_STYLE_METRIC"
}

/// An opaque sRGB color with explicit appearance and increased-contrast variants.
///
/// Values belong to an opt-in application style, not the sealed semantic token registry.
public struct DesignOSAdaptiveColor: Hashable, Sendable {
  public let lightRGB: UInt32
  public let darkRGB: UInt32
  public let increasedContrastLightRGB: UInt32
  public let increasedContrastDarkRGB: UInt32

  /// Creates an adaptive color from 24-bit RGB values. Alpha is intentionally unsupported.
  public init(
    lightRGB: UInt32,
    darkRGB: UInt32,
    increasedContrastLightRGB: UInt32? = nil,
    increasedContrastDarkRGB: UInt32? = nil
  ) throws {
    let highLight = increasedContrastLightRGB ?? lightRGB
    let highDark = increasedContrastDarkRGB ?? darkRGB
    guard [lightRGB, darkRGB, highLight, highDark].allSatisfy({ $0 <= 0xFF_FFFF }) else {
      throw DesignOSAppStyleError.invalidColor
    }
    self.init(
      uncheckedLightRGB: lightRGB,
      darkRGB: darkRGB,
      increasedContrastLightRGB: highLight,
      increasedContrastDarkRGB: highDark
    )
  }

  internal init(
    uncheckedLightRGB lightRGB: UInt32,
    darkRGB: UInt32,
    increasedContrastLightRGB: UInt32? = nil,
    increasedContrastDarkRGB: UInt32? = nil
  ) {
    self.lightRGB = lightRGB
    self.darkRGB = darkRGB
    self.increasedContrastLightRGB = increasedContrastLightRGB ?? lightRGB
    self.increasedContrastDarkRGB = increasedContrastDarkRGB ?? darkRGB
  }

  /// A platform dynamic color that follows the supplied rendering traits.
  public var color: Color {
    #if os(iOS)
      Color(uiColor: nativeColor)
    #elseif os(macOS)
      Color(nsColor: nativeColor)
    #endif
  }

  #if os(iOS)
    /// The production native provider, exposed internally for platform-resolution tests.
    internal var nativeColor: UIColor {
      UIColor { traits in
        let rgb = self.resolvedRGB(
          dark: traits.userInterfaceStyle == .dark,
          increasedContrast: traits.accessibilityContrast == .high
        )
        return UIColor(
          red: CGFloat((rgb >> 16) & 0xFF) / 255,
          green: CGFloat((rgb >> 8) & 0xFF) / 255,
          blue: CGFloat(rgb & 0xFF) / 255,
          alpha: 1
        )
      }
    }
  #elseif os(macOS)
    /// The production native provider, exposed internally for platform-resolution tests.
    internal var nativeColor: NSColor {
      NSColor(name: nil) { appearance in
        let match = appearance.bestMatch(from: [
          .accessibilityHighContrastDarkAqua, .accessibilityHighContrastAqua,
          .darkAqua, .aqua,
        ])
        let rgb = self.resolvedRGB(
          dark: match == .darkAqua || match == .accessibilityHighContrastDarkAqua,
          increasedContrast: match == .accessibilityHighContrastAqua
            || match == .accessibilityHighContrastDarkAqua
        )
        return NSColor(
          srgbRed: CGFloat((rgb >> 16) & 0xFF) / 255,
          green: CGFloat((rgb >> 8) & 0xFF) / 255,
          blue: CGFloat(rgb & 0xFF) / 255,
          alpha: 1
        )
      }
    }
  #endif

  internal func resolvedRGB(dark: Bool, increasedContrast: Bool) -> UInt32 {
    switch (dark, increasedContrast) {
    case (false, false): lightRGB
    case (true, false): darkRGB
    case (false, true): increasedContrastLightRGB
    case (true, true): increasedContrastDarkRGB
    }
  }
}
