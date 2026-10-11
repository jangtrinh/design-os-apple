import SwiftUI

/// A bounded task: introduction, native fields, inline feedback and bottom completion action.
///
/// The app owns sheet presentation, focus, keyboard submit handling, validation and dismiss
/// policy. Supply the same readiness guard to keyboard submission and the real action Button.
/// Disable repeated submission while committing and dismiss only after confirmed success.
public struct DesignOSFocusedTaskScreen<
  Introduction: View, Fields: View, Feedback: View, Action: View
>: View {
  @Environment(\.designOSAppStyle) private var style
  private let introduction: Introduction
  private let fields: Fields
  private let feedback: Feedback
  private let action: Action

  public init(
    @ViewBuilder introduction: () -> Introduction,
    @ViewBuilder fields: () -> Fields,
    @ViewBuilder feedback: () -> Feedback,
    @ViewBuilder action: () -> Action
  ) {
    self.introduction = introduction()
    self.fields = fields()
    self.feedback = feedback()
    self.action = action()
  }

  public var body: some View {
    DesignOSFocusedTaskShell {
      VStack(alignment: .leading, spacing: style.metrics.itemSpacing) {
        introduction
        fields
        feedback
      }
    } action: {
      action
    }
  }
}
