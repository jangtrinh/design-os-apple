import SwiftUI

struct SystemDeviceChromeHostRecipeGallery: View {
  var body: some View {
    ContentUnavailableView(
      "System-owned chrome",
      systemImage: "macwindow",
      description: Text(
        "This gallery runs inside native scenes and windows; it draws no device chrome."
      )
    )
  }
}
