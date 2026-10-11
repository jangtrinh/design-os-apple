import DesignOSApple
import SwiftUI
import Testing

@Test("Additional shells preserve native host, navigation, canvas and conversation boundaries")
@MainActor
func extendedShellCompositionsCompile() {
  acceptExtendedShell(DesignOSFlatScrollShell { Text("Editorial content") }.body)
  acceptExtendedShell(
    DesignOSFlatScrollShell(padded: false) { Color.clear.frame(height: 100) }.body
  )
  acceptExtendedShell(
    DesignOSNativeHostShell { TextEditor(text: .constant("Native scrolling editor")) }.body
  )
  acceptExtendedShell(
    DesignOSConversationShell { _ in
      LazyVStack { Text("Message").id("message-1") }
    } composer: {
      TextField("Message", text: .constant("Draft"), axis: .vertical)
    }.body
  )
  acceptExtendedShell(
    DesignOSUtilityCanvasShell {
      Color.clear.accessibilityLabel("Integration fixture only")
    } overlay: {
      Text("Permission required")
    } controls: {
      Button("Close") {}
    }.body
  )
  acceptExtendedShell(
    DesignOSAdaptiveNavigationShell(columnVisibility: .constant(.automatic)) {
      List { NavigationLink("Detail", value: "detail") }
    } detail: {
      NavigationStack { Text("Selected content") }
    }.body
  )
}

@Test("Flat List shell composes native optional and set selection")
@MainActor
func nativeSelectionShellCompositionsCompile() {
  acceptExtendedShell(
    DesignOSFlatListShell(selection: Binding<String?>.constant("one")) {
      Text("One").tag("one")
    }.body
  )
  acceptExtendedShell(
    DesignOSFlatListShell(selection: Binding<Set<String>>.constant(["one"])) {
      Text("One").tag("one")
      Text("Two").tag("two")
    }.body
  )
}

private func acceptExtendedShell(_: some View) {}
