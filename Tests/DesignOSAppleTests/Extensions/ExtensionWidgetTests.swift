import DesignOSAppleExtensions
import SwiftUI
import Testing

#if os(iOS)
  import WidgetKit
#endif

@Test("Widget recipe exposes a direct WidgetKit call site")
@available(iOS 17.0, *)
@MainActor
func extensionWidgetRecipeContract() {
  #if os(iOS)
    _ = ExtensionWidgetRecipe.self
    acceptsWidget(ExtensionWidgetFixture())
    acceptsWidgetBundle(ExtensionWidgetBundleFixture())
  #endif
}

#if os(iOS)
  @MainActor
  private func acceptsWidget(_: some Widget) {}

  @MainActor
  private func acceptsWidgetBundle(_: some WidgetBundle) {}

  private struct ExtensionWidgetEntry: TimelineEntry {
    let date: Date
  }

  private struct ExtensionWidgetProvider: TimelineProvider {
    func placeholder(in _: Context) -> ExtensionWidgetEntry {
      ExtensionWidgetEntry(date: Date())
    }

    func getSnapshot(
      in _: Context,
      completion: @escaping @Sendable (ExtensionWidgetEntry) -> Void
    ) {
      completion(ExtensionWidgetEntry(date: Date()))
    }

    func getTimeline(
      in _: Context,
      completion: @escaping @Sendable (Timeline<ExtensionWidgetEntry>) -> Void
    ) {
      let entry = ExtensionWidgetEntry(date: Date())
      completion(Timeline(entries: [entry], policy: .atEnd))
    }
  }

  private struct ExtensionWidgetContent: View {
    let entry: ExtensionWidgetEntry

    var body: some View {
      Text(entry.date, style: .time)
    }
  }

  @available(iOS 17.0, *)
  private struct ExtensionWidgetFixture: Widget {
    var body: some WidgetConfiguration {
      StaticConfiguration(
        kind: "com.example.design-os.widget",
        provider: ExtensionWidgetProvider()
      ) { entry in
        ExtensionWidgetContent(entry: entry)
      }
      .configurationDisplayName("Status")
      .description("Shows current status.")
    }
  }

  @available(iOS 17.0, *)
  private struct ExtensionWidgetBundleFixture: WidgetBundle {
    var body: some Widget {
      ExtensionWidgetFixture()
    }
  }
#endif
