import SwiftUI

struct NativeMenuContextAndEditActionsRecipeGallery: View {
  var body: some View {
    Menu("Actions", systemImage: "ellipsis.circle") {
      Button("Duplicate", systemImage: "plus.square.on.square") {}
      Button("Delete", systemImage: "trash", role: .destructive) {}
    }
    .contextMenu {
      Button("Pin", systemImage: "pin") {}
    }
  }
}
