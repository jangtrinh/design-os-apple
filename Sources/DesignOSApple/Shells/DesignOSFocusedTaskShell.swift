import SwiftUI

/// One scrolling task body with a native safe-area bottom action region.
///
/// The bottom action follows native safe-area and keyboard avoidance. Supply a real Button
/// and its readiness/commit state; the shell does not submit, dismiss or mutate inputs.
/// Do not nest vertical scroll containers or ignore the keyboard safe area in its content.
public struct DesignOSFocusedTaskShell<Content: View, Action: View>: View {
  @Environment(\.designOSAppStyle) private var style
  private let content: Content
  private let action: Action

  public init(@ViewBuilder content: () -> Content, @ViewBuilder action: () -> Action) {
    self.content = content()
    self.action = action()
  }

  public var body: some View {
    ScrollView {
      content
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(style.metrics.pageInset)
    }
    .background(style.palette.canvas.color)
    .safeAreaInset(edge: .bottom, spacing: 0) {
      action
        .padding(style.metrics.pageInset)
        .frame(maxWidth: .infinity)
        .background(style.palette.canvas.color)
    }
  }
}
