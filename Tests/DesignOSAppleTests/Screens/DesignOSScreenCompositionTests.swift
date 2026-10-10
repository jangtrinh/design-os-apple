import DesignOSApple
import SwiftUI
import Testing

// The compiler checks all bodies. Instantiation/state ownership checks are not hosted
// interactions, accessibility audits or screenshots; run those in a consuming native app.
@Test("Flat collection supports populated, loading, empty, no-results and failed states")
@MainActor
func flatCollectionStateCompositionsCompile() {
  for phase in CollectionPhase.allCases {
    let screen = DesignOSFlatCollectionScreen(showsStatus: phase != .populated) {
      DesignOSAppSectionHeader("Recent")
    } rows: {
      ForEach(["one", "two"], id: \.self) { identifier in
        NavigationLink(value: identifier) { Text(identifier) }
      }
    } status: {
      switch phase {
      case .populated:
        EmptyView()
      case .loading:
        ProgressView("Loading")
      case .empty:
        ContentUnavailableView("No items", systemImage: "tray")
      case .noResults:
        ContentUnavailableView.search(text: "Missing")
      case .failed:
        DesignOSStatusMessage("Could not load", message: "Try again.") {
          Image(systemName: "exclamationmark.circle")
        } actions: {
          Button("Retry") {}
        }
      }
    }
    acceptScreen(screen.body)
    acceptScreen(
      NavigationStack {
        screen.navigationDestination(for: String.self) { Text($0) }
      }
    )
  }
  acceptScreen(DesignOSFlatCollectionScreen(header: { Text("Items") }, rows: { Text("One") }).body)
}

@Test("Media screens support owned media and explicit no-media composition")
@MainActor
func mediaScreenCompositionsCompile() {
  for image in [Image?.none, Image(systemName: "leaf")] {
    let detail = DesignOSMediaDetailScreen(media: image) {
      if let image {
        DesignOSMediaFrame { image.resizable().scaledToFill() }.accessibilityLabel("Sample leaf")
      }
    } identity: {
      DesignOSIdentityHeader(title: { Text("Sample") }, metadata: { Text("Metadata") })
    } content: {
      DesignOSAppSectionHeader("Details")
      Text("Long-form content is not placed in a mandatory card.")
    }
    acceptScreen(detail.body)
    let composer = DesignOSMediaComposerScreen(media: image) {
      if let image {
        DesignOSMediaFrame { image.resizable().scaledToFill() }.accessibilityLabel("Sample leaf")
      }
    } fields: {
      DesignOSFieldGroup {
        TextField("Name", text: .constant("Retained after failure"))
      }
    } feedback: {
      Label("Save failed. Your changes are still here.", systemImage: "exclamationmark.circle")
    }
    acceptScreen(composer.body)
  }
  acceptScreen(
    DesignOSMediaDetailScreen(identity: { Text("Plain") }, content: { Text("Details") }).body
  )
  acceptScreen(DesignOSMediaComposerScreen(fields: { TextField("Name", text: .constant("")) }).body)
}

@Test("Grouped screen retains native controls and consequential action roles")
@MainActor
func groupedScreenCompositionsCompile() {
  let screen = DesignOSGroupedFormScreen {
    Section {
      TextField("Name", text: .constant("Sample"))
      Toggle("Enabled", isOn: .constant(true))
    } header: {
      Text("Details")
    } footer: {
      Text("Changes apply to this item.")
    }
  } consequential: {
    Section {
      Button("Remove", role: .destructive) {}
    }
  }
  acceptScreen(screen.body)
  acceptScreen(DesignOSGroupedFormScreen { Section("Settings") { Text("Value") } }.body)
}

@Test("Focused task keeps input and submission decisions in caller state")
@MainActor
func focusedTaskStateOwnership() {
  let state = TaskValues()
  let name = Binding(get: { state.name }, set: { state.name = $0 })
  for phase in TaskPhase.allCases {
    state.phase = phase
    let screen = DesignOSFocusedTaskScreen {
      DesignOSAppSectionHeader("Name this item")
    } fields: {
      TextField("Name", text: name)
        .onSubmit { state.submitIfReady() }
    } feedback: {
      if state.phase == .failed {
        Label("Save failed; try again.", systemImage: "exclamationmark.circle")
      } else if state.phase == .invalid {
        Text("Enter a name.")
      }
    } action: {
      Button(action: { state.submitIfReady() }) {
        if state.phase == .committing { ProgressView("Saving") } else { Text("Save") }
      }
      .buttonStyle(DesignOSPrimaryButtonStyle())
      .disabled(!state.canSubmit)
    }
    acceptScreen(screen.body)
    acceptScreen(Text("Host").sheet(isPresented: .constant(true)) { NavigationStack { screen } })
    #expect(state.name == "Retained draft")
    #expect(state.submissions == 0)
  }
  // Test the supplied app-owned guard, not an invented screen-owned submission mechanism.
  state.phase = .invalid
  state.submitIfReady()
  #expect(state.submissions == 0)
  state.phase = .ready
  state.submitIfReady()
  state.submitIfReady()
  #expect(state.submissions == 1)
  #expect(state.phase == .committing)
  state.phase = .failed
  #expect(name.wrappedValue == "Retained draft")
  state.submitIfReady()
  #expect(state.submissions == 2)
}

private func acceptScreen(_: some View) {}

private enum CollectionPhase: CaseIterable {
  case populated, loading, empty, noResults, failed
}

private enum TaskPhase: CaseIterable {
  case invalid, ready, committing, failed
}

@MainActor
private final class TaskValues {
  var name = "Retained draft"
  var phase = TaskPhase.invalid
  var submissions = 0
  var canSubmit: Bool { phase == .ready || phase == .failed }

  func submitIfReady() {
    guard canSubmit else { return }
    phase = .committing
    submissions += 1
  }
}
