import DesignOSApple
import SwiftUI
import Testing

@Test("List, sidebar, and disclosure recipe exposes direct native calls")
@MainActor
func listSidebarAndDisclosureRecipeContract() {
  _ = NativeListSidebarAndDisclosureRecipe.self
  acceptsView(ListSidebarAndDisclosureFixture())
}

private func acceptsView(_: some View) {}

private struct ListSidebarAndDisclosureFixture: View {
  @State private var selection: Int?
  @State private var isExpanded = false

  var body: some View {
    NavigationSplitView {
      List(selection: $selection) {
        Text("Inbox").tag(1)
        DisclosureGroup("More", isExpanded: $isExpanded) {
          Text("Archive").tag(2)
        }
      }
    } content: {
      Text("Selected content")
    } detail: {
      Text("Detail")
    }
  }
}
