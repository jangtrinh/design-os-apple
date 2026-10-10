import SwiftUI

/// Crisp optional hero followed by identity, title, metadata and local native actions.
///
/// Use DesignOSMediaFrame in the hero slot for actual owned media. The identity may be an avatar
/// or EmptyView. This header is non-scrolling and does not choose a backdrop or force appearance.
public struct DesignOSMediaDetailHeader<
  Hero: View, Identity: View, Title: View, Metadata: View, Actions: View
>:
  View
{
  @Environment(\.designOSAppStyle) private var style
  private let hero: Hero
  private let identity: Identity
  private let title: Title
  private let metadata: Metadata
  private let actions: Actions

  public init(
    @ViewBuilder hero: () -> Hero,
    @ViewBuilder identity: () -> Identity,
    @ViewBuilder title: () -> Title,
    @ViewBuilder metadata: () -> Metadata,
    @ViewBuilder actions: () -> Actions
  ) {
    self.hero = hero()
    self.identity = identity()
    self.title = title()
    self.metadata = metadata()
    self.actions = actions()
  }

  public var body: some View {
    VStack(alignment: .leading, spacing: style.metrics.sectionSpacing) {
      hero
      DesignOSIdentityHeader {
        identity
      } title: {
        title
      } metadata: {
        metadata
      } actions: {
        actions
      }
    }
  }
}
