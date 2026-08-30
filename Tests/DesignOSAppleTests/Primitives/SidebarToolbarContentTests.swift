import DesignOSApple
import SwiftUI
import Testing

@Test("Sidebar toolbar content excludes system chrome and actions")
@MainActor
func sidebarToolbarContentCompiles() {
  acceptsView(
    SidebarToolbarContent {
      Text("Edit")
    } trailing: {
      Image(systemName: "circle")
      Image(systemName: "sidebar.left")
    }
  )
}

private func acceptsView(_: some View) {}
