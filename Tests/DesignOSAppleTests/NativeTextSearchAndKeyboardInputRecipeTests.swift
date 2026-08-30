import DesignOSApple
import SwiftUI
import Testing

@Test("Text, search, focus, and keyboard recipe exposes direct native calls")
@MainActor
func textSearchAndKeyboardInputRecipeContract() {
  _ = NativeTextSearchAndKeyboardInputRecipe.self
  acceptsView(TextSearchAndKeyboardInputFixture())
}

private func acceptsView(_: some View) {}

private struct TextSearchAndKeyboardInputFixture: View {
  @State private var text = ""
  @State private var searchText = ""
  @FocusState private var isTextFieldFocused: Bool

  var body: some View {
    NavigationStack {
      List {
        TextField("Name", text: $text)
          .focused($isTextFieldFocused)
      }
      .searchable(text: $searchText)
      .scrollDismissesKeyboard(.interactively)
    }
  }
}
