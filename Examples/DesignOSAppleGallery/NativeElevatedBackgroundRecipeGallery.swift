import SwiftUI

struct NativeElevatedBackgroundRecipeGallery: View {
  var body: some View {
    Text("Native contextual background")
      .padding()
      .background(.background, in: RoundedRectangle(cornerRadius: 14))
  }
}
