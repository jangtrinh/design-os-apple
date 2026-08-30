import SwiftUI

struct NativeTextSearchAndKeyboardInputRecipeGallery: View {
  @State private var text = ""
  @State private var query = ""

  var body: some View {
    Form {
      TextField("Name", text: $text)
    }
    .searchable(text: $query, prompt: "Search")
  }
}
