import CoreGraphics

/// Immutable spacing relationships consumed by package-owned row composition.
public struct DesignOSSpacingProfile: Hashable, Sendable {
  /// The title-to-subtitle relationship inside custom row content.
  public let titleSubtitle: CGFloat
  /// The label-to-accessory relationship inside sidebar content.
  public let sidebarContent: CGFloat
  /// The leading-to-content relationship inside list-row content.
  public let listRowContent: CGFloat

  /// Creates validated, finite, nonnegative spacing relationships.
  public init(
    titleSubtitle: CGFloat,
    sidebarContent: CGFloat,
    listRowContent: CGFloat
  ) throws {
    guard Self.isValid(titleSubtitle), Self.isValid(sidebarContent),
      Self.isValid(listRowContent)
    else { throw DesignOSProfileError.invalid }
    self.titleSubtitle = titleSubtitle
    self.sidebarContent = sidebarContent
    self.listRowContent = listRowContent
  }

  internal init(
    uncheckedTitleSubtitle titleSubtitle: CGFloat,
    sidebarContent: CGFloat,
    listRowContent: CGFloat
  ) {
    self.titleSubtitle = titleSubtitle
    self.sidebarContent = sidebarContent
    self.listRowContent = listRowContent
  }

  private static func isValid(_ value: CGFloat) -> Bool { value.isFinite && value >= 0 }
}
