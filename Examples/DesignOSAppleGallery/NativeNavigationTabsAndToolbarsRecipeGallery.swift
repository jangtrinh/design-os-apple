import DesignOSApple
import SwiftUI

struct NativeNavigationTabsAndToolbarsRecipeGallery: View {
  enum SectionItem: String, CaseIterable, Identifiable, Hashable {
    case library = "Library"
    case favorites = "Favorites"
    case recents = "Recents"

    var id: String { rawValue }
    var symbolName: String {
      switch self {
      case .library: "books.vertical"
      case .favorites: "star"
      case .recents: "clock"
      }
    }
  }

  enum NavigationMode: String, CaseIterable, Identifiable {
    case split = "Split View"
    case tabs = "Tabs"

    var id: String { rawValue }
  }

  @State private var mode: NavigationMode = .split
  @State private var selectedItem: SectionItem? = nil
  @State private var preferredColumn: NavigationSplitViewColumn = .sidebar
  @State private var selectedTab: Int = 0

  var body: some View {
    Group {
      switch mode {
      case .split:
        splitNavigation
      case .tabs:
        tabsNavigation
      }
    }
  }

  private var splitNavigation: some View {
    NavigationSplitView(preferredCompactColumn: $preferredColumn) {
      List(SectionItem.allCases, id: \.self, selection: $selectedItem) { item in
        NavigationLink(value: item) {
          Label(item.rawValue, systemImage: item.symbolName)
            .accessibilityIdentifier("design-os.navigation.section.\(item.rawValue.lowercased())")
        }
        .accessibilityIdentifier("design-os.navigation.row.\(item.rawValue.lowercased())")
      }
      .navigationTitle("Adaptive Navigation")
      .navigationDestination(for: SectionItem.self) { item in
        detailContent(for: item)
      }
      .toolbar {
        ToolbarItem(placement: .principal) {
          modePicker
        }
        ToolbarItem(placement: .primaryAction) {
          Button("Action", systemImage: "ellipsis.circle") {}
            .accessibilityIdentifier("design-os.navigation.toolbar.action")
        }
      }
    } detail: {
      detailContent(for: selectedItem)
    }
  }

  private var tabsNavigation: some View {
    TabView(selection: $selectedTab) {
      NavigationStack {
        ContentUnavailableView("Library", systemImage: "books.vertical")
          .navigationTitle("Library")
          .toolbar {
            ToolbarItem(placement: .principal) {
              modePicker
            }
          }
      }
      .tabItem { Label("Library", systemImage: "books.vertical") }
      .tag(0)

      NavigationStack {
        ContentUnavailableView("Search", systemImage: "magnifyingglass")
          .navigationTitle("Search")
          .toolbar {
            ToolbarItem(placement: .principal) {
              modePicker
            }
          }
      }
      .tabItem { Label("Search", systemImage: "magnifyingglass") }
      .tag(1)
    }
  }

  private var modePicker: some View {
    Picker("Mode", selection: $mode) {
      ForEach(NavigationMode.allCases) { mode in
        Text(mode.rawValue).tag(mode)
      }
    }
    .pickerStyle(.segmented)
    .accessibilityIdentifier("design-os.navigation.mode-picker")
  }

  @ViewBuilder
  private func detailContent(for item: SectionItem?) -> some View {
    if let item {
      VStack(spacing: 16) {
        Image(systemName: item.symbolName)
          .font(.system(size: 56))
          .foregroundStyle(.tint)
        Text(item.rawValue)
          .font(.title2.weight(.semibold))
        Text("Caller-owned selection state: \(item.rawValue)")
          .font(.subheadline)
          .foregroundStyle(.secondary)
          .accessibilityIdentifier("design-os.navigation.detail.selection")
        Text("Adapts between compact single stack and wide two-column split view.")
          .font(.caption)
          .foregroundStyle(.tertiary)
          .multilineTextAlignment(.center)
          .padding(.horizontal)
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .navigationTitle(item.rawValue)
    } else {
      ContentUnavailableView(
        "Select an Item",
        systemImage: "sidebar.left",
        description: Text("Choose an item from the sidebar to inspect adaptive navigation.")
      )
    }
  }
}
