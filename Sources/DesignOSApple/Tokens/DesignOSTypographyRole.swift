/// A semantic typography intent that preserves platform-native scaling.
public struct DesignOSTypographyRole: Hashable, Sendable {
  internal enum Identifier: Hashable, Sendable {
    case largeTitle
    case title
    case title2
    case title3
    case headline
    case subheadline
    case body
    case callout
    case footnote
    case caption
    case caption2
  }

  internal let identifier: Identifier
  internal let isEmphasized: Bool
  internal let isItalic: Bool

  internal init(
    _ identifier: Identifier,
    isEmphasized: Bool = false,
    isItalic: Bool = false
  ) {
    self.identifier = identifier
    self.isEmphasized = isEmphasized
    self.isItalic = isItalic
  }

  /// The large title semantic role.
  public static let largeTitle = Self(.largeTitle)
  /// The title semantic role.
  public static let title = Self(.title)
  /// The second-level title semantic role.
  public static let title2 = Self(.title2)
  /// The third-level title semantic role.
  public static let title3 = Self(.title3)
  /// The headline semantic role.
  public static let headline = Self(.headline)
  /// The subheadline semantic role.
  public static let subheadline = Self(.subheadline)
  /// The body semantic role.
  public static let body = Self(.body)
  /// The callout semantic role.
  public static let callout = Self(.callout)
  /// The footnote semantic role.
  public static let footnote = Self(.footnote)
  /// The caption semantic role.
  public static let caption = Self(.caption)
  /// The second-level caption semantic role.
  public static let caption2 = Self(.caption2)

  /// Returns this role with emphasized semantic intent.
  public func emphasized() -> Self {
    Self(identifier, isEmphasized: true, isItalic: isItalic)
  }

  /// Returns this role with italic semantic intent.
  public func italic() -> Self {
    Self(identifier, isEmphasized: isEmphasized, isItalic: true)
  }
}
