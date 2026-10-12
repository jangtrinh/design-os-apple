import SwiftUI

/// Onboarding artwork, explanation and native choices with a safe-area completion action.
///
/// Authentication and permission prompts remain app/platform-owned. This screen never requests
/// access on appearance; use actual native actions and explain the requested access accurately.
public struct DesignOSOnboardingScreen<
  Artwork: View, Introduction: View, Choices: View, Action: View
>: View {
  @Environment(\.designOSAppStyle) private var style
  private let artwork: Artwork
  private let introduction: Introduction
  private let choices: Choices
  private let action: Action

  public init(
    @ViewBuilder artwork: () -> Artwork,
    @ViewBuilder introduction: () -> Introduction,
    @ViewBuilder choices: () -> Choices,
    @ViewBuilder action: () -> Action
  ) {
    self.artwork = artwork()
    self.introduction = introduction()
    self.choices = choices()
    self.action = action()
  }

  public var body: some View {
    DesignOSFocusedTaskShell {
      VStack(alignment: .leading, spacing: style.metrics.sectionSpacing) {
        artwork
        introduction
        choices
      }
    } action: {
      action
    }
  }
}
