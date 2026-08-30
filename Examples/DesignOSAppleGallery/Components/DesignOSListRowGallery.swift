import DesignOSApple
import SwiftUI

struct DesignOSListRowGallery: View {
  var body: some View {
    List {
      Section("Content-only rows") {
        DesignOSListRow {
          Image(systemName: "doc.fill")
            .foregroundStyle(DesignOSColorRole.blue.color)
        } title: {
          Text("Project brief")
        } subtitle: {
          Text("Updated today")
        } trailing: {
          Text("12 KB").foregroundStyle(.secondary)
        }

        DesignOSListRow {
          Text("Title-only row")
        }
      }
    }
  }
}
