import SwiftUI

struct NativeListSidebarAndDisclosureRecipeGallery: View {
  @State private var expanded = true

  var body: some View {
    List {
      Section("Library") {
        Label("Recent", systemImage: "clock")
        DisclosureGroup("Collections", isExpanded: $expanded) {
          Label("Favorites", systemImage: "star")
        }
      }
    }
  }
}
