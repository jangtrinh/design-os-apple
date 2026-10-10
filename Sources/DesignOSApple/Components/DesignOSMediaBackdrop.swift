import SwiftUI

/// A decorative, image-derived backdrop for a dark media presentation.
///
/// Supply owned or licensed media. The backdrop never derives colors from remote content
/// or forces a color scheme. Light appearance, Reduce Transparency, and Increase Contrast
/// use the opaque canvas. No animation is installed, including when Reduce Motion is on.
public struct DesignOSMediaBackdrop<Media: View>: View {
  @Environment(\.designOSAppStyle) private var style
  @Environment(\.colorScheme) private var colorScheme
  @Environment(\.colorSchemeContrast) private var contrast
  @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
  private let media: Media

  public init(@ViewBuilder _ media: () -> Media) {
    self.media = media()
  }

  public var body: some View {
    GeometryReader { geometry in
      ZStack {
        style.palette.canvas.color
        if DesignOSMediaBackdropPolicy.showsMedia(
          dark: colorScheme == .dark,
          reduceTransparency: reduceTransparency,
          increasedContrast: contrast == .increased,
          allowsTranslucency: style.profile.accessibility.translucency == .systemAdaptive
        ) {
          media
            .frame(width: geometry.size.width, height: geometry.size.height)
            .blur(radius: DesignOSMediaBackdropPolicy.blurRadius, opaque: true)
            .opacity(DesignOSMediaBackdropPolicy.imageOpacity)
          style.palette.canvas.color
            .opacity(DesignOSMediaBackdropPolicy.scrimOpacity)
        }
      }
      .frame(width: geometry.size.width, height: geometry.size.height)
      .clipped()
    }
    .ignoresSafeArea()
    .allowsHitTesting(false)
    .accessibilityHidden(true)
  }
}

internal enum DesignOSMediaBackdropPolicy {
  // Optical reconstruction values, not claimed source tokens. The two opacity stages limit
  // a white source pixel to 25% sRGB channel intensity over the editorial black canvas.
  // This also preserves metadata contrast when a 10% white ambient group is overlaid.
  static let blurRadius: CGFloat = 64
  static let imageOpacity = 0.5
  static let scrimOpacity = 0.5

  static func showsMedia(
    dark: Bool,
    reduceTransparency: Bool,
    increasedContrast: Bool,
    allowsTranslucency: Bool = true
  ) -> Bool {
    dark && !reduceTransparency && !increasedContrast && allowsTranslucency
  }
}
