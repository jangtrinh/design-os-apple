import SwiftUI

struct NativePickerAndDateColorInputRecipeGallery: View {
  @State private var density = "Automatic"
  @State private var date = Date.now
  @State private var tint = Color.blue

  var body: some View {
    Form {
      Picker("Density", selection: $density) {
        Text("Automatic").tag("Automatic")
        Text("Compact").tag("Compact")
      }
      DatePicker("Date", selection: $date, displayedComponents: .date)
      ColorPicker("Tint", selection: $tint)
    }
  }
}
