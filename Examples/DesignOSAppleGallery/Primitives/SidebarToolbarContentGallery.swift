import SwiftUI

struct SidebarToolbarContentGallery: View {
  var body: some View {
    HStack {
      Label("Library", systemImage: "books.vertical")
      Spacer()
      Image(systemName: "sidebar.left")
    }
  }
}
