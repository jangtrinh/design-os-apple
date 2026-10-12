import SwiftUI

/// Hosts native/provider-owned content without adding a competing scroll container.
///
/// The hosted TextEditor, picker, provider controller or presentation anchor owns scrolling
/// and interaction. The shell supplies only a full-size adaptive canvas; it makes no claims
/// that permissions, authentication or an external provider integration have been completed.
public struct DesignOSNativeHostShell<Content: View>: View {
  @Environment(\.designOSAppStyle) private var style
  private let content: Content

  public init(@ViewBuilder content: () -> Content) {
    self.content = content()
  }

  public var body: some View {
    content
      .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
      .background(style.palette.canvas.color)
  }
}
