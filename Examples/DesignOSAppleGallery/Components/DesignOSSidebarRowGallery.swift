import DesignOSApple
import SwiftUI

struct DesignOSSidebarRowGallery: View {
  var body: some View {
    List {
      DesignOSSidebarRow {
        Label("Downloads", systemImage: "arrow.down.circle")
      } accessory: {
        Text("4")
          .font(DesignOSTypographyRole.caption.font)
          .foregroundStyle(.secondary)
      }

      DesignOSSidebarRow {
        Label("Library", systemImage: "books.vertical")
      }
    }
  }
}
