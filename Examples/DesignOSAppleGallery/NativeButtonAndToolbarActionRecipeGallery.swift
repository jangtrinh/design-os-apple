import SwiftUI

struct NativeButtonAndToolbarActionRecipeGallery: View {
  @State private var status = "Choose an action"

  var body: some View {
    VStack(spacing: 12) {
      HStack {
        Button("Add", systemImage: "plus") { status = "Item added" }
        Button("Delete", systemImage: "trash", role: .destructive) {
          status = "Delete requested"
        }
        Button("Unavailable") {}.disabled(true)
      }
      Text(status)
        .foregroundStyle(.secondary)
    }
  }
}
