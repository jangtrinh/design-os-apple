import DesignOSApple
import SwiftUI
import Testing

@Test("Hierarchical style recipe is a public metadata namespace")
func hierarchicalStyleRecipeContract() {
  _ = NativeHierarchicalStyleRecipe.self
  acceptsView(HierarchicalStyleFixture())
}

private func acceptsView(_: some View) {}

private struct HierarchicalStyleFixture: View {
  var body: some View {
    VStack {
      Text("Primary").foregroundStyle(.primary)
      Text("Secondary").foregroundStyle(.secondary)
      Text("Tertiary").foregroundStyle(.tertiary)
      Text("Quaternary").foregroundStyle(.quaternary)
    }
  }
}
