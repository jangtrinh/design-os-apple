import DesignOSApple
import SwiftUI
import Testing

@testable import DesignOSApple

// Native compilation and instantiation fixtures, plus explicit caller-state and shared layout
// policy tests. These do not claim hosted interaction, VoiceOver or screenshot verification.
@Test("Choice row preserves independently labeled native selection and caller state")
@MainActor
func choiceRowCompositionCompiles() {
  let state = CompositeDraft()
  let selected = Binding(get: { state.selected }, set: { state.selected = $0 })
  let row = DesignOSChoiceRow {
    DesignOSAvatar { Image(systemName: "person").accessibilityHidden(true) }
  } description: {
    Text("A long choice title")
    Text("Details that remain available at large text sizes")
  } control: {
    Toggle("Select this person", isOn: selected)
  }
  acceptsExtendedComposite(row.body)
  acceptsExtendedComposite(row.environment(\.dynamicTypeSize, .accessibility5))
  acceptsExtendedComposite(row.environment(\.layoutDirection, .rightToLeft))
  selected.wrappedValue = true
  #expect(state.selected)
}

@Test("Selection summary keeps count, readiness and native action decisions caller-owned")
@MainActor
func selectionSummaryCompositionCompiles() {
  var completions = 0
  for count in [0, 1, 12] {
    let summary = DesignOSSelectionSummary {
      Text("Selected: \(count)")
      Text("Selection is preserved while filtering")
    } actions: {
      Button("Continue with selection") { completions += 1 }
        .buttonStyle(DesignOSPrimaryButtonStyle())
        .disabled(count == 0)
      Button("Clear selection") {}
    }
    acceptsExtendedComposite(summary.body)
    acceptsExtendedComposite(summary.environment(\.dynamicTypeSize, .accessibility5))
  }
  #expect(completions == 0)
}

@Test("Category rail has populated and explicit empty compositions with stable item IDs")
@MainActor
func categoryRailCompositionCompiles() {
  let samples = [RailItem(id: "nearby", title: "Nearby"), RailItem(id: "saved", title: "Saved")]
  var selections = 0
  for items in [samples, []] {
    let rail = DesignOSCategoryRail(items) {
      DesignOSAppSectionHeader("Categories")
    } item: { item in
      Button(item.title) { selections += 1 }
        .buttonStyle(DesignOSSecondaryButtonStyle())
    } empty: {
      Text("No categories available")
    }
    acceptsExtendedComposite(rail.body)
    acceptsExtendedComposite(rail.environment(\.dynamicTypeSize, .accessibility5))
  }
  #expect(samples.map(\.id) == ["nearby", "saved"])
  #expect(selections == 0)
}

@Test("Detail and composer headers support media, no-media and retained invalid fields")
@MainActor
func mediaHeaderCompositionsCompile() {
  let state = CompositeDraft()
  let draft = Binding(get: { state.text }, set: { state.text = $0 })
  for hasMedia in [false, true] {
    let detail = DesignOSMediaDetailHeader {
      if hasMedia {
        DesignOSMediaFrame { Image(systemName: "leaf").resizable().scaledToFit() }
          .accessibilityLabel("Sample leaf")
      }
    } identity: {
      EmptyView()
    } title: {
      Text("An item with a long descriptive title").font(.title)
    } metadata: {
      Text("Supporting information")
    } actions: {
      Button("Edit") {}.buttonStyle(DesignOSSecondaryButtonStyle())
    }
    acceptsExtendedComposite(detail.body)
    acceptsExtendedComposite(detail.environment(\.dynamicTypeSize, .accessibility5))
    let composer = DesignOSMediaComposerHeader {
      if hasMedia {
        DesignOSMediaFrame { Image(systemName: "leaf").resizable().scaledToFit() }
          .accessibilityLabel("Sample leaf")
      }
    } mediaActions: {
      Menu("Change media") { Button("Choose existing image") {} }
    } field: {
      TextField("Name", text: draft, axis: .vertical)
    } feedback: {
      Text("Save failed. Your draft remains available.")
    }
    acceptsExtendedComposite(composer.body)
    #expect(draft.wrappedValue == "Retained draft")
  }
}

@Test("Message bubble keeps direction, reply context and persistent failed delivery metadata")
@MainActor
func messageBubbleCompositionsCompile() {
  for isOutgoing in [false, true] {
    let bubble = DesignOSMessageBubble(isOutgoing: isOutgoing) {
      Text("Replying to an earlier message").font(.caption)
    } content: {
      Text("Message content that wraps instead of truncating.")
      NestedBubbleMediaFixture()
    } metadata: {
      Label("Not delivered", systemImage: "exclamationmark.circle")
      Button("Retry") {}
    }
    acceptsExtendedComposite(bubble.body)
    acceptsExtendedComposite(bubble.environment(\.dynamicTypeSize, .accessibility5))
    acceptsExtendedComposite(bubble.environment(\.layoutDirection, .rightToLeft))
  }
  acceptsExtendedComposite(
    DesignOSMessageBubble(
      isOutgoing: false, content: { Text("Hello") }, metadata: { Text("Today") }
    )
    .body
  )
}

@Test("Conversation composer keeps draft and repeated-submit guard in the caller")
@MainActor
func conversationComposerStateOwnership() {
  let state = CompositeDraft()
  let draft = Binding(get: { state.text }, set: { state.text = $0 })
  let composer = DesignOSConversationComposer {
    Menu("Attach") { Button("Choose image") {} }
  } input: {
    TextField("Message", text: draft, axis: .vertical).lineLimit(1...5)
      .onSubmit { state.submitIfReady() }
  } actions: {
    Button("Send") { state.submitIfReady() }.disabled(state.isSending)
  } feedback: {
    Text("Send failed. Try again.")
  }
  acceptsExtendedComposite(composer.body)
  acceptsExtendedComposite(composer.environment(\.dynamicTypeSize, .accessibility5))
  #expect(state.submissions == 0)
  state.submitIfReady()
  state.submitIfReady()
  #expect(state.submissions == 1)
  #expect(draft.wrappedValue == "Retained draft")
  state.isSending = false
  state.submitIfReady()
  #expect(state.submissions == 2)
}

@Test("Record summary and utility overlay preserve readable statuses and real actions")
@MainActor
func recordAndUtilityCompositionsCompile() {
  let record = DesignOSRecordSummary {
    Text("Record identifier").font(.headline)
    Text("Record type")
  } status: {
    Text("Confirmed")
    Text("Updated today")
  } facts: {
    DesignOSLabeledValueRow("Date") { Text("Today") }
    DesignOSLabeledValueRow("Type") { Text("Sample") }
  }
  acceptsExtendedComposite(record.body)
  acceptsExtendedComposite(record.environment(\.dynamicTypeSize, .accessibility5))
  for text in ["Waiting for access", "No result", "Result available"] {
    let overlay = DesignOSUtilityOverlay {
      Text(text)
      Text("Additional context")
    } actions: {
      Button("Close") {}
      Button("More information") {}
    }
    acceptsExtendedComposite(overlay.body)
    acceptsExtendedComposite(overlay.environment(\.dynamicTypeSize, .accessibility5))
    acceptsExtendedComposite(overlay.environment(\.colorScheme, .dark))
  }
}

@Test("Choice and composer shared layout policy reflows long controls and accessibility text")
func compositeAdaptiveLayoutPolicy() {
  #expect(
    !DesignOSEditorialRowPolicy.usesVerticalLayout(
      availableWidth: 400, idealWidths: [44, 200, 88], spacing: 12, accessibilitySize: false
    )
  )
  #expect(
    DesignOSEditorialRowPolicy.usesVerticalLayout(
      availableWidth: 240, idealWidths: [44, 200, 88], spacing: 12, accessibilitySize: false
    )
  )
  #expect(
    DesignOSEditorialRowPolicy.usesVerticalLayout(
      availableWidth: 800, idealWidths: [44, 200, 88], spacing: 12, accessibilitySize: true
    )
  )
  #expect(
    DesignOSEditorialRowPolicy.horizontalWidths(
      availableWidth: 400, idealWidths: [44, 200, 88], spacing: 12
    ) == [44, 244, 88]
  )
}

private func acceptsExtendedComposite(_: some View) {}

private struct RailItem: Identifiable {
  let id: String
  let title: String
}

@MainActor
private final class CompositeDraft {
  var text = "Retained draft"
  var selected = false
  var isSending = false
  var submissions = 0

  func submitIfReady() {
    guard !isSending, !text.isEmpty else { return }
    isSending = true
    submissions += 1
  }
}

// The bubble owns one contentInset of padding; the media uses that actual concentric inset.
private struct NestedBubbleMediaFixture: View {
  @Environment(\.designOSAppStyle) private var style

  var body: some View {
    DesignOSMediaFrame(
      cornerRadius: DesignOSCornerGeometry.innerRadius(
        outerRadius: style.metrics.surfaceRadius, inset: style.metrics.contentInset
      )
    ) {
      Image(systemName: "leaf").resizable().scaledToFit()
    }
    .accessibilityLabel("Synthetic leaf attachment")
  }
}
