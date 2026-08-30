import DesignOSApple
import SwiftUI
import Testing

@Test("Menu, context menu, and edit-action recipe exposes direct native calls")
@MainActor
func menuContextAndEditActionsRecipeContract() {
  _ = NativeMenuContextAndEditActionsRecipe.self
  acceptsView(MenuContextAndEditActionsFixture())
}

private func acceptsView(_: some View) {}

private struct MenuContextAndEditActionsFixture: View {
  var body: some View {
    List {
      Menu("Actions") {
        Button("Duplicate") {}
        Button("Delete", role: .destructive) {}
      }

      Text("Document")
        .contextMenu {
          Button("Rename") {}
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
          Button("Delete", role: .destructive) {}
        }
    }
  }
}
