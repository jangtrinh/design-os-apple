import DesignOSAppleCatalog

extension StoryReferenceContent {
  static let nativeReferenceContentB: [Self] = [
    native(
      .menuContextAndEditActions,
      what:
        "Uses native menus, context menus, and edit actions for discoverable secondary commands.",
      use: "Several related actions belong to one object or compact command surface.",
      avoid:
        "The action is primary, destructive without confirmation, or must always stay visible.",
      where: "Use `Menu` in visible chrome and `.contextMenu` on the object it affects.",
      api: "Menu / contextMenu",
      code: """
        Menu("More", systemImage: "ellipsis.circle") {
          Button("Duplicate", systemImage: "plus.square.on.square") {
            duplicate()
          }
          Button("Delete", systemImage: "trash", role: .destructive) {
            confirmDelete()
          }
        }
        """,
      preview: .bounded(.compact)
    ),
    native(
      .navigationTabsAndToolbars,
      what:
        "Uses `NavigationSplitView`, `NavigationStack`, `TabView`, and toolbars directly so platform navigation adapts natively.",
      use:
        "The app needs hierarchical navigation, peer destinations, two-column split navigation, or context-aware commands.",
      avoid:
        "Custom chrome would duplicate native Back, tab selection, split adaptation, or toolbar placement.",
      where:
        "Choose one navigation owner per scene; place toolbars on the destination that owns their actions.",
      api: "NavigationSplitView / NavigationStack / TabView / toolbar",
      code: """
        TabView {
          NavigationSplitView {
            List(items, selection: $selectedItem) { item in
              NavigationLink(item.title, value: item)
            }
          } detail: {
            ItemDetail(item: selectedItem)
          }
          .tabItem { Label("Browse", systemImage: "sidebar.left") }
        }
        """,
      preview: .destination
    ),
    native(
      .pickerAndDateColorInput,
      what:
        "Uses SwiftUI `Picker`, `DatePicker`, and `ColorPicker` directly for typed value input.",
      use: "A user chooses one option, date/time, or color with platform input behavior.",
      avoid: "Free-form text or a small binary choice better fits `TextField` or `Toggle`.",
      where: "Place inside the form or settings section that owns the bound value.",
      api: "Picker / DatePicker / ColorPicker",
      code: """
        Form {
          Picker("Priority", selection: $priority) {
            ForEach(Priority.allCases) { Text($0.title).tag($0) }
          }
          DatePicker("Due", selection: $dueDate)
          ColorPicker("Accent", selection: $accent)
        }
        """,
      preview: .destination
    ),
    native(
      .presentationAndShare,
      what:
        "Uses native sheets, popovers, confirmation dialogs, and `ShareLink` for transient presentation.",
      use:
        "Content or a decision temporarily overlays the current task, or a value is shared outside the app.",
      avoid:
        "The destination belongs in persistent navigation or requires a custom overlay to imitate a sheet.",
      where: "Attach presentation state to the view that owns the initiating action.",
      api: "sheet / popover / confirmationDialog / ShareLink",
      code: """
        Button("Show details") { isPresented = true }
          .sheet(isPresented: $isPresented) {
            DetailSheet()
          }

        ShareLink(item: exportURL)
        """,
      preview: .intrinsic
    ),
    native(
      .progressSliderStepper,
      what:
        "Uses native progress and numeric adjustment controls with system-owned geometry and accessible values.",
      use: "Show completion or let the user adjust a bounded continuous or stepped value.",
      avoid: "The value is categorical, unbounded text, or better selected from explicit options.",
      where: "Keep the visible value and unit next to the control inside its owning form section.",
      api: "ProgressView / Slider / Stepper",
      code: """
        ProgressView(value: progress)
        Slider(value: $volume, in: 0...1) {
          Text("Volume")
        }
        Stepper("Guests: \\(guestCount)", value: $guestCount, in: 1...8)
        """,
      preview: .bounded(.standard)
    ),
    native(
      .textSearchAndKeyboardInput,
      what:
        "Uses native text fields, searchable content, focus, submit, and keyboard configuration.",
      use: "Users enter text or filter a collection with platform keyboard and search behavior.",
      avoid: "A closed value set should use a picker, toggle, or other typed control.",
      where:
        "Attach `.searchable` to the collection/navigation container and focus state to the owning form.",
      api: "TextField / searchable / FocusState",
      code: """
        List(filteredItems) { Text($0.title) }
          .searchable(text: $query, prompt: "Search projects")
          .onSubmit(of: .search) { recordQuery() }
        """,
      preview: .destination
    ),
    native(
      .systemDeviceChromeHost,
      what:
        "Keeps status bars, safe areas, keyboard, windows, and scene chrome owned by the system host.",
      use: "A full-scene design must coexist with device, window, and keyboard geometry.",
      avoid:
        "Drawing fake status bars, home indicators, title bars, or keyboard gaps into reusable views.",
      where:
        "Resolve safe-area and scene behavior at the app/window host, not inside leaf components.",
      api: "safeAreaInset / scene / window APIs",
      code: """
        NavigationStack {
          ContentView()
            .safeAreaInset(edge: .bottom) {
              PlaybackControls()
            }
        }
        """,
      preview: .destination
    ),
  ]

  static func native(
    _ storyID: DesignOSStoryID,
    what: String,
    use: String,
    avoid: String,
    where placement: String,
    api: String,
    code: String,
    preview: StoryPreviewPresentation
  ) -> Self {
    .init(
      storyID: storyID,
      whatItIs: what,
      useWhen: use,
      avoidWhen: avoid,
      placement: placement,
      contract: [
        .init(title: "Native API", detail: api),
        .init(
          title: "Ownership",
          detail: "SwiftUI owns control behavior and accessibility; the app owns state and copy."),
      ],
      code: code,
      preview: preview
    )
  }
}
