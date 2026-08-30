import DesignOSApple
import SwiftUI
import Testing

@Test("Button and toolbar recipe is a public metadata namespace")
func buttonAndToolbarRecipeContract() {
  _ = NativeButtonAndToolbarActionRecipe.self
  acceptsView(ButtonAndToolbarFixture())
}

private func acceptsView(_: some View) {}

private struct ButtonAndToolbarFixture: View {
  var body: some View {
    NavigationStack {
      Button("Continue") {}
        .toolbar {
          ToolbarItem(placement: .primaryAction) {
            Button("Add", systemImage: "plus") {}
          }
        }
    }
  }
}
