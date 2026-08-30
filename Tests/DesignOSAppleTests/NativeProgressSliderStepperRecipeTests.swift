import DesignOSApple
import SwiftUI
import Testing

@Test("Progress, range, and stepper recipe is a public metadata namespace")
func progressSliderStepperRecipeContract() {
  _ = NativeProgressSliderStepperRecipe.self
  acceptsView(ProgressSliderStepperFixture())
}

private func acceptsView(_: some View) {}

private struct ProgressSliderStepperFixture: View {
  @State private var value = 0.5
  @State private var count = 1
  @State private var isEnabled = true
  @State private var selection = 0

  var body: some View {
    Form {
      ProgressView(value: value)
      Slider(value: $value, in: 0...1)
      Stepper("Count", value: $count, in: 0...10)
      Toggle("Enabled", isOn: $isEnabled)
      Picker("Mode", selection: $selection) {
        Text("First").tag(0)
        Text("Second").tag(1)
      }.pickerStyle(.segmented)
      TabView(selection: $selection) {
        Text("First").tag(0)
        Text("Second").tag(1)
      }
    }
  }
}
