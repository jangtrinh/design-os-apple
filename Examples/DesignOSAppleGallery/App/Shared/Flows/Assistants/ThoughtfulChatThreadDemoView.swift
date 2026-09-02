import SwiftUI

struct ThoughtfulChatThreadDemoView: View {
  @Environment(\.accessibilityReduceMotion) private var reduceMotion
  @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
  @State private var hasAttachment = false
  @State private var messageDraft = ""
  @State private var reaction: Reaction?

  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 16) {
        Text("Calm Interface Patterns")
          .font(.system(.headline, design: .serif, weight: .semibold))
          .padding(.leading, 52)
        response
        reactionRow
      }
      .font(.body)
      .fontDesign(.serif)
      .frame(maxWidth: 640, alignment: .leading)
      .padding(.horizontal, 16)
      .padding(.top, 8)
      .padding(.bottom, 12)
      .frame(maxWidth: .infinity)
    }
    .background(ThoughtfulChatTheme.paper.ignoresSafeArea())
    .safeAreaInset(edge: .bottom, spacing: 0) { compactComposer }
    .navigationTitle("")
    .localDemoRootIdentifier("design-os.demo.assistant.thoughtful-chat.working-thread")
    #if os(iOS)
      .navigationBarTitleDisplayMode(.inline)
    #endif
  }

  private var response: some View {
    VStack(alignment: .leading, spacing: 10) {
      Text(
        "Calm interfaces begin by making the next action obvious without making every option compete for attention. Strong hierarchy, generous rhythm, and familiar controls let people move with confidence while the system stays quietly supportive."
      )
      Text(
        "Motion works best when it explains a change. A short transition can preserve context as a panel opens or a task advances, while restrained depth helps separate controls from content. The effect should disappear when Reduce Motion or Reduce Transparency is enabled, leaving the information equally clear."
      )
      Text(
        "Spatial design can add useful continuity when it reflects the real structure of the work. A layered canvas may reveal relationships, but ordinary lists and detail views remain better when speed, scanning, and accessibility matter most. New techniques earn their place by reducing effort, not by calling attention to themselves."
      )
      Text(
        "As products grow, consistent language and predictable placement become part of the experience. Reusing clear patterns lowers the cost of learning, creates room for richer content, and helps people understand what will happen before they act. The result feels considered because every detail supports the same intent."
      )
    }
    .foregroundStyle(ThoughtfulChatTheme.ink)
    .fixedSize(horizontal: false, vertical: true)
  }

  private var reactionRow: some View {
    HStack(spacing: 8) {
      reactionButton(.helpful, symbol: "hand.thumbsup", selectedSymbol: "hand.thumbsup.fill")
      reactionButton(
        .notHelpful, symbol: "hand.thumbsdown", selectedSymbol: "hand.thumbsdown.fill")
      Spacer()
    }
  }

  private func reactionButton(_ value: Reaction, symbol: String, selectedSymbol: String)
    -> some View
  {
    Button {
      withAnimation(LocalDemoInteractionMotion.animation(reduceMotion: reduceMotion)) {
        reaction = reaction == value ? nil : value
      }
    } label: {
      Image(systemName: reaction == value ? selectedSymbol : symbol)
        .frame(width: 44, height: 44)
    }
    .buttonStyle(LocalDemoPressButtonStyle())
    .foregroundStyle(reaction == value ? ThoughtfulChatTheme.clay : ThoughtfulChatTheme.subdued)
    .accessibilityLabel(value.label)
    .accessibilityValue(reaction == value ? "Selected" : "Not selected")
  }

  private var compactComposer: some View {
    VStack(spacing: 8) {
      HStack(alignment: .center, spacing: 8) {
        Image(systemName: "sun.max.fill")
          .foregroundStyle(ThoughtfulChatTheme.clay)
          .accessibilityHidden(true)
        Spacer()
        Text("Generated guidance may miss context.\nReview important decisions.")
          .font(.caption)
          .foregroundStyle(ThoughtfulChatTheme.subdued)
          .multilineTextAlignment(.trailing)
      }
      .padding(.horizontal, 16)

      HStack(spacing: 8) {
        Button {
          withAnimation(LocalDemoInteractionMotion.animation(reduceMotion: reduceMotion)) {
            hasAttachment.toggle()
          }
        } label: {
          Image(systemName: hasAttachment ? "paperclip.badge.ellipsis" : "paperclip")
            .contentTransition(.symbolEffect(.replace))
            .font(.body)
            .foregroundStyle(.blue)
            .frame(width: 44, height: 44)
        }
        .buttonStyle(LocalDemoPressButtonStyle())
        .accessibilityLabel(hasAttachment ? "Remove attachment" : "Add attachment")
        .accessibilityValue(hasAttachment ? "Attached" : "None")
        TextField("Message the assistant…", text: $messageDraft)
          .font(.body)
          .foregroundStyle(ThoughtfulChatTheme.subdued)
          .accessibilityLabel("Message the assistant")
        Spacer(minLength: 4)
      }
      .padding(.horizontal, 8)
      .padding(.vertical, 5)
      .background {
        if reduceTransparency {
          ThoughtfulChatTheme.card
        } else {
          Rectangle().fill(.regularMaterial)
        }
      }
      .clipShape(RoundedRectangle(cornerRadius: 22))
      .overlay {
        RoundedRectangle(cornerRadius: 22)
          .stroke(ThoughtfulChatTheme.ink.opacity(0.06), lineWidth: 1)
      }
    }
    .padding(.horizontal, 8)
    .padding(.top, 8)
    .padding(.bottom, 8)
    .background(ThoughtfulChatTheme.paper)
  }
}

extension ThoughtfulChatThreadDemoView {
  fileprivate enum Reaction: Equatable {
    case helpful
    case notHelpful

    var label: String {
      switch self {
      case .helpful: "Helpful"
      case .notHelpful: "Not helpful"
      }
    }
  }
}
