import DesignOSApple
import SwiftUI
import Testing

@Test("Presentation and share recipe exposes direct native calls")
@MainActor
func presentationAndShareRecipeContract() {
  _ = NativePresentationAndShareRecipe.self
  acceptsView(PresentationAndShareFixture())
}

private func acceptsView(_: some View) {}

private struct PresentationAndShareFixture: View {
  @State private var isAlertPresented = false
  @State private var isDialogPresented = false
  @State private var isSheetPresented = false
  @State private var isCoverPresented = false
  @State private var isPopoverPresented = false

  var body: some View {
    #if os(iOS)
      basePresentations
        .fullScreenCover(isPresented: $isCoverPresented) {
          Text("Full-screen cover")
        }
        .popover(
          isPresented: $isPopoverPresented,
          attachmentAnchor: .rect(.bounds),
          arrowEdge: .top
        ) {
          Text("Popover")
        }
    #else
      basePresentations
        .popover(
          isPresented: $isPopoverPresented,
          attachmentAnchor: .rect(.bounds),
          arrowEdge: .top
        ) {
          Text("Popover")
        }
    #endif
  }

  private var basePresentations: some View {
    VStack {
      ShareLink(item: URL(string: "https://example.com")!) {
        Label("Share", systemImage: "square.and.arrow.up")
      }
      Button("Show alert") { isAlertPresented = true }
    }
    .alert("Alert", isPresented: $isAlertPresented) {
      Button("OK") {}
    }
    .confirmationDialog(
      "Choose an action",
      isPresented: $isDialogPresented,
      titleVisibility: .visible
    ) {
      Button("Continue") {}
    }
    .sheet(isPresented: $isSheetPresented) {
      Text("Sheet")
    }
  }
}
