import SwiftUI

struct VisualAssistantHomeDemoView: View {
  @Environment(\.accessibilityReduceMotion) private var reduceMotion
  @State private var hasPhoto = false
  @State private var isListening = false
  @State private var prompt = ""
  @State private var showsProfile = false

  var body: some View {
    VStack(spacing: 0) {
      Spacer(minLength: 32)
      Text("Hello, there")
        .font(.system(.title, design: .rounded, weight: .medium))
        .foregroundStyle(VisualAssistantTheme.spectrum)
        .accessibilityAddTraits(.isHeader)
      Spacer(minLength: 32)
      promptComposer
    }
    .padding(.horizontal, 16)
    .padding(.top, 6)
    .padding(.bottom, 10)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(VisualAssistantTheme.canvas.ignoresSafeArea())
    .navigationTitle("")
    .toolbar {
      ToolbarItem(placement: .primaryAction) {
        Button {
          showsProfile = true
        } label: {
          Text("A")
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(.white)
            .frame(width: 36, height: 36)
            .background(VisualAssistantTheme.blue, in: Circle())
            .frame(minWidth: 44, minHeight: 44)
        }
        .buttonStyle(LocalDemoPressButtonStyle())
        .accessibilityLabel("Profile")
      }
    }
    .localDemoRootIdentifier("design-os.demo.assistant.visual.prompt-home")
    .alert("Visual profile", isPresented: $showsProfile) {
      Button("Done", role: .cancel) {}
    } message: {
      Text("This local profile is ready for reusable visual-assistant demos.")
    }
    #if os(iOS)
      .navigationBarTitleDisplayMode(.inline)
    #endif
  }

  private var promptComposer: some View {
    HStack(spacing: 8) {
      inputPill
      liveAudioTransition
    }
  }

  private var inputPill: some View {
    HStack(spacing: 6) {
      TextField(
        isListening ? "Listening…" : hasPhoto ? "Photo ready" : "Ask anything",
        text: $prompt
      )
      .font(.subheadline)
      .foregroundStyle(VisualAssistantTheme.muted)
      .padding(.leading, 4)
      .accessibilityLabel("Prompt")
      Spacer(minLength: 4)
      inputActions
    }
    .padding(.leading, 10)
    .padding(.trailing, 3)
    .padding(.vertical, 3)
    .frame(minHeight: 56)
    .background(VisualAssistantTheme.canvas, in: Capsule())
    .overlay { Capsule().stroke(VisualAssistantTheme.ink.opacity(0.10), lineWidth: 1) }
    .shadow(color: VisualAssistantTheme.blue.opacity(0.08), radius: 16, y: 4)
    .accessibilityIdentifier("design-os.demo.assistant.visual.input-pill")
  }

  private var inputActions: some View {
    HStack(spacing: 0) {
      Button {
        withAnimation(LocalDemoInteractionMotion.animation(reduceMotion: reduceMotion)) {
          isListening.toggle()
        }
      } label: {
        VisualAssistantCircleControl(
          symbol: isListening ? "stop.fill" : "mic.fill",
          label: isListening ? "Stop listening" : "Use microphone")
      }
      .buttonStyle(LocalDemoPressButtonStyle())
      .accessibilityIdentifier("design-os.demo.assistant.visual.microphone")

      Button {
        withAnimation(LocalDemoInteractionMotion.animation(reduceMotion: reduceMotion)) {
          hasPhoto.toggle()
        }
      } label: {
        VisualAssistantCircleControl(
          symbol: hasPhoto ? "checkmark.circle.fill" : "camera.fill",
          label: hasPhoto ? "Remove photo" : "Add a photo")
      }
      .buttonStyle(LocalDemoPressButtonStyle())
      .accessibilityIdentifier("design-os.demo.assistant.visual.camera")
    }
    .padding(2)
    .background(VisualAssistantTheme.field, in: Capsule())
    .accessibilityIdentifier("design-os.demo.assistant.visual.input-actions")
  }

  private var liveAudioTransition: some View {
    NavigationLink(value: LocalDemoDestination.visualAssistantAnswer) {
      Image(systemName: "waveform")
        .font(.body.weight(.semibold))
        .foregroundStyle(VisualAssistantTheme.violet)
        .frame(width: 48, height: 48)
        .background(VisualAssistantTheme.field, in: Circle())
    }
    .buttonStyle(.plain)
    .localDemoTransitionSource(.visualAssistantAnswer)
    .accessibilityLabel("Open live audio answer")
    .accessibilityIdentifier("design-os.demo.assistant.visual.transition.answer-canvas")
  }
}
