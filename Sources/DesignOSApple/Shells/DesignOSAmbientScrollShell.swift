import SwiftUI

/// One vertical ScrollView over an optional image-derived, accessibility-adaptive backdrop.
///
/// Supply owned or licensed media; nil intentionally uses the adaptive canvas. The shell
/// never forces appearance. Content owns its internal grouping; the shell owns page padding.
/// Do not pass another vertical scroll container. Apply navigation and toolbar modifiers outside.
public struct DesignOSAmbientScrollShell<Content: View>: View {
  @Environment(\.designOSAppStyle) private var style
  private let media: Image?
  private let content: Content

  public init(media: Image? = nil, @ViewBuilder content: () -> Content) {
    self.media = media
    self.content = content()
  }

  public var body: some View {
    ScrollView {
      content
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(style.metrics.pageInset)
    }
    .background {
      if let media {
        DesignOSMediaBackdrop { media.resizable().scaledToFill() }
      } else {
        style.palette.canvas.color
      }
    }
  }
}
