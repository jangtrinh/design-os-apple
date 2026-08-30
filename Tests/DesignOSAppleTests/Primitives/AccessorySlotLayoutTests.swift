import DesignOSApple
import SwiftUI
import Testing

@Test("Accessory slots compose caller-owned content")
@MainActor
func accessorySlotLayoutCompiles() {
  acceptsView(
    AccessorySlotLayout {
      Text("Detail")
      Image(systemName: "info.circle")
    }
  )
}

private func acceptsView(_: some View) {}
