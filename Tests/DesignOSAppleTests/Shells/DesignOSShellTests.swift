import DesignOSApple
import SwiftUI
import Testing

@Test("Shells compile with native rows, Sections and controls")
@MainActor
func nativeShellCompositionsCompile() {
  acceptShell(
    DesignOSFlatListShell {
      Section("Items") {
        NavigationLink("Sample", value: "sample")
      }
    }.body
  )
  acceptShell(
    DesignOSGroupedFormShell {
      Section("Settings") {
        Toggle("Enabled", isOn: .constant(true))
        TextField("Name", text: .constant("Sample"))
      }
    }.body
  )
  for image in [Image?.none, Image(systemName: "leaf")] {
    let shell = DesignOSAmbientScrollShell(media: image) {
      VStack {
        Text("Content")
        Text("More content")
      }
    }
    acceptShell(shell.body)
    acceptShell(shell.environment(\.colorScheme, .light))
    acceptShell(shell.environment(\.colorScheme, .dark))
    acceptShell(shell.environment(\.accessibilityReduceTransparency, true))
    acceptShell(shell.environment(\.colorSchemeContrast, .increased))
  }
}

@Test("Focused shell exposes a real disabled native action without invoking it")
@MainActor
func focusedShellCompositionCompiles() {
  var calls = 0
  let shell = DesignOSFocusedTaskShell {
    TextField("Name", text: .constant(""))
  } action: {
    Button("Save") { calls += 1 }
      .buttonStyle(DesignOSPrimaryButtonStyle())
      .disabled(true)
  }
  acceptShell(shell.body)
  #expect(calls == 0)
}

private func acceptShell(_: some View) {}
