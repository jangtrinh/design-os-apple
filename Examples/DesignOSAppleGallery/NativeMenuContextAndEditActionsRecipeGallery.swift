import SwiftUI

struct NativeMenuContextAndEditActionsRecipeGallery: View {
  @State private var status = "Choose an action"

  var body: some View {
    VStack(spacing: 12) {
      Menu("Actions", systemImage: "ellipsis.circle") {
        Button("Duplicate", systemImage: "plus.square.on.square") { status = "Duplicated" }
        Button("Delete", systemImage: "trash", role: .destructive) {
          status = "Delete requested"
        }
      }
      .contextMenu {
        Button("Pin", systemImage: "pin") { status = "Pinned" }
      }
      Text(status)
        .foregroundStyle(.secondary)
    }
  }
}
