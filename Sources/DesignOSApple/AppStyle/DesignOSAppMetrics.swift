import CoreGraphics

/// Content geometry for an application style, separate from native control geometry.
public struct DesignOSAppMetrics: Hashable, Sendable {
  public let pageInset: CGFloat
  public let sectionSpacing: CGFloat
  public let contentInset: CGFloat
  public let itemSpacing: CGFloat
  public let surfaceRadius: CGFloat
  public let actionMinHeight: CGFloat
  public let mediaSize: CGFloat
  public let mediaRadius: CGFloat
  /// Legacy reference geometry retained for source compatibility; pill button styles ignore it.
  public let actionRadius: CGFloat

  /// Creates finite nonnegative metrics. Opt-in primary actions retain a 44-point minimum.
  public init(
    pageInset: CGFloat,
    sectionSpacing: CGFloat,
    contentInset: CGFloat,
    itemSpacing: CGFloat,
    surfaceRadius: CGFloat,
    actionMinHeight: CGFloat,
    mediaSize: CGFloat,
    mediaRadius: CGFloat,
    actionRadius: CGFloat = 12
  ) throws {
    let values = [
      pageInset, sectionSpacing, contentInset, itemSpacing, surfaceRadius,
      actionMinHeight, mediaSize, mediaRadius, actionRadius,
    ]
    guard values.allSatisfy({ $0.isFinite && $0 >= 0 }), actionMinHeight >= 44,
      mediaSize > 0, mediaRadius <= mediaSize / 2
    else { throw DesignOSAppStyleError.invalidMetric }
    self.init(
      uncheckedPageInset: pageInset,
      sectionSpacing: sectionSpacing,
      contentInset: contentInset,
      itemSpacing: itemSpacing,
      surfaceRadius: surfaceRadius,
      actionMinHeight: actionMinHeight,
      mediaSize: mediaSize,
      mediaRadius: mediaRadius,
      actionRadius: actionRadius
    )
  }

  internal init(
    uncheckedPageInset pageInset: CGFloat,
    sectionSpacing: CGFloat,
    contentInset: CGFloat,
    itemSpacing: CGFloat,
    surfaceRadius: CGFloat,
    actionMinHeight: CGFloat,
    mediaSize: CGFloat,
    mediaRadius: CGFloat,
    actionRadius: CGFloat = 12
  ) {
    self.pageInset = pageInset
    self.sectionSpacing = sectionSpacing
    self.contentInset = contentInset
    self.itemSpacing = itemSpacing
    self.surfaceRadius = surfaceRadius
    self.actionMinHeight = actionMinHeight
    self.mediaSize = mediaSize
    self.mediaRadius = mediaRadius
    self.actionRadius = actionRadius
  }
}
