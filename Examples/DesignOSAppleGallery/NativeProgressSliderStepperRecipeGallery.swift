import SwiftUI

struct NativeProgressSliderStepperRecipeGallery: View {
  @State private var enabled = true
  @State private var progress = 0.62
  @State private var count = 2

  var body: some View {
    Form {
      Toggle("Enabled", isOn: $enabled)
      Slider(value: $progress) { Text("Progress") }
      ProgressView(value: progress)
      Stepper("Count: \(count)", value: $count, in: 0...10)
    }
  }
}
