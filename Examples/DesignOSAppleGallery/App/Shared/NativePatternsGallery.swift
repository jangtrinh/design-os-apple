import SwiftUI

struct NativePatternsGallery: View {
  @State private var notificationsEnabled = true
  @State private var progress = 0.62
  @State private var density = "Automatic"

  var body: some View {
    Form {
      Section("Controls") {
        Toggle("Notifications", isOn: $notificationsEnabled)
        Slider(value: $progress) {
          Text("Progress")
        }
        Picker("Density", selection: $density) {
          Text("Automatic").tag("Automatic")
          Text("Comfortable").tag("Comfortable")
          Text("Compact").tag("Compact")
        }
      }

      Section("Rows and actions") {
        NavigationLink {
          ContentUnavailableView(
            "Native detail",
            systemImage: "swift",
            description: Text("Navigation, chrome, and state are owned by SwiftUI.")
          )
        } label: {
          Label("Navigation row", systemImage: "doc.text")
        }

        Menu("Actions", systemImage: "ellipsis.circle") {
          Button("Duplicate", systemImage: "plus.square.on.square") {}
          Button("Delete", systemImage: "trash", role: .destructive) {}
        }
      }

      Section("System presentation") {
        ShareLink(item: URL(string: "https://developer.apple.com/xcode/swiftui/")!) {
          Label("Share SwiftUI documentation", systemImage: "square.and.arrow.up")
        }
      }
    }
  }
}
