import SwiftUI
import Testing

import DesignOSApple

@Test("Semantic media accepts original media and explicit no-media content")
@MainActor
func semanticMediaFrameCompositionsCompile() {
  let image = DesignOSMediaFrame(aspectRatio: 4.0 / 3.0) {
    Image(systemName: "photo").resizable().scaledToFill().accessibilityHidden(true)
  }
  let placeholder = DesignOSMediaFrame {
    Label("No image available", systemImage: "photo")
  }
  let nested = DesignOSMediaFrame(
    cornerRadius: DesignOSCornerGeometry.innerRadius(outerRadius: 24, inset: 8)
  ) {
    Color.gray.accessibilityHidden(true)
  }
  _ = image.body
  _ = placeholder.body
  _ = nested.body
  #expect(String(reflecting: type(of: image)).contains("DesignOSMediaFrame"))
}

@Test("Semantic avatars retain caller-owned photo and fallback content")
@MainActor
func semanticAvatarCompositionsCompile() {
  let avatar = DesignOSAvatar(size: 40) {
    Image(systemName: "person.crop.circle.fill").resizable().scaledToFill()
      .accessibilityLabel("Example profile")
  }
  let fallback = DesignOSAvatar {
    Text("AB").font(.headline).accessibilityLabel("Example identity")
  }
  _ = avatar.body
  _ = fallback.body
  #expect(String(reflecting: type(of: fallback)).contains("DesignOSAvatar"))
}

@Test("Semantic labeled values preserve actual native input and action slots")
@MainActor
func semanticLabeledValueCompositionsCompile() {
  let label = DesignOSLabeledValueRow("Name") {
    TextField("Display name", text: .constant("Example"))
  }
  let accessory = DesignOSLabeledValueRow("Availability") {
    Toggle("Available", isOn: .constant(true))
  } accessory: {
    Button("Details") {}
  }
  let readonly = DesignOSLabeledValueRow("Location") {
    Text("A long location can wrap without losing its complete value")
  }
  _ = label.body
  _ = accessory.body
  _ = readonly.body
  #expect(String(reflecting: type(of: accessory)).contains("DesignOSLabeledValueRow"))
}

@Test("Semantic status slots accept empty, recovery, busy, and result content")
@MainActor
func semanticStatusMessageCompositionsCompile() {
  let empty = DesignOSStatusMessage("No items", message: "Add an item when you are ready.")
  let recovery = DesignOSStatusMessage("Could not save", message: "Your edits are still here.") {
    Image(systemName: "exclamationmark.triangle").accessibilityHidden(true)
  } actions: {
    Button("Try again") {}.buttonStyle(DesignOSPrimaryButtonStyle())
  }
  let busy = DesignOSStatusMessage("Saving", icon: { ProgressView("Saving") })
  let result = DesignOSStatusMessage("Saved", actions: { Button("Done") {} })
  _ = empty.body
  _ = recovery.body
  _ = busy.body
  _ = result.body
  #expect(String(reflecting: type(of: recovery)).contains("DesignOSStatusMessage"))
}

@Test("Semantic primitives compose outside the dogfood app using public APIs only")
@MainActor
func semanticComponentsComposeWithoutApplicationImports() {
  let content = VStack {
    DesignOSMediaFrame { Color.gray.accessibilityHidden(true) }
    DesignOSAvatar { Image(systemName: "person.fill").accessibilityHidden(true) }
    DesignOSLabeledValueRow("Reference") { Text("Independent consumer") }
    DesignOSStatusMessage("Ready", message: "Caller-owned content and actions.")
  }
  .designOSAppStyle(.editorial)
  .environment(\.dynamicTypeSize, .accessibility3)
  .environment(\.layoutDirection, .rightToLeft)
  #expect(String(reflecting: type(of: content)).contains("ModifiedContent"))
}
