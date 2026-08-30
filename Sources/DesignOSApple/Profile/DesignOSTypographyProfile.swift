/// Closed semantic font designs supported by the runtime profile.
public enum DesignOSFontDesign: String, CaseIterable, Hashable, Sendable {
  case standard
  case expressive
}

/// Immutable typography customization consumed by semantic font projection.
public struct DesignOSTypographyProfile: Hashable, Sendable {
  /// The semantic font design used by Dynamic Type-compatible roles.
  public let fontDesign: DesignOSFontDesign

  /// Creates a typography profile without replacing semantic text styles.
  public init(fontDesign: DesignOSFontDesign) {
    self.fontDesign = fontDesign
  }
}
