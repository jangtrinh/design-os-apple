import SwiftUI

/// Long-form confirmation sheet content with explicit consequences and native action slots.
///
/// Prefer confirmationDialog or alert for a short decision. The app presents this content only
/// when explanation or input warrants a sheet, supplies destructive/cancel roles and owns consent.
public struct DesignOSConfirmationScreen<Explanation: View, Details: View, Actions: View>: View {
  @Environment(\.designOSAppStyle) private var style
  private let explanation: Explanation
  private let details: Details
  private let actions: Actions

  public init(
    @ViewBuilder explanation: () -> Explanation,
    @ViewBuilder details: () -> Details,
    @ViewBuilder actions: () -> Actions
  ) {
    self.explanation = explanation()
    self.details = details()
    self.actions = actions()
  }

  public var body: some View {
    DesignOSFocusedTaskShell {
      VStack(alignment: .leading, spacing: style.metrics.sectionSpacing) {
        explanation
        details
      }
    } action: {
      actions
    }
  }
}
