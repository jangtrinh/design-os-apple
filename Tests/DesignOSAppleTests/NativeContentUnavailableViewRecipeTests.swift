import DesignOSApple
import SwiftUI
import Testing

@Test("Empty-state recipe exposes a direct ContentUnavailableView call site")
func nativeContentUnavailableViewRecipeCompiles() {
  let recipe = NativeContentUnavailableViewRecipe.self
  let view = ContentUnavailableView(
    "No results",
    systemImage: "magnifyingglass",
    description: Text("Try a different search.")
  )

  #expect(String(reflecting: recipe).contains("NativeContentUnavailableViewRecipe"))
  #expect(String(reflecting: type(of: view)).contains("ContentUnavailableView"))
}
