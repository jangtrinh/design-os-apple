import SwiftUI

struct NativePresentationAndShareRecipeGallery: View {
  @State private var showsAlert = false
  @State private var showsSheet = false

  var body: some View {
    VStack(spacing: 12) {
      Button("Show alert") { showsAlert = true }
      Button("Show sheet") { showsSheet = true }
      ShareLink(item: URL(string: "https://developer.apple.com/xcode/swiftui/")!)
    }
    .alert("Native alert", isPresented: $showsAlert) {
      Button("OK") {}
    }
    .sheet(isPresented: $showsSheet) {
      ContentUnavailableView("Native sheet", systemImage: "rectangle.bottomhalf.inset.filled")
        .padding()
    }
  }
}
