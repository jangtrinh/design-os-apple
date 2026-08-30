/// A construction intent for a future custom, non-interactive surface.
public struct DesignOSSurfaceRole: Hashable, Sendable {
  internal enum Identifier: Hashable, Sendable {
    case content
    case groupedContent
    case translucentContent
  }

  internal let identifier: Identifier

  internal init(_ identifier: Identifier) {
    self.identifier = identifier
  }

  /// An opaque semantic content surface.
  public static let content = Self(.content)
  /// An opaque semantic grouped-content surface.
  public static let groupedContent = Self(.groupedContent)
  /// A semantic translucent-content surface.
  public static let translucentContent = Self(.translucentContent)
}
