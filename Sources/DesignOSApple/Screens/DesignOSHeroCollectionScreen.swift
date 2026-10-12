import SwiftUI

/// Edge-to-edge hero transitioning into adaptive flat collection content.
///
/// Supply readable hero text/contrast and original media. Rows are non-scrolling content,
/// typically LazyVStack/ForEach. For native row editing or selection, use a List-based screen.
public struct DesignOSHeroCollectionScreen<Hero: View, Introduction: View, Rows: View>: View {
  @Environment(\.designOSAppStyle) private var style
  private let hero: Hero
  private let introduction: Introduction
  private let rows: Rows

  public init(
    @ViewBuilder hero: () -> Hero,
    @ViewBuilder introduction: () -> Introduction,
    @ViewBuilder rows: () -> Rows
  ) {
    self.hero = hero()
    self.introduction = introduction()
    self.rows = rows()
  }

  public var body: some View {
    DesignOSFlatScrollShell(padded: false) {
      VStack(alignment: .leading, spacing: 0) {
        hero
        VStack(alignment: .leading, spacing: style.metrics.sectionSpacing) {
          introduction
          rows
        }
        .padding(style.metrics.pageInset)
        .background(style.palette.canvas.color)
      }
    }
  }
}
