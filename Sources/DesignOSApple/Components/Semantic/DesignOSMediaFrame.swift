import SwiftUI

/// A continuous-corner media frame that takes its size from the native container proposal.
///
/// Supply a resizable image with the desired fit/fill treatment, or an accessible placeholder.
/// The caller owns loading, errors and media accessibility. No gesture or network operation is
/// installed. A nil corner radius uses the current app-style surface radius; a genuinely inset
/// image can pass a radius derived with `DesignOSCornerGeometry.innerRadius`.
public struct DesignOSMediaFrame<Media: View>: View {
  @Environment(\.designOSAppStyle) private var style
  private let aspectRatio: CGFloat
  private let cornerRadius: CGFloat?
  private let media: Media

  /// Invalid aspect ratios use a square; invalid explicit radii fail closed to zero.
  public init(
    aspectRatio: CGFloat = 1,
    cornerRadius: CGFloat? = nil,
    @ViewBuilder content: () -> Media
  ) {
    self.aspectRatio = DesignOSEditorialGeometry.aspectRatio(aspectRatio)
    self.cornerRadius = cornerRadius
    self.media = content()
  }

  public var body: some View {
    Color.clear
      .aspectRatio(aspectRatio, contentMode: .fit)
      .overlay {
        GeometryReader { geometry in
          DesignOSEditorialClippedContent(
            size: geometry.size,
            shape: RoundedRectangle(
              cornerRadius: DesignOSEditorialGeometry.cornerRadius(
                cornerRadius ?? style.metrics.surfaceRadius, in: geometry.size
              ),
              style: .continuous
            ),
            content: media
          )
        }
      }
  }
}
