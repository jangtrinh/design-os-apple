import DesignOSApple
import SwiftUI
import Testing

@Test("Navigation, tabs, and toolbar recipe exposes direct native calls")
@MainActor
func navigationTabsAndToolbarsRecipeContract() {
  _ = NativeNavigationTabsAndToolbarsRecipe.self
  acceptsView(NavigationTabsAndToolbarsFixture())
}

private func acceptsView(_: some View) {}

private struct NavigationTabsAndToolbarsFixture: View {
  @State private var path: [Destination] = []
  @State private var selectedTab = 0

  var body: some View {
    TabView(selection: $selectedTab) {
      NavigationStack(path: $path) {
        Text("Home")
          .navigationDestination(for: Destination.self) { destination in
            Text(destination.title)
          }
          .toolbar {
            ToolbarItem(placement: .primaryAction) {
              Button("Add", systemImage: "plus") {}
            }
          }
      }
      .tabItem { Label("Home", systemImage: "house") }
      .tag(0)

      NavigationSplitView {
        Text("Sidebar")
      } content: {
        Text("Content")
      } detail: {
        Text("Detail")
      }
      .tabItem { Label("Browse", systemImage: "sidebar.left") }
      .tag(1)
    }
  }

  private enum Destination: Hashable {
    case detail

    var title: String { "Detail" }
  }
}
