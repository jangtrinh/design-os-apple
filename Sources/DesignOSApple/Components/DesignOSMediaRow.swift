import SwiftUI

/// Flat, image-led content that does not own a row's navigation, selection, or gestures.
///
/// Supply resizable media as appropriate. The caller owns media accessibility and labels.
public struct DesignOSMediaRow<Media: View, Content: View>: View {
  @Environment(\.designOSAppStyle) private var style
  @Environment(\.dynamicTypeSize) private var dynamicTypeSize
  private let media: Media
  private let content: Content

  public init(@ViewBuilder _ media: () -> Media, @ViewBuilder content: () -> Content) {
    self.media = media()
    self.content = content()
  }

  public var body: some View {
    let layout =
      DesignOSAppContentLayout.axis(for: dynamicTypeSize) == .vertical
      ? AnyLayout(VStackLayout(alignment: .leading, spacing: style.metrics.itemSpacing))
      : AnyLayout(HStackLayout(alignment: .top, spacing: style.metrics.itemSpacing))
    layout {
      media
        .frame(width: style.metrics.mediaSize, height: style.metrics.mediaSize)
        .clipShape(
          RoundedRectangle(cornerRadius: style.metrics.mediaRadius, style: .continuous)
        )
      content
        .frame(maxWidth: .infinity, alignment: .leading)
        .fixedSize(horizontal: false, vertical: true)
    }
  }
}
