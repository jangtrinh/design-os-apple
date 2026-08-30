import SwiftUI

struct NativeNavigationTabsAndToolbarsRecipeGallery: View {
  var body: some View {
    TabView {
      ContentUnavailableView("Library", systemImage: "books.vertical")
        .tabItem { Label("Library", systemImage: "books.vertical") }
      ContentUnavailableView("Search", systemImage: "magnifyingglass")
        .tabItem { Label("Search", systemImage: "magnifyingglass") }
    }
  }
}
