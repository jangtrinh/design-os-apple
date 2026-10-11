import SwiftUI

/// A real map, camera, scanner or media canvas with top overlay and bottom native controls.
///
/// No fake utility view or permission flow is supplied. The canvas owns gestures and any
/// internal scrolling. The overlay does not absorb touches outside its own content, and the
/// bottom controls occupy a native safe-area inset. The app owns presentation and lifecycle.
public struct DesignOSUtilityCanvasShell<Canvas: View, Overlay: View, Controls: View>: View {
  @Environment(\.designOSAppStyle) private var style
  private let canvas: Canvas
  private let overlay: Overlay
  private let controls: Controls

  public init(
    @ViewBuilder canvas: () -> Canvas,
    @ViewBuilder overlay: () -> Overlay,
    @ViewBuilder controls: () -> Controls
  ) {
    self.canvas = canvas()
    self.overlay = overlay()
    self.controls = controls()
  }

  public var body: some View {
    canvas
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .overlay(alignment: .top) { overlay.padding(style.metrics.pageInset) }
      .safeAreaInset(edge: .bottom, spacing: 0) {
        controls.padding(style.metrics.contentInset)
      }
      .background(style.palette.canvas.color)
  }
}
