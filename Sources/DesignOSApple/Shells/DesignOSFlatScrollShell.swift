import SwiftUI

/// One flat, adaptive vertical canvas for editorial sections and horizontal rails.
///
/// Turn off page padding only for genuinely edge-to-edge heroes; inset following content
/// with the app style's pageInset. Native List/Form behavior belongs to their own shells.
public struct DesignOSFlatScrollShell<Content: View>: View {
  @Environment(\.designOSAppStyle) private var style
  private let padded: Bool
  private let content: Content

  public init(padded: Bool = true, @ViewBuilder content: () -> Content) {
    self.padded = padded
    self.content = content()
  }

  public var body: some View {
    ScrollView {
      content
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(padded ? style.metrics.pageInset : 0)
    }
    .background(style.palette.canvas.color)
  }
}
