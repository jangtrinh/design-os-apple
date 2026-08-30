import DesignOSApple
import SwiftUI
import Testing

@Test(
  "Symbol content supports Figma image policies",
  arguments: SymbolContentScale.allCases,
  SymbolContentKind.allCases
)
@MainActor
func symbolContentCompiles(scale: SymbolContentScale, kind: SymbolContentKind) {
  acceptsView(
    SymbolContent(scale: scale, kind: kind) {
      Image(systemName: "photo")
        .resizable()
    }
  )
}

private func acceptsView(_: some View) {}
