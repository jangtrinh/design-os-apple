import XCTest

final class DesignOSAppleGalleryLocalDemoMacOSUITests: XCTestCase {
  @MainActor
  func testEveryMiniAppUsesNativeBackRoundTrip() {
    let app = launchMiniApps()
    capture("local-demo-macos-00-mini-apps", app: app)

    for flow in MacMiniAppFlow.all {
      open(flow.cardID, expecting: flow.entryID, in: app)
      if let preparationID = flow.preparationID {
        scrollUntilHittable(preparationID, in: app).click()
      }
      if flow.usesScrollTransition {
        scrollUntilVisibleState(element(flow.detailID, in: app), in: app)
      } else if let transitionID = flow.transitionID {
        scrollUntilHittable(transitionID, in: app).click()
        assertReady(flow.detailID, in: app)
        nativeBack(in: app).click()
        assertReady(flow.entryID, in: app)
      }
      nativeBack(in: app).click()
      assertReady("design-os.gallery.examples.ready", in: app)
    }
  }

  @MainActor
  private func launchMiniApps() -> XCUIApplication {
    let app = XCUIApplication()
    if let appearance = ProcessInfo.processInfo.environment["DESIGN_OS_UI_TEST_APPEARANCE"] {
      app.launchArguments += ["-AppleInterfaceStyle", appearance]
    }
    app.launchArguments += ["-ApplePersistenceIgnoreState", "YES"]
    app.launch()
    let examples = app.buttons["Examples"]
    XCTAssertTrue(examples.waitForExistence(timeout: 5))
    examples.click()
    assertReady("design-os.gallery.examples.ready", in: app)
    return app
  }

  @MainActor
  private func open(_ cardID: String, expecting entryID: String, in app: XCUIApplication) {
    scrollUntilHittable(cardID, in: app).click()
    assertReady(entryID, in: app)
  }

  @MainActor
  private func scrollUntilHittable(_ identifier: String, in app: XCUIApplication) -> XCUIElement {
    let scrollView =
      identifier.hasPrefix("design-os.gallery.demo.")
      ? element("design-os.gallery.examples.ready", in: app)
      : app.scrollViews.firstMatch
    for _ in 0..<12 {
      let target = element(identifier, in: app)
      if target.exists && target.isHittable { return target }
      scrollView.swipeUp()
    }
    let target = element(identifier, in: app)
    XCTAssertTrue(target.exists && target.isHittable)
    return target
  }

  @MainActor
  private func scrollUntilVisibleState(_ target: XCUIElement, in app: XCUIApplication) {
    XCTAssertTrue(target.waitForExistence(timeout: 5))
    let initialMinY = target.frame.minY
    let scrollView = element("design-os.demo.entertainment.streaming-library.page", in: app)
    scrollView.swipeUp()
    let windowFrame = app.windows.firstMatch.frame
    for _ in 0..<5 where !target.frame.intersects(windowFrame) { scrollView.swipeUp() }
    XCTAssertLessThan(target.frame.minY, initialMinY)
    XCTAssertTrue(target.frame.intersects(windowFrame))
  }

  @MainActor
  private func assertReady(_ identifier: String, in app: XCUIApplication) {
    XCTAssertTrue(element(identifier, in: app).waitForExistence(timeout: 5))
  }

  @MainActor
  private func element(_ identifier: String, in app: XCUIApplication) -> XCUIElement {
    app.descendants(matching: .any)[identifier]
  }

  @MainActor
  private func nativeBack(in app: XCUIApplication) -> XCUIElement {
    let button = app.buttons["chevron.backward"]
    XCTAssertTrue(button.waitForExistence(timeout: 5))
    return button
  }

  @MainActor
  private func capture(_ name: String, app: XCUIApplication) {
    let attachment = XCTAttachment(screenshot: app.screenshot())
    attachment.name = name
    attachment.lifetime = .keepAlways
    add(attachment)
  }
}

private struct MacMiniAppFlow {
  let cardID: String
  let entryID: String
  let transitionID: String?
  let detailID: String
  var preparationID: String?
  var usesScrollTransition = false

  static let all: [Self] = [
    .init(
      cardID: "design-os.gallery.demo.assistant.thoughtful-chat",
      entryID: "design-os.demo.assistant.thoughtful-chat.new-conversation",
      transitionID: "design-os.demo.assistant.thoughtful-chat.transition.working-thread",
      detailID: "design-os.demo.assistant.thoughtful-chat.working-thread"),
    .init(
      cardID: "design-os.gallery.demo.assistant.visual",
      entryID: "design-os.demo.assistant.visual.prompt-home",
      transitionID: "design-os.demo.assistant.visual.transition.answer-canvas",
      detailID: "design-os.demo.assistant.visual.answer-canvas"),
    .init(
      cardID: "design-os.gallery.demo.mobility.flight-tracker",
      entryID: "design-os.demo.mobility.flight-tracker.board",
      transitionID: "design-os.demo.mobility.flight-tracker.open-live",
      detailID: "design-os.demo.mobility.flight-tracker.live"),
    .init(
      cardID: "design-os.gallery.demo.mobility.city-ride",
      entryID: "design-os.demo.mobility.city-ride.selection",
      transitionID: "design-os.demo.mobility.city-ride.open-tracking",
      detailID: "design-os.demo.mobility.city-ride.tracking",
      preparationID: "design-os.demo.mobility.city-ride.option.eco"),
    .init(
      cardID: "design-os.gallery.demo.entertainment.streaming-library",
      entryID: "design-os.demo.entertainment.streaming-library.highlighted-hero",
      transitionID: nil,
      detailID: "design-os.demo.entertainment.streaming-library.scrolled-library",
      usesScrollTransition: true),
    .init(
      cardID: "design-os.gallery.demo.entertainment.song-finder",
      entryID: "design-os.demo.entertainment.song-finder.listening",
      transitionID: "design-os.demo.entertainment.song-finder.open-result",
      detailID: "design-os.demo.entertainment.song-finder.result"),
  ]
}
