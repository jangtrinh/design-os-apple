import Foundation
import XCTest

final class AssistantMiniAppTests: XCTestCase {
  func testThoughtfulChatExposesExactRootsStatesAndTransition() throws {
    let home = try source("ThoughtfulChatHomeDemoView.swift")
    let thread = try source("ThoughtfulChatThreadDemoView.swift")

    XCTAssertTrue(home.contains("struct ThoughtfulChatHomeDemoView: View"))
    XCTAssertTrue(thread.contains("struct ThoughtfulChatThreadDemoView: View"))
    XCTAssertTrue(
      home.contains("design-os.demo.assistant.thoughtful-chat.new-conversation"))
    XCTAssertTrue(
      thread.contains("design-os.demo.assistant.thoughtful-chat.working-thread"))
    XCTAssertTrue(
      home.contains("NavigationLink(value: LocalDemoDestination.thoughtfulChatThread)"))
    XCTAssertTrue(
      home.contains("design-os.demo.assistant.thoughtful-chat.transition.working-thread"))
  }

  func testVisualAssistantExposesExactRootsStatesAndTransition() throws {
    let home = try source("VisualAssistantHomeDemoView.swift")
    let answer = try source("VisualAssistantAnswerDemoView.swift")

    XCTAssertTrue(home.contains("struct VisualAssistantHomeDemoView: View"))
    XCTAssertTrue(answer.contains("struct VisualAssistantAnswerDemoView: View"))
    XCTAssertTrue(home.contains("design-os.demo.assistant.visual.prompt-home"))
    XCTAssertTrue(answer.contains("design-os.demo.assistant.visual.answer-canvas"))
    XCTAssertTrue(
      home.contains("NavigationLink(value: LocalDemoDestination.visualAssistantAnswer)"))
    XCTAssertTrue(
      home.contains("design-os.demo.assistant.visual.transition.answer-canvas"))
  }

  func testCriticalReferenceAnchorsRemainInSource() throws {
    let thoughtfulHome = try source("ThoughtfulChatHomeDemoView.swift")
    let thoughtfulThread = try source("ThoughtfulChatThreadDemoView.swift")
    let thoughtfulTheme = try source("ThoughtfulChatTheme.swift")
    let visualHome = try source("VisualAssistantHomeDemoView.swift")
    let visualAnswer = try source("VisualAssistantAnswerDemoView.swift")
    let visualTheme = try source("VisualAssistantTheme.swift")

    XCTAssertTrue(thoughtfulTheme.contains("static let paper"))
    XCTAssertTrue(thoughtfulHome.contains("design: .serif"))
    XCTAssertTrue(thoughtfulHome.contains("Start a thoughtful conversation"))
    XCTAssertTrue(thoughtfulThread.contains("reactionRow"))
    XCTAssertTrue(thoughtfulThread.contains("safeAreaInset(edge: .bottom"))

    XCTAssertTrue(visualTheme.contains("static let spectrum"))
    XCTAssertTrue(visualHome.contains("Ask anything"))
    XCTAssertTrue(visualAnswer.contains("ShareLink(item: answerText)"))
    XCTAssertTrue(visualAnswer.contains("LocalDemoPasteboard.copy(answerText)"))
    XCTAssertTrue(visualAnswer.contains("regenerationCount += 1"))
    XCTAssertTrue(visualAnswer.contains("sourceActions"))
    XCTAssertTrue(visualAnswer.contains("safeAreaInset(edge: .bottom"))
    XCTAssertTrue(thoughtfulThread.contains("hasAttachment.toggle()"))
  }

  func testThoughtfulComposerPreservesNestedControlSurfaces() throws {
    let home = try source("ThoughtfulChatHomeDemoView.swift")
    let theme = try source("ThoughtfulChatTheme.swift")
    let required = [
      "Upgrade",
      "design-os.demo.assistant.thoughtful-chat.promo-pill",
      "design-os.demo.assistant.thoughtful-chat.add-context",
      "design-os.demo.assistant.thoughtful-chat.model-selector",
      "design-os.demo.assistant.thoughtful-chat.microphone",
    ]

    for anchor in required {
      XCTAssertTrue(home.contains(anchor), "Missing thoughtful composer anchor: \(anchor)")
    }

    for role in [
      "outline", "secondaryControlFill", "primaryControlFill", "primaryControlInk",
    ] {
      XCTAssertTrue(
        theme.contains("static let \(role) = Color.localDemoAdaptive"),
        "Thoughtful composer must own adaptive \(role)"
      )
    }
    XCTAssertTrue(home.contains(".stroke(ThoughtfulChatTheme.outline"))
    XCTAssertTrue(home.contains(".background(ThoughtfulChatTheme.secondaryControlFill"))
    XCTAssertTrue(home.contains(".foregroundStyle(ThoughtfulChatTheme.primaryControlInk)"))
    XCTAssertTrue(home.contains(".background(ThoughtfulChatTheme.primaryControlFill"))
    XCTAssertFalse(home.contains(".stroke(.white"))
  }

  func testVisualComposerSeparatesInputActionsFromLiveAudio() throws {
    let home = try source("VisualAssistantHomeDemoView.swift")
    let required = [
      "design-os.demo.assistant.visual.input-pill",
      "design-os.demo.assistant.visual.input-actions",
      "design-os.demo.assistant.visual.microphone",
      "design-os.demo.assistant.visual.camera",
      "design-os.demo.assistant.visual.transition.answer-canvas",
    ]

    for anchor in required {
      XCTAssertTrue(home.contains(anchor), "Missing visual composer anchor: \(anchor)")
    }
  }

  func testAssistantSemanticSurfacesOwnPairedLightAndDarkPalettes() throws {
    let thoughtfulTheme = try source("ThoughtfulChatTheme.swift")
    let visualTheme = try source("VisualAssistantTheme.swift")

    for role in ["paper", "card", "ink", "clay", "subdued"] {
      XCTAssertTrue(
        thoughtfulTheme.contains("static let \(role) = Color.localDemoAdaptive"),
        "Thoughtful Chat \(role) must adapt with appearance"
      )
    }
    for role in ["canvas", "ink", "muted", "field"] {
      XCTAssertTrue(
        visualTheme.contains("static let \(role) = Color.localDemoAdaptive"),
        "Visual Assistant \(role) must adapt with appearance"
      )
    }
    XCTAssertFalse(visualTheme.contains("static let canvas = Color.white"))
  }

  func testAssistantSourcesContainNoThirdPartyIdentity() throws {
    let combined =
      try assistantSourceFiles
      .map { try String(contentsOf: $0, encoding: .utf8) }
      .joined(separator: "\n")
      .lowercased()
    let forbidden = ["claude", "anthropic", "gemini", "google", "mobbin"]

    for identity in forbidden {
      XCTAssertFalse(combined.contains(identity), "Found forbidden identity: \(identity)")
    }
    XCTAssertFalse(combined.contains("NavigationStack"))
  }

  func testEveryAssistantSwiftFileStaysWithinTwoHundredLines() throws {
    for file in try assistantSourceFiles {
      let source = try String(contentsOf: file, encoding: .utf8)
      XCTAssertLessThanOrEqual(
        source.split(separator: "\n", omittingEmptySubsequences: false).count,
        200,
        file.lastPathComponent
      )
    }
  }

  private func source(_ name: String) throws -> String {
    try String(contentsOf: assistantsRoot.appendingPathComponent(name), encoding: .utf8)
  }

  private var assistantSourceFiles: [URL] {
    get throws {
      try FileManager.default.contentsOfDirectory(
        at: assistantsRoot,
        includingPropertiesForKeys: nil
      ).filter { $0.pathExtension == "swift" }
    }
  }

  private var assistantsRoot: URL {
    URL(fileURLWithPath: #filePath)
      .deletingLastPathComponent()
      .deletingLastPathComponent()
      .deletingLastPathComponent()
      .appendingPathComponent("App/Shared/Flows/Assistants")
  }
}
