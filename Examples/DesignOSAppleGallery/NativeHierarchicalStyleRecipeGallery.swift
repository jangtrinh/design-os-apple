import SwiftUI

struct NativeHierarchicalStyleRecipeGallery: View {
  var body: some View {
    VStack(alignment: .leading) {
      Text("Primary")
      Text("Secondary").foregroundStyle(.secondary)
      Text("Tertiary").foregroundStyle(.tertiary)
    }
  }
}
