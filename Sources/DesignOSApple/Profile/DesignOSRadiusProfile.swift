import CoreGraphics

/// Immutable radius customization for package-owned non-interactive surfaces.
public struct DesignOSRadiusProfile: Hashable, Sendable {
  /// The corner radius used by custom non-interactive composition.
  public let customContent: CGFloat

  /// Creates a validated, finite, nonnegative custom-content radius.
  public init(customContent: CGFloat) throws {
    guard customContent.isFinite, customContent >= 0 else {
      throw DesignOSProfileError.invalid
    }
    self.customContent = customContent
  }

  internal init(uncheckedCustomContent customContent: CGFloat) {
    self.customContent = customContent
  }
}
