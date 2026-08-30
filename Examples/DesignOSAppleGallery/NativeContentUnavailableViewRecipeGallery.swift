import SwiftUI

struct NativeContentUnavailableViewRecipeGallery: View {
  var body: some View {
    ContentUnavailableView(
      "No saved items",
      systemImage: "bookmark",
      description: Text("Save an item to find it here.")
    )
  }
}
