import SwiftUI

/// An opaque, non-interactive content grouping. Native containers retain their own styling.
public struct DesignOSAppSurface<Content: View>: View {
  public enum Tone: Hashable, Sendable {
    case standard
    case subtle
  }

  @Environment(\.designOSAppStyle) private var style
  private let tone: Tone
  private let content: Content

  public init(tone: Tone = .standard, @ViewBuilder content: () -> Content) {
    self.tone = tone
    self.content = content()
  }

  public var body: some View {
    content
      .padding(style.metrics.contentInset)
      .background(
        tone == .standard ? style.palette.surface.color : style.palette.subtleSurface.color,
        in: RoundedRectangle(cornerRadius: style.metrics.surfaceRadius, style: .continuous)
      )
  }
}
