import SwiftUI

struct NativeButtonAndToolbarActionRecipeGallery: View {
  var body: some View {
    HStack {
      Button("Add", systemImage: "plus") {}
      Button("Delete", systemImage: "trash", role: .destructive) {}
      Button("Unavailable") {}.disabled(true)
    }
  }
}
