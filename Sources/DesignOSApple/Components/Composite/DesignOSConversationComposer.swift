import SwiftUI

/// Native attachment actions, expanding input and completion controls with persistent feedback.
///
/// Supply a real TextField(axis: .vertical) or another native input with an app-chosen line limit.
/// The same control instances reflow at narrow widths/accessibility sizes. The app owns draft,
/// attachments, focus, submit guards and send completion; failed sends must preserve the draft.
public struct DesignOSConversationComposer<Attachments: View, Input: View, Actions: View, Feedback: View>:
  View
{
  @Environment(\.designOSAppStyle) private var style
  @Environment(\.dynamicTypeSize) private var dynamicTypeSize
  @Environment(\.layoutDirection) private var layoutDirection
  private let attachments: Attachments
  private let input: Input
  private let actions: Actions
  private let feedback: Feedback

  public init(
    @ViewBuilder attachments: () -> Attachments,
    @ViewBuilder input: () -> Input,
    @ViewBuilder actions: () -> Actions,
    @ViewBuilder feedback: () -> Feedback
  ) {
    self.attachments = attachments()
    self.input = input()
    self.actions = actions()
    self.feedback = feedback()
  }

  public var body: some View {
    VStack(alignment: .leading, spacing: style.metrics.itemSpacing) {
      DesignOSEditorialAdaptiveRowLayout(
        spacing: style.metrics.itemSpacing,
        accessibilitySize: dynamicTypeSize.isAccessibilitySize,
        layoutDirection: layoutDirection
      ) {
        VStack(alignment: .leading, spacing: style.metrics.itemSpacing) { attachments }
        VStack(alignment: .leading, spacing: style.metrics.itemSpacing) { input }
          .frame(maxWidth: .infinity, alignment: .leading)
        VStack(alignment: .leading, spacing: style.metrics.itemSpacing) { actions }
      }
      feedback
    }
  }
}
