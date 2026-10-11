import DesignOSApple
import SwiftUI
import Testing

// All additional canonical families are instantiated against actual public APIs. These
// fixtures prove type compatibility when run natively, not 393 rendered reference states.
@Test("Onboarding, confirmation and status retain native caller actions")
@MainActor
func boundedScreenCompositionsCompile() {
  acceptExtendedScreen(
    DesignOSOnboardingScreen {
      Image(systemName: "leaf").accessibilityHidden(true)
    } introduction: {
      Text("Welcome").font(.largeTitle)
    } choices: {
      Button("Continue with account") {}
    } action: {
      Button("Continue") {}.buttonStyle(DesignOSPrimaryButtonStyle())
    }.body
  )
  acceptExtendedScreen(
    DesignOSConfirmationScreen {
      Text("Remove this item?")
    } details: {
      Text("The app supplies the actual consequence and recovery policy.")
    } actions: {
      Button("Remove", role: .destructive) {}
      Button("Cancel", role: .cancel) {}
    }.body
  )
  acceptExtendedScreen(
    DesignOSStatusScreen {
      Image(systemName: "checkmark.circle").accessibilityHidden(true)
    } message: {
      Text("Saved")
    } details: {
      Text("Your changes were confirmed.")
    } actions: {
      Button("Done") {}
    }.body
  )
}

@Test("Discovery, profile, hero and record screens keep distinct content hierarchy")
@MainActor
func editorialScreenCompositionsCompile() {
  acceptExtendedScreen(
    DesignOSDiscoveryScreen {
      Text("Discover")
    } rails: {
      ScrollView(.horizontal) {
        HStack {
          Text("Nearby")
          Text("Saved")
        }
      }
    } sections: {
      LazyVStack { Text("Result") }
    }.body
  )
  acceptExtendedScreen(
    DesignOSProfileDetailScreen {
      EmptyView()
    } identity: {
      DesignOSIdentityHeader(title: { Text("Profile") }, metadata: { Text("Metadata") })
    } summary: {
      Text("Two items")
    } sections: {
      Text("Profile content")
    }.body
  )
  acceptExtendedScreen(
    DesignOSHeroCollectionScreen {
      DesignOSMediaFrame { Image(systemName: "leaf").resizable().scaledToFit() }
    } introduction: {
      Text("Collection")
    } rows: {
      LazyVStack {
        Text("One")
        Text("Two")
      }
    }.body
  )
  acceptExtendedScreen(
    DesignOSRecordDetailScreen {
      Text("Receipt")
    } credential: {
      EmptyView()
    } details: {
      DesignOSLabeledValueRow("Status") { Text("Confirmed") }
    } actions: {
      Button("Close") {}
    }.body
  )
}

@Test("Native and provider host screens do not simulate integrations")
@MainActor
func nativeHostScreenCompositionsCompile() {
  acceptExtendedScreen(
    DesignOSFreeformEditorScreen("Notes", text: .constant("Unsaved draft")) {
      Text("Save failed; your draft remains.")
    }.body
  )
  acceptExtendedScreen(DesignOSFreeformEditorScreen("Notes", text: .constant("")).body)
  acceptExtendedScreen(
    DesignOSProviderHostScreen {
      ContentUnavailableView("Provider fixture", systemImage: "creditcard")
    } disclosure: {
      Text("No provider connection or transaction in this fixture.")
    } recovery: {
      Button("Cancel", role: .cancel) {}
    }.body
  )
  acceptExtendedScreen(
    DesignOSNativePresentationScreen {
      Button("Remove") {}
        .confirmationDialog("Remove?", isPresented: .constant(false)) {
          Button("Remove", role: .destructive) {}
          Button("Cancel", role: .cancel) {}
        }
    } context: {
      Text("Native confirmation fixture")
    }.body
  )
  acceptExtendedScreen(
    DesignOSUtilityCanvasScreen {
      Color.clear.accessibilityLabel("Camera integration fixture, not a working camera")
    } status: {
      Text("Camera unavailable")
    } controls: {
      Button("Close") {}
    }.body
  )
}

@Test("Message thread exposes native composer without automatic send or scroll")
@MainActor
func messageThreadCompositionCompiles() {
  var sends = 0
  let screen = DesignOSMessageThreadScreen { _ in
    LazyVStack(alignment: .leading) {
      Text("Incoming message").id("one")
      Text("Outgoing message").id("two")
    }
  } status: {
    Text("Not delivered")
  } composer: {
    HStack {
      TextField("Message", text: .constant("Retained draft"), axis: .vertical)
      Button("Send") { sends += 1 }.disabled(true)
    }
  }
  acceptExtendedScreen(screen.body)
  #expect(sends == 0)
}

@Test("Search filtering and failed states do not silently clear caller-owned selection")
@MainActor
func searchSelectionStateOwnership() {
  let state = SelectionValues()
  let query = Binding(get: { state.query }, set: { state.query = $0 })
  let single = Binding(get: { state.single }, set: { state.single = $0 })
  let multiple = Binding(get: { state.multiple }, set: { state.multiple = $0 })
  for isEmpty in [false, true] {
    acceptExtendedScreen(
      DesignOSSearchSelectionScreen(query: query, selection: single, showsStatus: isEmpty) {
        Text("One").tag("one")
      } status: {
        ContentUnavailableView.search(text: state.query)
      }.body
    )
    acceptExtendedScreen(
      DesignOSSearchSelectionScreen(query: query, selection: multiple, showsStatus: isEmpty) {
        Text("One").tag("one")
      } status: {
        Text("Could not load results. Try again.")
      }.body
    )
  }
  query.wrappedValue = "No results"
  #expect(single.wrappedValue == "one")
  #expect(multiple.wrappedValue == ["one"])
  #expect(query.wrappedValue == "No results")
}

private func acceptExtendedScreen(_: some View) {}

@MainActor
private final class SelectionValues {
  var query = ""
  var single: String? = "one"
  var multiple: Set<String> = ["one"]
}
