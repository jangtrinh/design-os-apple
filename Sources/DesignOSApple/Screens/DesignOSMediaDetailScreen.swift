import SwiftUI

/// Optional crisp hero, identity and flowing detail sections over an adaptive canvas.
///
/// Pass an empty hero for plain details and nil media for no backdrop. The hero may use
/// DesignOSMediaFrame; the identity may use DesignOSIdentityHeader. This screen does not
/// invent image descriptions, add row cards, install navigation or force a color scheme.
public struct DesignOSMediaDetailScreen<Hero: View, Identity: View, Content: View>: View {
  @Environment(\.designOSAppStyle) private var style
  private let media: Image?
  private let hero: Hero
  private let identity: Identity
  private let content: Content

  public init(
    media: Image? = nil,
    @ViewBuilder hero: () -> Hero,
    @ViewBuilder identity: () -> Identity,
    @ViewBuilder content: () -> Content
  ) {
    self.media = media
    self.hero = hero()
    self.identity = identity()
    self.content = content()
  }

  public var body: some View {
    DesignOSAmbientScrollShell(media: media) {
      VStack(alignment: .leading, spacing: style.metrics.sectionSpacing) {
        hero
        identity
        content
      }
    }
  }
}

extension DesignOSMediaDetailScreen where Hero == EmptyView {
  public init(@ViewBuilder identity: () -> Identity, @ViewBuilder content: () -> Content) {
    self.init(hero: { EmptyView() }, identity: identity, content: content)
  }
}
