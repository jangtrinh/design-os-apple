import DesignOSApple
import SwiftUI
import Testing

@Test("Material and glass recipe is a public metadata namespace")
func materialAndGlassRecipeContract() {
  _ = NativeMaterialAndGlassSurfaceRecipe.self
  acceptsView(MaterialAndGlassFixture())
}

private func acceptsView(_: some View) {}

private struct MaterialAndGlassFixture: View {
  var body: some View {
    if #available(iOS 26, macOS 26, *) {
      Text("Surface").glassEffect()
    } else {
      Text("Surface").background(.regularMaterial)
    }
  }
}
