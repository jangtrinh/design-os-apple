import SwiftUI

struct ThoughtfulChatHomeDemoView: View {
  @Environment(\.accessibilityReduceMotion) private var reduceMotion
  @Environment(\.dynamicTypeSize) private var dynamicTypeSize
  @State private var hasContext = false
  @State private var isRecording = false
  @State private var draft = ""
  @State private var modelMode = "Balanced"
  @State private var notice: ThoughtfulChatNotice?

  var body: some View {
    VStack(spacing: 0) {
      Spacer(minLength: 28)
      greeting
      Spacer(minLength: 28)
      composer
    }
    .padding(.horizontal, 16)
    .padding(.top, 8)
    .padding(.bottom, 12)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(ThoughtfulChatTheme.paper.ignoresSafeArea())
    .navigationTitle("")
    .toolbar {
      ToolbarItem(placement: .primaryAction) {
        Button {
          notice = .profile
        } label: {
          ThoughtfulChatCircleControl(symbol: "person.crop.circle", label: "Assistant profile")
        }
        .buttonStyle(LocalDemoPressButtonStyle())
      }
    }
    .localDemoRootIdentifier("design-os.demo.assistant.thoughtful-chat.new-conversation")
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

  private var greeting: some View {
    VStack(spacing: 18) {
      Image(systemName: "sun.max.fill")
        .font(.system(.title, design: .serif, weight: .regular))
        .symbolRenderingMode(.hierarchical)
        .foregroundStyle(ThoughtfulChatTheme.clay)
        .accessibilityHidden(true)
      Text("Welcome back")
        .font(.title3.weight(.regular))
        .fontDesign(.serif)
        .foregroundStyle(ThoughtfulChatTheme.ink)
        .multilineTextAlignment(.center)
    }
    .offset(y: -34)
    .accessibilityElement(children: .combine)
  }

  private var composer: some View {
    VStack(alignment: .leading, spacing: 12) {
      promoPill
      TextField("Start a thoughtful conversation", text: $draft)
        .font(.body)
        .foregroundStyle(ThoughtfulChatTheme.subdued)
        .frame(minHeight: 44)
        .accessibilityLabel("Message")

      HStack(spacing: 10) { composerActions }
    }
    .padding(12)
    .background(ThoughtfulChatTheme.card, in: RoundedRectangle(cornerRadius: 22))
    .overlay {
      RoundedRectangle(cornerRadius: 22)
        .stroke(ThoughtfulChatTheme.outline, lineWidth: 1)
    }
    .shadow(color: .black.opacity(0.08), radius: 18, y: 6)
  }

  private var promoPill: some View {
    HStack(spacing: 8) {
      Image(systemName: "sparkles")
        .foregroundStyle(ThoughtfulChatTheme.clay)
      Text("Get more room for longer ideas")
        .font(.caption.weight(.medium))
      Spacer()
      Button {
        notice = .upgrade
      } label: {
        Text("Upgrade")
          .font(.caption.weight(.semibold))
          .padding(.horizontal, 10)
          .frame(minHeight: 28)
          .background(ThoughtfulChatTheme.secondaryControlFill, in: Capsule())
          .frame(minHeight: 44)
      }
      .buttonStyle(.plain)
      .buttonStyle(LocalDemoPressButtonStyle())
      .accessibilityIdentifier("design-os.demo.assistant.thoughtful-chat.upgrade")
    }
    .foregroundStyle(ThoughtfulChatTheme.subdued)
    .padding(.horizontal, 10)
    .frame(minHeight: 36)
    .background(ThoughtfulChatTheme.paper, in: Capsule())
    .accessibilityIdentifier("design-os.demo.assistant.thoughtful-chat.promo-pill")
  }

  @ViewBuilder private var composerActions: some View {
    Button {
      withAnimation(LocalDemoInteractionMotion.animation(reduceMotion: reduceMotion)) {
        hasContext.toggle()
      }
    } label: {
      Image(systemName: hasContext ? "paperclip" : "plus")
        .contentTransition(.symbolEffect(.replace))
        .frame(width: 44, height: 44)
        .background(ThoughtfulChatTheme.secondaryControlFill, in: Circle())
    }
    .buttonStyle(LocalDemoPressButtonStyle())
    .accessibilityLabel("Add context")
    .accessibilityIdentifier("design-os.demo.assistant.thoughtful-chat.add-context")

    if !dynamicTypeSize.isAccessibilitySize {
      Button {
        withAnimation(LocalDemoInteractionMotion.animation(reduceMotion: reduceMotion)) {
          modelMode = modelMode == "Balanced" ? "Concise" : "Balanced"
        }
      } label: {
        HStack(spacing: 5) {
          Text(modelMode)
          Image(systemName: "chevron.down").font(.caption.bold())
        }
        .font(.caption.weight(.medium))
        .foregroundStyle(ThoughtfulChatTheme.subdued)
        .padding(.horizontal, 12)
        .frame(minHeight: 36)
        .background(ThoughtfulChatTheme.secondaryControlFill, in: Capsule())
        .frame(minHeight: 44)
      }
      .buttonStyle(LocalDemoPressButtonStyle())
      .accessibilityLabel("Choose model")
      .accessibilityIdentifier("design-os.demo.assistant.thoughtful-chat.model-selector")
    }

    Spacer(minLength: 0)

    Button {
      withAnimation(LocalDemoInteractionMotion.animation(reduceMotion: reduceMotion)) {
        isRecording.toggle()
      }
    } label: {
      Image(systemName: isRecording ? "stop.fill" : "mic.fill")
        .contentTransition(.symbolEffect(.replace))
        .frame(width: 44, height: 44)
        .background(ThoughtfulChatTheme.secondaryControlFill, in: Circle())
    }
    .buttonStyle(LocalDemoPressButtonStyle())
    .accessibilityLabel("Use microphone")
    .accessibilityIdentifier("design-os.demo.assistant.thoughtful-chat.microphone")

    NavigationLink(value: LocalDemoDestination.thoughtfulChatThread) {
      Image(systemName: "waveform")
        .font(.body.weight(.semibold))
        .foregroundStyle(ThoughtfulChatTheme.primaryControlInk)
        .frame(width: 44, height: 44)
        .background(ThoughtfulChatTheme.primaryControlFill, in: Circle())
    }
    .buttonStyle(.plain)
    .localDemoTransitionSource(.thoughtfulChatThread)
    .accessibilityLabel("Open sample conversation")
    .accessibilityIdentifier("design-os.demo.assistant.thoughtful-chat.transition.working-thread")
  }
}

private enum ThoughtfulChatNotice: String, Identifiable {
  case profile, upgrade

  var id: String { rawValue }
  var title: String { self == .profile ? "Assistant profile" : "Thoughtful Pro" }
  var message: String {
    self == .profile
      ? "Your local profile keeps this demo private and reusable."
      : "Longer conversations and expanded context are available in this reusable demo state."
  }
}
