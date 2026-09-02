import SwiftUI

struct VisualAssistantAnswerDemoView: View {
  @Environment(\.accessibilityReduceMotion) private var reduceMotion
  @State private var composerStatus = "Ask a follow-up"
  @State private var followUpDraft = ""
  @State private var notice: VisualAssistantNotice?
  @State private var regenerationCount = 0
  @State private var selectedAction: String?

  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 10) {
        answerToolbar
        introText
        answerSection(
          "1. Grounding with the senses",
          "Notice five things you can see, four you can feel, and three you can hear. The sequence gives a busy mind a concrete place to land."
        )
        answerSection(
          "2. Mind–body movement",
          "A short walk, gentle stretching, or a few slow breaths can reconnect physical sensation with the present moment."
        )
        answerSection(
          "3. Journaling and reflection",
          "Write one sentence about what is demanding attention, then one sentence about what can wait. Keep the ritual small enough to repeat."
        )

        Text(closingQuestion)
          .font(.body)
          .foregroundStyle(VisualAssistantTheme.ink)
          .accessibilityIdentifier("design-os.demo.assistant.visual.closing-question")
        sourceActions
      }
      .frame(maxWidth: 680, alignment: .leading)
      .padding(.horizontal, 16)
      .padding(.top, 8)
      .padding(.bottom, 16)
      .frame(maxWidth: .infinity)
    }
    .background(VisualAssistantTheme.canvas.ignoresSafeArea())
    .safeAreaInset(edge: .bottom, spacing: 0) {
      VisualAssistantAnswerFooter(
        composerStatus: $composerStatus,
        followUpDraft: $followUpDraft)
    }
    .navigationTitle("")
    .localDemoRootIdentifier("design-os.demo.assistant.visual.answer-canvas")
    .alert(item: $notice) { notice in
      Alert(
        title: Text(notice.title),
        message: Text(notice.message),
        dismissButton: .cancel(Text("Done")))
    }
    #if os(iOS)
      .navigationBarTitleDisplayMode(.inline)
    #endif
  }

  private var answerToolbar: some View {
    HStack(spacing: 8) {
      Text("Attention practice")
        .font(.subheadline.weight(.semibold))
        .lineLimit(1)
      Spacer(minLength: 4)
      iconButton("square.and.pencil", label: "New prompt", action: startNewPrompt)
      ShareLink(item: answerText) {
        Image(systemName: "square.and.arrow.up").frame(width: 44, height: 44)
      }
      .buttonStyle(LocalDemoPressButtonStyle())
      .accessibilityLabel("Share answer")
      Menu {
        Button("Explain sources") { notice = .sources }
        Button("Start new prompt", action: startNewPrompt)
      } label: {
        Image(systemName: "ellipsis").frame(width: 44, height: 44)
      }
      .accessibilityLabel("More actions")
    }
  }

  private var introText: some View {
    Text(
      "A useful practice is brief, specific, and easy to return to. These three approaches combine attention, movement, and reflection."
    )
    .font(.subheadline)
    .foregroundStyle(VisualAssistantTheme.ink)
    .fixedSize(horizontal: false, vertical: true)
  }

  private func answerSection(_ title: String, _ body: String) -> some View {
    VStack(alignment: .leading, spacing: 3) {
      Text(title)
        .font(.subheadline.weight(.semibold))
        .foregroundStyle(VisualAssistantTheme.ink)
      Text(body)
        .font(.subheadline)
        .foregroundStyle(VisualAssistantTheme.ink.opacity(0.80))
        .fixedSize(horizontal: false, vertical: true)
    }
  }

  private var sourceActions: some View {
    HStack(spacing: 8) {
      feedbackButton("hand.thumbsup", label: "Helpful")
      feedbackButton("hand.thumbsdown", label: "Not helpful")
      iconButton(
        "arrow.clockwise", label: "Regenerate",
        identifier: "design-os.demo.assistant.visual.regenerate", action: regenerate)
      ShareLink(item: answerText) {
        Image(systemName: "square.and.arrow.up").frame(width: 44, height: 44)
      }
      .buttonStyle(LocalDemoPressButtonStyle())
      .accessibilityLabel("Share")
      iconButton(
        "doc.on.doc", label: "Copy",
        identifier: "design-os.demo.assistant.visual.copy", action: copyAnswer)
      Spacer()
    }
  }

  private func feedbackButton(_ symbol: String, label: String) -> some View {
    Button {
      withAnimation(LocalDemoInteractionMotion.animation(reduceMotion: reduceMotion)) {
        selectedAction = selectedAction == label ? nil : label
      }
    } label: {
      Image(systemName: symbol)
        .frame(width: 44, height: 44)
        .background(
          selectedAction == label ? VisualAssistantTheme.field : .clear,
          in: Circle())
    }
    .buttonStyle(LocalDemoPressButtonStyle())
    .foregroundStyle(VisualAssistantTheme.muted)
    .accessibilityLabel(label)
    .accessibilityValue(selectedAction == label ? "Selected" : "Not selected")
  }

  private func iconButton(
    _ symbol: String, label: String, identifier: String? = nil,
    action: @escaping () -> Void
  )
    -> some View
  {
    Button(action: action) {
      Image(systemName: symbol).frame(width: 44, height: 44)
    }
    .buttonStyle(LocalDemoPressButtonStyle())
    .foregroundStyle(VisualAssistantTheme.muted)
    .accessibilityLabel(label)
    .accessibilityIdentifier(identifier ?? "design-os.demo.assistant.visual.action.\(label)")
  }

  private var closingQuestion: String {
    regenerationCount == 0
      ? "Which practice feels easiest to try for five minutes today?"
      : "Which practice could you repeat tomorrow? Revision \(regenerationCount)."
  }

  private var answerText: String {
    "Attention practice. Ground with the senses, add gentle movement, then reflect in writing."
  }

  private func startNewPrompt() {
    followUpDraft = ""
    composerStatus = "New prompt ready"
  }

  private func regenerate() {
    withAnimation(LocalDemoInteractionMotion.animation(reduceMotion: reduceMotion)) {
      regenerationCount += 1
      composerStatus = "Answer revised"
    }
  }

  private func copyAnswer() {
    LocalDemoPasteboard.copy(answerText)
    notice = .copied
  }
}
