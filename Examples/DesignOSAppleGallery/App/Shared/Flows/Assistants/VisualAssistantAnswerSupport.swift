import SwiftUI

struct VisualAssistantAnswerFooter: View {
  @Environment(\.accessibilityReduceMotion) private var reduceMotion
  @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
  @Binding var composerStatus: String
  @Binding var followUpDraft: String

  var body: some View {
    VStack(spacing: 8) {
      Text("Generated guidance can miss context. Use your judgment for personal decisions.")
        .font(.caption)
        .foregroundStyle(VisualAssistantTheme.muted)
        .frame(maxWidth: .infinity, alignment: .trailing)
        .padding(.horizontal, 16)
      HStack(spacing: 8) {
        composerButton("plus", label: "Add context", status: "Context attached")
        TextField(composerStatus, text: $followUpDraft)
          .font(.subheadline)
          .foregroundStyle(VisualAssistantTheme.muted)
          .accessibilityLabel("Follow-up prompt")
        Spacer(minLength: 2)
        composerButton("mic.fill", label: "Use microphone", status: "Listening…")
        composerButton(
          "sparkles", label: "Improve prompt", status: "Prompt improved", highlighted: true)
      }
      .padding(.horizontal, 10)
      .padding(.vertical, 4)
      .background(
        reduceTransparency
          ? AnyShapeStyle(VisualAssistantTheme.canvas) : AnyShapeStyle(.regularMaterial)
      )
      .clipShape(RoundedRectangle(cornerRadius: 26))
      .padding(.horizontal, 10)
      .padding(.bottom, 8)
    }
    .background(VisualAssistantTheme.canvas)
  }

  private func composerButton(
    _ symbol: String, label: String, status: String, highlighted: Bool = false
  ) -> some View {
    Button {
      withAnimation(LocalDemoInteractionMotion.animation(reduceMotion: reduceMotion)) {
        composerStatus = composerStatus == status ? "Ask a follow-up" : status
      }
    } label: {
      Image(systemName: symbol)
        .foregroundStyle(highlighted ? VisualAssistantTheme.violet : VisualAssistantTheme.ink)
        .frame(width: 44, height: 44)
        .background(highlighted ? VisualAssistantTheme.field : .clear, in: Circle())
    }
    .buttonStyle(LocalDemoPressButtonStyle())
    .accessibilityLabel(label)
  }
}

enum VisualAssistantNotice: String, Identifiable {
  case copied
  case sources

  var id: String { rawValue }
  var title: String { self == .copied ? "Answer copied" : "About these sources" }
  var message: String {
    self == .copied
      ? "The complete local answer is now on the pasteboard."
      : "This deterministic demo uses local fixtures and does not make a network request."
  }
}
