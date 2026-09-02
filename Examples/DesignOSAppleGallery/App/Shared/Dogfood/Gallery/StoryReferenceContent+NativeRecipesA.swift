import DesignOSAppleCatalog

extension StoryReferenceContent {
  static let nativeReferenceContentA: [Self] = [
    native(
      .buttonAndToolbarActions,
      what: "Uses SwiftUI `Button`, roles, and toolbar placement directly for app actions.",
      use: "An action belongs in content, navigation chrome, or a platform toolbar.",
      avoid:
        "The interaction is selection or navigation; use the native control that owns that behavior.",
      where: "Put primary content actions near their object and global actions in `.toolbar`.",
      api: "Button / ToolbarItem",
      code: """
        Button("Delete", systemImage: "trash", role: .destructive) {
          deleteItem()
        }
        .toolbar {
          ToolbarItem { Button("Add", systemImage: "plus", action: addItem) }
        }
        """,
      preview: .intrinsic
    ),
    native(
      .contentUnavailable,
      what:
        "Uses SwiftUI `ContentUnavailableView` directly for an empty collection or no-results state.",
      use: "The content region has no items, or a search/filter returns no results.",
      avoid:
        "Content is loading, populated, or merely decorative; use progress or the real content instead.",
      where: "Replace the content container that would otherwise render the empty results.",
      api: "ContentUnavailableView",
      code: """
        ContentUnavailableView(
          "No saved items",
          systemImage: "bookmark",
          description: Text("Save an item to find it here.")
        )
        """,
      preview: .bounded(.compact)
    ),
    native(
      .elevatedBackground,
      what:
        "Uses platform semantic backgrounds to distinguish elevated content without freezing a literal color.",
      use:
        "A custom panel sits above the base canvas and native containers do not already provide separation.",
      avoid: "A sheet, list, form, popover, or material already owns the elevation treatment.",
      where: "Apply to the outer custom panel and verify it in its real window or scene.",
      api: "Color(uiColor:) / Color(nsColor:)",
      code: """
        content
          .padding()
          .background(.background, in: .rect(cornerRadius: 16))
        """,
      preview: .intrinsic
    ),
    native(
      .hierarchicalStyle,
      what: "Uses SwiftUI hierarchical foreground styles to express emphasis without fixed colors.",
      use: "Primary, secondary, tertiary, or quaternary content needs platform-adaptive hierarchy.",
      avoid: "Color communicates a semantic status such as destructive, warning, or success.",
      where: "Apply `.foregroundStyle` to the smallest text or symbol group sharing the hierarchy.",
      api: "HierarchicalShapeStyle",
      code: """
        VStack(alignment: .leading) {
          Text("Account").foregroundStyle(.primary)
          Text("Updated today").foregroundStyle(.secondary)
        }
        """,
      preview: .intrinsic
    ),
    native(
      .homeScreenQuickActions,
      what:
        "Publishes native Home Screen shortcuts through `UIApplicationShortcutItem`; no SwiftUI control is redrawn.",
      use: "A frequent app action should be available before the user opens the main scene.",
      avoid: "The action requires unavailable state, confirmation, or a long decision flow.",
      where:
        "Configure at the iOS application or scene boundary and route its identifier into app navigation.",
      api: "UIApplicationShortcutItem",
      code: """
        UIApplication.shared.shortcutItems = [
          UIApplicationShortcutItem(
            type: "new-note",
            localizedTitle: "New Note",
            localizedSubtitle: nil,
            icon: .init(systemImageName: "square.and.pencil")
          )
        ]
        """,
      preview: .intrinsic
    ),
    native(
      .listSidebarAndDisclosure,
      what:
        "Combines native `List`, `NavigationSplitView`, and disclosure containers for adaptive information hierarchy.",
      use:
        "Content has selectable collections or expandable groups that must adapt between compact and regular width.",
      avoid: "A small linear flow only needs `NavigationStack`.",
      where: "Own selection at the app level and let the split view adapt its columns.",
      api: "List / NavigationSplitView / DisclosureGroup",
      code: """
        NavigationSplitView {
          List(items, selection: $selection) { item in
            NavigationLink(item.title, value: item.id)
          }
        } detail: {
          DetailView(selection: selection)
        }
        """,
      preview: .destination
    ),
    native(
      .materialAndGlassSurface,
      what:
        "Uses native material or availability-gated glass for transient chrome, with an opaque accessibility fallback.",
      use:
        "Floating controls need contextual separation while content remains visible behind them.",
      avoid: "Dense reading content, nested surfaces, or decoration that does not need depth.",
      where: "Apply once to the outer chrome container and honor Reduce Transparency.",
      api: "Material / glassEffect",
      code: """
        controls
          .padding()
          .background(.regularMaterial, in: .rect(cornerRadius: 16))
        """,
      preview: .intrinsic
    ),
  ]
}
