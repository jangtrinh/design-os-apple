import AppIntents
import DesignOSAppleExtensions
import SwiftUI
import Testing

#if os(iOS)
  import WidgetKit
#endif

@Test("Control Widget recipe exposes a direct WidgetKit and App Intents call site")
@available(iOS 18.0, *)
@MainActor
func extensionControlWidgetRecipeContract() {
  #if os(iOS)
    _ = ExtensionControlWidgetRecipe.self
    acceptsControlWidget(ExtensionControlWidgetFixture())
  #endif
}

#if os(iOS)
  @available(iOS 18.0, *)
  @MainActor
  private func acceptsControlWidget(_: some ControlWidget) {}

  @available(iOS 18.0, *)
  private struct ExtensionControlWidgetFixture: ControlWidget {
    var body: some ControlWidgetConfiguration {
      StaticControlConfiguration(kind: "com.example.design-os.control") {
        ControlWidgetButton(action: RefreshStatusIntent()) {
          Label("Refresh status", systemImage: "arrow.clockwise")
        }
      }
      .displayName("Status")
      .description("Refreshes the current status.")
    }
  }

  @available(iOS 18.0, *)
  private struct RefreshStatusIntent: AppIntent {
    static let title: LocalizedStringResource = "Refresh status"
    static let description = IntentDescription("Refreshes the current status.")

    func perform() async throws -> some IntentResult {
      .result()
    }
  }
#endif
