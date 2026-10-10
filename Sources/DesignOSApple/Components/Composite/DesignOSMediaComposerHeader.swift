import SwiftUI

/// Editable media, native media-selection actions and the primary identity field as one header.
///
/// Media actions sit below the hero so they do not occlude it or depend on an unlabeled overlay
/// gesture. The app supplies PhotosPicker/Menu/Button, accessible media, bindings and validation.
/// Fields are native controls; this composition owns neither a rounded outer card nor scrolling.
public struct DesignOSMediaComposerHeader<Media: View, MediaActions: View, Field: View, Feedback: View>:
  View
{
  @Environment(\.designOSAppStyle) private var style
  private let media: Media
  private let mediaActions: MediaActions
  private let field: Field
  private let feedback: Feedback

  public init(
    @ViewBuilder media: () -> Media,
    @ViewBuilder mediaActions: () -> MediaActions,
    @ViewBuilder field: () -> Field,
    @ViewBuilder feedback: () -> Feedback
  ) {
    self.media = media()
    self.mediaActions = mediaActions()
    self.field = field()
    self.feedback = feedback()
  }

  public var body: some View {
    VStack(alignment: .leading, spacing: style.metrics.sectionSpacing) {
      VStack(alignment: .leading, spacing: style.metrics.itemSpacing) {
        media
        mediaActions
      }
      VStack(alignment: .leading, spacing: style.metrics.itemSpacing) {
        field
        feedback
      }
    }
  }
}
