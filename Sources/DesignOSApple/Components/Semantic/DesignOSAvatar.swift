import SwiftUI

/// Circular identity media or caller-owned fallback content; never an image loader or action.
///
/// Supply a resizable image, initials, or an SF Symbol. The caller labels meaningful media or
/// hides a decorative avatar when adjacent text already names the identity. Wrapping controls
/// remain responsible for their native hit region and accessible action label.
public struct DesignOSAvatar<Content: View>: View {
  @Environment(\.designOSAppStyle) private var style
  private let requestedSize: CGFloat?
  private let content: Content

  /// A nil, nonpositive, or non-finite size uses the current style's media-size metric.
  public init(size: CGFloat? = nil, @ViewBuilder content: () -> Content) {
    self.requestedSize = size
    self.content = content()
  }

  public var body: some View {
    let diameter = DesignOSEditorialGeometry.diameter(
      requestedSize, fallback: style.metrics.mediaSize)
    DesignOSEditorialClippedContent(
      size: CGSize(width: diameter, height: diameter),
      shape: Circle(),
      content: content
    )
    .background(style.palette.subtleSurface.color, in: Circle())
    .foregroundStyle(style.palette.ink.color)
  }
}
