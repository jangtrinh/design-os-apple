import DesignOSApple
import SwiftUI
import Testing

// These tests compile and instantiate native composition; they do not claim rendered QA.
@Test("Field group preserves native bindings and has optional header and help slots")
@MainActor
func fieldGroupCompositionsCompile() {
  let values = CompositeValues()
  let name = Binding(get: { values.name }, set: { values.name = $0 })
  let included = Binding(get: { values.included }, set: { values.included = $0 })
  let group = DesignOSFieldGroup {
    DesignOSAppSectionHeader("Details")
  } content: {
    TextField("Name", text: name)
    Divider()
    Toggle("Include", isOn: included)
  } footer: {
    Text("Changes are kept until Save succeeds.")
  }
  acceptComposite(group.body)
  acceptComposite(DesignOSFieldGroup { TextField("Name", text: name) }.body)
  name.wrappedValue = "Updated"
  included.wrappedValue = false
  #expect(values.name == "Updated")
  #expect(!values.included)
}

@Test("Identity header accepts media, no media, real actions and accessibility text sizes")
@MainActor
func identityHeaderCompositionsCompile() {
  var invocations = 0
  let header = DesignOSIdentityHeader {
    DesignOSAvatar { Image(systemName: "person.fill").accessibilityHidden(true) }
  } title: {
    Text("Long identity title that must remain readable")
      .font(.title).accessibilityAddTraits(.isHeader)
  } metadata: {
    Text("Supporting information").foregroundStyle(.secondary)
  } actions: {
    Button("Follow") { invocations += 1 }.buttonStyle(DesignOSSecondaryButtonStyle())
  }
  acceptComposite(header.body)
  acceptComposite(header.environment(\.dynamicTypeSize, .accessibility5))
  acceptComposite(
    DesignOSIdentityHeader(title: { Text("Plain identity") }, metadata: { Text("Info") })
  )
  #expect(invocations == 0)
}

private func acceptComposite(_: some View) {}

@MainActor
private final class CompositeValues {
  var name = "Original"
  var included = true
}
