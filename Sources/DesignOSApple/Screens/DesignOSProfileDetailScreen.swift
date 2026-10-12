import SwiftUI

/// Optional cover, identity/actions, counts/summary and open profile sections.
///
/// Use EmptyView for missing cover or summary, and nil backdrop media for a plain profile.
/// Domain identity, follow/block actions, selection and private information remain app-owned.
public struct DesignOSProfileDetailScreen<
  Cover: View, Identity: View, Summary: View, Sections: View
>: View {
  @Environment(\.designOSAppStyle) private var style
  private let media: Image?
  private let cover: Cover
  private let identity: Identity
  private let summary: Summary
  private let sections: Sections

  public init(
    media: Image? = nil,
    @ViewBuilder cover: () -> Cover,
    @ViewBuilder identity: () -> Identity,
    @ViewBuilder summary: () -> Summary,
    @ViewBuilder sections: () -> Sections
  ) {
    self.media = media
    self.cover = cover()
    self.identity = identity()
    self.summary = summary()
    self.sections = sections()
  }

  public var body: some View {
    DesignOSAmbientScrollShell(media: media) {
      VStack(alignment: .leading, spacing: style.metrics.sectionSpacing) {
        cover
        identity
        summary
        sections
      }
    }
  }
}
