import SwiftUI

/// An opt-in, reusable application design language without product or navigation state.
public struct DesignOSAppStyle: Hashable, Sendable {
  public let profile: DesignOSProfile
  public let palette: DesignOSAppPalette
  public let metrics: DesignOSAppMetrics

  public init(
    profile: DesignOSProfile,
    palette: DesignOSAppPalette,
    metrics: DesignOSAppMetrics
  ) {
    self.profile = profile
    self.palette = palette
    self.metrics = metrics
  }

  /// A monochrome, image-led application style. See `docs/reusable-app-style.md` for provenance.
  ///
  /// The reference's raster colors are observations; point geometry and fallback surfaces
  /// are inferred. This preset makes no pixel-fidelity or third-party affiliation claim.
  public static let editorial = Self(
    profile: .default,
    palette: DesignOSAppPalette(
      canvas: DesignOSAdaptiveColor(uncheckedLightRGB: 0xFF_FFFF, darkRGB: 0x00_0000),
      surface: DesignOSAdaptiveColor(uncheckedLightRGB: 0xF7_F7F7, darkRGB: 0x24_2424),
      subtleSurface: DesignOSAdaptiveColor(uncheckedLightRGB: 0xF0_F0F0, darkRGB: 0x18_1818),
      ink: DesignOSAdaptiveColor(
        uncheckedLightRGB: 0x16_1616,
        darkRGB: 0xFF_FFFF,
        increasedContrastLightRGB: 0x00_0000
      ),
      secondaryInk: DesignOSAdaptiveColor(
        uncheckedLightRGB: 0x66_6666,
        darkRGB: 0xCC_CCCC,
        increasedContrastLightRGB: 0x45_4545,
        increasedContrastDarkRGB: 0xF0_F0F0
      ),
      separator: DesignOSAdaptiveColor(
        uncheckedLightRGB: 0xF0_F0F0,
        darkRGB: 0x25_2525,
        increasedContrastLightRGB: 0x76_7676,
        increasedContrastDarkRGB: 0x80_8080
      ),
      action: DesignOSAdaptiveColor(uncheckedLightRGB: 0x16_1616, darkRGB: 0xFF_FFFF),
      actionInk: DesignOSAdaptiveColor(uncheckedLightRGB: 0xFF_FFFF, darkRGB: 0x16_1616)
    ),
    metrics: DesignOSAppMetrics(
      uncheckedPageInset: 20,
      sectionSpacing: 24,
      contentInset: 16,
      itemSpacing: 12,
      surfaceRadius: 24,
      actionMinHeight: 54,
      mediaSize: 80,
      mediaRadius: 8
    )
  )
}

private struct DesignOSAppStyleKey: EnvironmentKey {
  static let defaultValue = DesignOSAppStyle.editorial
}

extension EnvironmentValues {
  /// The application style consumed only by opt-in content and appearance components.
  public var designOSAppStyle: DesignOSAppStyle {
    get { self[DesignOSAppStyleKey.self] }
    set { self[DesignOSAppStyleKey.self] = newValue }
  }
}

extension View {
  /// Injects a reusable app style and its semantic profile without replacing native controls.
  ///
  /// This modifier does not force appearance, tint native controls, or paint system containers.
  public func designOSAppStyle(_ style: DesignOSAppStyle) -> some View {
    environment(\.designOSAppStyle, style)
      .designOSProfile(style.profile)
  }
}
