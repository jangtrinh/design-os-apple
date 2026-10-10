import DesignOSApple
import SwiftUI
import Testing

@Test("Material and glass recipe is a public metadata namespace")
@MainActor
func materialAndGlassRecipeContract() {
  _ = NativeMaterialAndGlassSurfaceRecipe.self
  acceptsView(MaterialAndGlassFixture())
}

private func acceptsView(_: some View) {}

private struct MaterialAndGlassFixture: View {
  @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

  var body: some View {
    if reduceTransparency {
      Text("Surface").background(.background)
    } else {
      #if compiler(>=6.2)
      if #available(iOS 26, macOS 26, *) {
        Text("Surface").glassEffect()
      } else {
        Text("Surface").background(.regularMaterial)
      }
      #else
      Text("Surface").background(.regularMaterial)
      #endif
    }
  }
}
