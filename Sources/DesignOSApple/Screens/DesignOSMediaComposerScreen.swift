import SwiftUI

/// Media-led editing with a hero, semantic field groups and persistent feedback slots.
///
/// Supply actual controls, usually grouped by DesignOSFieldGroup. Use a native toolbar for
/// Cancel/Save at the app boundary. Bindings, media picking, validation and commit state stay
/// in the app; failed saves must preserve inputs and remain visible in feedback.
public struct DesignOSMediaComposerScreen<Hero: View, Fields: View, Feedback: View>: View {
  @Environment(\.designOSAppStyle) private var style
  private let media: Image?
  private let hero: Hero
  private let fields: Fields
  private let feedback: Feedback

  public init(
    media: Image? = nil,
    @ViewBuilder hero: () -> Hero,
    @ViewBuilder fields: () -> Fields,
    @ViewBuilder feedback: () -> Feedback
  ) {
    self.media = media
    self.hero = hero()
    self.fields = fields()
    self.feedback = feedback()
  }

  public var body: some View {
    DesignOSAmbientScrollShell(media: media) {
      VStack(alignment: .leading, spacing: style.metrics.sectionSpacing) {
        hero
        fields
        feedback
      }
    }
  }
}

extension DesignOSMediaComposerScreen where Hero == EmptyView, Feedback == EmptyView {
  public init(@ViewBuilder fields: () -> Fields) {
    self.init(hero: { EmptyView() }, fields: fields, feedback: { EmptyView() })
  }
}
