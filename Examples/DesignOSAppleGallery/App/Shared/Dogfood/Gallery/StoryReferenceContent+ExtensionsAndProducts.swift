import DesignOSAppleCatalog

extension StoryReferenceContent {
  static let extensionAndProductReferenceContent: [Self] = [
    .init(
      storyID: .extensionWidget,
      whatItIs: "Integrates a native WidgetKit timeline and view inside an extension target.",
      useWhen: "Glanceable, relevant app information should appear outside the main app.",
      avoidWhen:
        "The experience requires long interaction, unrestricted networking, or main-app navigation state.",
      placement:
        "Implement in a WidgetKit extension target and share only the model contract needed by the timeline.",
      contract: [
        .init(
          title: "Host",
          detail: "WidgetKit owns rendering cadence, size family, and interaction limits."),
        .init(title: "Fallback", detail: "Omit the extension capability on unsupported platforms."),
      ],
      code: """
        struct StatusWidget: Widget {
          var body: some WidgetConfiguration {
            StaticConfiguration(kind: "status", provider: Provider()) { entry in
              StatusWidgetView(entry: entry)
            }
            .configurationDisplayName("Status")
          }
        }
        """,
      preview: .bounded(.standard)
    ),
    .init(
      storyID: .extensionControlWidget,
      whatItIs:
        "Uses WidgetKit `ControlWidget` for an availability-gated system control owned by an extension host.",
      useWhen: "A fast, stateful app action belongs in supported system control surfaces.",
      avoidWhen:
        "The action needs a multi-step flow, unsupported OS, or foreground-only app state.",
      placement:
        "Declare inside the extension target and gate compilation and product exposure by availability.",
      contract: [
        .init(title: "Host", detail: "WidgetKit owns control presentation and invocation."),
        .init(title: "Availability", detail: "iOS and iPadOS 18 or newer."),
      ],
      code: """
        @available(iOS 18, *)
        struct CaptureControl: ControlWidget {
          var body: some ControlWidgetConfiguration {
            StaticControlConfiguration(kind: "capture") {
              ControlWidgetButton(action: CaptureIntent()) {
                Label("Capture", systemImage: "camera")
              }
            }
          }
        }
        """,
      preview: .bounded(.compact)
    ),
    product(
      .omniactSettingsShell,
      what:
        "App-owned macOS settings composition using native split navigation, form controls, and actions.",
      use: "A desktop app has multiple stable preference categories with independent values.",
      avoid: "A single lightweight preference fits one compact `Settings` form.",
      where: "At the app `Settings` scene; keep selection and persisted values app-owned.",
      patterns: "NavigationSplitView, Form, Toggle, TextField",
      code: """
        Settings {
          NavigationSplitView {
            SettingsSidebar(selection: $section)
          } detail: {
            SettingsForm(section: section)
          }
        }
        """
    ),
    product(
      .omniactCommandRow,
      what:
        "App-owned command row combining reusable list-row anatomy with native controls and status.",
      use:
        "A command catalog needs consistent identity, shortcut, enabled state, and an app action.",
      avoid: "The row is passive information with no command behavior.",
      where:
        "Inside the app's native command `List`; keep execution and persistence outside the row component.",
      patterns: "DesignOSListRow, Button, Toggle, keyboardShortcut",
      code: """
        DesignOSListRow {
          Image(systemName: command.symbol)
        } title: {
          Text(command.title)
        } trailing: {
          Button("Run") { run(command) }
        }
        """
    ),
    product(
      .tocchienDictionarySearch,
      what: "App-owned searchable dictionary flow using native search and local filtered results.",
      use: "A local collection needs immediate text filtering and a clear no-results state.",
      avoid:
        "Search requires remote ranking, pagination, or privacy-sensitive network queries not represented here.",
      where:
        "Attach `.searchable` to the results container and derive visible entries from app-owned query state.",
      patterns: "searchable, List, ContentUnavailableView",
      code: """
        List(filteredEntries) { entry in
          DictionaryRow(entry: entry)
        }
        .searchable(text: $query, prompt: "Tra từ điển")
        .overlay {
          if filteredEntries.isEmpty { ContentUnavailableView.search(text: query) }
        }
        """
    ),
    product(
      .tocchienNavigationTabs,
      what: "App-owned two-destination composition using native `TabView` selection.",
      use: "Two peer destinations must retain native tab semantics and independent content state.",
      avoid: "The destinations form a hierarchy; use `NavigationStack` instead.",
      where: "At the app's primary compact-width navigation boundary.",
      patterns: "TabView, tabItem, selection",
      code: """
        TabView(selection: $selection) {
          DictionaryView().tabItem { Label("Dictionary", systemImage: "book") }.tag(Tab.dictionary)
          FavoritesView().tabItem { Label("Saved", systemImage: "star") }.tag(Tab.saved)
        }
        """
    ),
    product(
      .tocchienChampionHeroNegativeControl,
      what:
        "Synthetic app-owned hero fixture proving that visual similarity does not create a reusable runtime component.",
      use:
        "Testing catalog provenance and the boundary between product artwork and public design-system API.",
      avoid: "Building production hero UI or inferring a component contract from one screenshot.",
      where: "Gallery evidence only; never import this fixture into a product target.",
      patterns: "App-owned fixture; runtime unavailable",
      code: """
        // Gallery-only negative control.
        TocChienChampionHeroNegativeControlStory()
        """
    ),
  ]

  private static func product(
    _ storyID: DesignOSStoryID,
    what: String,
    use: String,
    avoid: String,
    where placement: String,
    patterns: String,
    code: String
  ) -> Self {
    .init(
      storyID: storyID,
      whatItIs: what,
      useWhen: use,
      avoidWhen: avoid,
      placement: placement,
      contract: [
        .init(title: "Boundary", detail: "App-owned example, not public runtime API."),
        .init(title: "Composed patterns", detail: patterns),
      ],
      code: code,
      preview: .destination
    )
  }
}
