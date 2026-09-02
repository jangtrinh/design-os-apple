import DesignOSAppleCatalog

extension StoryReferenceContent {
  static let componentReferenceContent: [Self] = [
    .init(
      storyID: .listRow,
      whatItIs:
        "Orders caller-owned leading, title, subtitle, and trailing content inside a native list row; it does not replace `List`.",
      useWhen:
        "Repeated rows need consistent branded content anatomy while the native host keeps interaction behavior.",
      avoidWhen:
        "The row needs custom selection, swipe, focus, or gesture ownership; keep those on the native container or control.",
      placement:
        "Place inside `List`, `Section`, `Button`, or `NavigationLink` according to the row action.",
      contract: [
        .init(title: "Caller owns", detail: "Content, action, state, and accessibility meaning."),
        .init(title: "Component owns", detail: "Content order and profile-driven spacing."),
        .init(
          title: "Native host owns",
          detail: "Insets, selection, gestures, focus, and disabled state."),
      ],
      code: """
        List {
          NavigationLink {
            ProjectDetail()
          } label: {
            DesignOSListRow {
              Image(systemName: "doc.fill")
            } title: {
              Text("Project brief")
            } subtitle: {
              Text("Updated today")
            } trailing: {
              Text("12 KB")
            }
          }
        }
        """,
      preview: .bounded(.standard)
    ),
    .init(
      storyID: .sidebarRow,
      whatItIs:
        "Composes a caller-owned sidebar label and accessory while the sidebar host keeps selection and navigation behavior.",
      useWhen:
        "A `NavigationSplitView` sidebar needs consistent label and trailing accessory anatomy.",
      avoidWhen: "The destination is a plain text label with no reusable accessory pattern.",
      placement: "Use as the label of a sidebar `NavigationLink` or selection row.",
      contract: [
        .init(title: "Caller owns", detail: "Destination, selection value, label, and accessory."),
        .init(
          title: "Native host owns",
          detail: "Sidebar appearance, focus, disclosure, and navigation."),
      ],
      code: """
        NavigationLink(value: SectionID.inbox) {
          DesignOSSidebarRow {
            Label("Inbox", systemImage: "tray")
          } accessory: {
            Text("4")
          }
        }
        """,
      preview: .bounded(.compact)
    ),
    internalPrimitive(
      .accessorySlotLayout,
      what:
        "Internal geometry that aligns caller-owned row accessories without taking over their semantics.",
      preferred: "Use `DesignOSListRow` or `DesignOSSidebarRow` in product code.",
      placement: "Inside the owning semantic row implementation only.",
      code: """
        DesignOSListRow {
          Image(systemName: "checkmark.circle.fill")
        } title: {
          Text("Synced")
        } subtitle: {
          Text("Just now")
        } trailing: {
          Text("Done")
        }
        """,
      preview: .intrinsic
    ),
    internalPrimitive(
      .sectionContentLayout,
      what: "Internal layout for a section title and trailing caller content.",
      preferred:
        "Prefer a native `Section` or the semantic component that already composes this primitive.",
      placement: "Inside a package-owned section header, not as an app-level container.",
      code: """
        Section {
          RecentItems()
        } header: {
          HStack {
            Text("Recent")
            Spacer()
            Button("See All") {}
          }
        }
        """,
      preview: .intrinsic
    ),
    internalPrimitive(
      .sidebarToolbarContent,
      what:
        "Internal leading/trailing arrangement used by package-owned sidebar toolbar composition.",
      preferred: "Prefer native `ToolbarItem` placement for app toolbar actions.",
      placement: "Inside a package-owned sidebar toolbar adapter only.",
      code: """
        NavigationStack {
          ProjectList()
            .toolbar {
              ToolbarItem(placement: .primaryAction) {
                Button("Add", systemImage: "plus") {}
              }
            }
        }
        """,
      preview: .intrinsic
    ),
    internalPrimitive(
      .symbolContent,
      what: "Internal image geometry policy for caller-owned symbols inside semantic components.",
      preferred: "Pass an `Image` directly to the public component slot in product code.",
      placement: "Inside a package component that must normalize symbol geometry.",
      code: """
        DesignOSListRow {
          Image(systemName: "folder.fill")
        } title: {
          Text("Archive")
        } subtitle: {
          Text("12 items")
        } trailing: {
          Image(systemName: "chevron.forward")
        }
        """,
      preview: .intrinsic
    ),
  ]

  private static func internalPrimitive(
    _ storyID: DesignOSStoryID,
    what: String,
    preferred: String,
    placement: String,
    code: String,
    preview: StoryPreviewPresentation
  ) -> Self {
    .init(
      storyID: storyID,
      whatItIs: what,
      useWhen: "Maintaining or extending the semantic component that owns this primitive.",
      avoidWhen: preferred,
      placement: placement,
      contract: [
        .init(title: "Audience", detail: "Package maintainers, not product call sites."),
        .init(title: "Preferred component", detail: preferred),
      ],
      code: code,
      preview: preview
    )
  }
}
