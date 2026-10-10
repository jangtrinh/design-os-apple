import SwiftUI

/// A non-interactive content grouping. Native controls retain their behavior and semantics.
public struct DesignOSAppSurface<Content: View>: View {
  public enum Tone: Hashable, Sendable {
    case standard
    case subtle
    /// A restrained white lift over a dark media backdrop, with opaque accessibility fallbacks.
    case ambient
  }

  @Environment(\.designOSAppStyle) private var style
  @Environment(\.colorScheme) private var colorScheme
  @Environment(\.colorSchemeContrast) private var contrast
  @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
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
        backgroundColor,
        in: RoundedRectangle(cornerRadius: style.metrics.surfaceRadius, style: .continuous)
      )
  }

  private var backgroundColor: Color {
    switch tone {
    case .standard:
      style.palette.surface.color
    case .subtle:
      style.palette.subtleSurface.color
    case .ambient:
      if DesignOSAppSurfacePolicy.usesAmbientFill(
        dark: colorScheme == .dark,
        reduceTransparency: reduceTransparency,
        increasedContrast: contrast == .increased,
        allowsTranslucency: style.profile.accessibility.translucency == .systemAdaptive
      ) {
        Color.white.opacity(DesignOSAppSurfacePolicy.ambientFillOpacity)
      } else {
        style.palette.surface.color
      }
    }
  }
}

internal enum DesignOSAppSurfacePolicy {
  static let ambientFillOpacity = 0.1

  static func usesAmbientFill(
    dark: Bool,
    reduceTransparency: Bool,
    increasedContrast: Bool,
    allowsTranslucency: Bool
  ) -> Bool {
    dark && !reduceTransparency && !increasedContrast && allowsTranslucency
  }
}
