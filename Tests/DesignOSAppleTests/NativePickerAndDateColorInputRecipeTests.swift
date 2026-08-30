import DesignOSApple
import SwiftUI
import Testing

@Test("Picker, date, and color recipe is a public metadata namespace")
func pickerAndDateColorRecipeContract() {
  _ = NativePickerAndDateColorInputRecipe.self
  acceptsView(PickerAndDateColorFixture())
}

private func acceptsView(_: some View) {}

private struct PickerAndDateColorFixture: View {
  @State private var selection = 0
  @State private var date = Date()
  @State private var color = Color.primary

  var body: some View {
    Form {
      Picker("Choice", selection: $selection) {
        Text("First").tag(0)
        Text("Second").tag(1)
      }
      DatePicker("Date", selection: $date)
      ColorPicker("Color", selection: $color)
    }
  }
}
