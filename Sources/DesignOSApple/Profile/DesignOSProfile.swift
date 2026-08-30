import CoreGraphics

/// Stable runtime validation failures for an environment profile.
public enum DesignOSProfileError: String, Error, Equatable, Sendable {
  case invalid = "E_PROFILE_INVALID"
}

/// Immutable, validated design-language groups injected into a runtime subtree.
public struct DesignOSProfile: Hashable, Sendable {
  /// Semantic typography customization.
  public let typography: DesignOSTypographyProfile
  /// Package-owned content spacing relationships.
  public let spacing: DesignOSSpacingProfile
  /// Package-owned non-interactive content radii.
  public let radius: DesignOSRadiusProfile
  /// Adaptive semantic color intent.
  public let semanticColors: DesignOSSemanticColorProfile
  /// Package-owned non-interactive surface intent.
  public let surface: DesignOSSurfaceProfile
  /// Fail-closed policy applied after system accessibility preferences.
  public let accessibility: DesignOSAccessibilityPolicy

  /// Creates a profile from independently validated typed groups.
  public init(
    typography: DesignOSTypographyProfile,
    spacing: DesignOSSpacingProfile,
    radius: DesignOSRadiusProfile,
    semanticColors: DesignOSSemanticColorProfile,
    surface: DesignOSSurfaceProfile,
    accessibility: DesignOSAccessibilityPolicy
  ) {
    self.typography = typography
    self.spacing = spacing
    self.radius = radius
    self.semanticColors = semanticColors
    self.surface = surface
    self.accessibility = accessibility
  }

  /// Creates a profile through the pre-release scalar compatibility bridge.
  public init(
    fontDesign: DesignOSFontDesign,
    titleSubtitleSpacing: CGFloat,
    sidebarContentSpacing: CGFloat,
    listRowContentSpacing: CGFloat,
    customContentCornerRadius: CGFloat = 12,
    surfaceRole: DesignOSSurfaceRole = .content
  ) throws {
    self.init(
      typography: DesignOSTypographyProfile(fontDesign: fontDesign),
      spacing: try DesignOSSpacingProfile(
        titleSubtitle: titleSubtitleSpacing,
        sidebarContent: sidebarContentSpacing,
        listRowContent: listRowContentSpacing
      ),
      radius: try DesignOSRadiusProfile(customContent: customContentCornerRadius),
      semanticColors: DesignOSSemanticColorProfile(secondaryContent: .labelSecondary),
      surface: DesignOSSurfaceProfile(role: surfaceRole),
      accessibility: .systemAdaptive
    )
  }

  /// Creates a profile from a semantic font-design identifier.
  public init(
    fontDesignID: String,
    titleSubtitleSpacing: CGFloat,
    sidebarContentSpacing: CGFloat,
    listRowContentSpacing: CGFloat,
    customContentCornerRadius: CGFloat = 12,
    surfaceRole: DesignOSSurfaceRole = .content
  ) throws {
    guard let fontDesign = DesignOSFontDesign(rawValue: fontDesignID) else {
      throw DesignOSProfileError.invalid
    }
    try self.init(
      fontDesign: fontDesign,
      titleSubtitleSpacing: titleSubtitleSpacing,
      sidebarContentSpacing: sidebarContentSpacing,
      listRowContentSpacing: listRowContentSpacing,
      customContentCornerRadius: customContentCornerRadius,
      surfaceRole: surfaceRole
    )
  }

  /// Preserves the existing runtime values and native platform behavior.
  public static let `default` = Self(
    typography: DesignOSTypographyProfile(fontDesign: .standard),
    spacing: DesignOSSpacingProfile(
      uncheckedTitleSubtitle: 2,
      sidebarContent: 8,
      listRowContent: 12
    ),
    radius: DesignOSRadiusProfile(uncheckedCustomContent: 12),
    semanticColors: DesignOSSemanticColorProfile(secondaryContent: .labelSecondary),
    surface: DesignOSSurfaceProfile(role: .content),
    accessibility: .systemAdaptive
  )
}

extension DesignOSProfile {
  /// Compatibility projection for the semantic font design.
  public var fontDesign: DesignOSFontDesign { typography.fontDesign }
  /// Compatibility projection for title-to-subtitle spacing.
  public var titleSubtitleSpacing: CGFloat { spacing.titleSubtitle }
  /// Compatibility projection for sidebar content spacing.
  public var sidebarContentSpacing: CGFloat { spacing.sidebarContent }
  /// Compatibility projection for list-row content spacing.
  public var listRowContentSpacing: CGFloat { spacing.listRowContent }
  /// Compatibility projection for custom-content radius.
  public var customContentCornerRadius: CGFloat { radius.customContent }
  /// Compatibility projection for custom surface intent.
  public var surfaceRole: DesignOSSurfaceRole { surface.role }
}
