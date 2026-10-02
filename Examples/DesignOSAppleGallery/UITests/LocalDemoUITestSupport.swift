import XCTest

extension DesignOSAppleGalleryLocalDemoUITests {
  @MainActor
  func launchMiniApps(appearance: String? = nil) -> XCUIApplication {
    XCUIDevice.shared.orientation = .portrait
    let app = XCUIApplication()
    app.launchEnvironment["UIPreferredContentSizeCategoryName"] = "UICTContentSizeCategoryL"
    if let appearance {
      app.launchArguments += ["-AppleInterfaceStyle", appearance]
    }
    app.launch()
    if !app.buttons["Examples"].exists { app.navigationBars.buttons.firstMatch.tap() }
    app.buttons["Examples"].tap()
    let dismissRegion = app.otherElements["PopoverDismissRegion"]
    if dismissRegion.exists {
      dismissRegion.tap()
      XCTAssertTrue(dismissRegion.waitForNonExistence(timeout: galleryUITestTimeout))
    }
    assertReady("design-os.gallery.examples.ready", in: app)
    return app
  }

  @MainActor
  func open(_ cardID: String, expecting entryID: String, in app: XCUIApplication) {
    tapWhenHittable(element(cardID, in: app), in: app)
    assertReady(entryID, in: app)
  }

  @MainActor
  func nativeBack(in app: XCUIApplication) -> XCUIElement {
    let button = app.navigationBars.buttons.firstMatch
    XCTAssertTrue(button.waitForExistence(timeout: galleryUITestTimeout))
    return button
  }

  @MainActor
  func tapWhenHittable(_ target: XCUIElement, in app: XCUIApplication) {
    scrollUntilHittable(target, in: app)
    target.tap()
  }

  @MainActor
  func reachSecondState(for flow: MiniAppFlow, in app: XCUIApplication) {
    let target = element(flow.detailID, in: app)
    if flow.usesScrollTransition {
      scrollUntilVisibleState(target, in: app)
    } else if let transitionID = flow.transitionID {
      tapWhenHittable(element(transitionID, in: app), in: app)
      assertReady(flow.detailID, in: app)
    }
  }

  @MainActor
  func scrollUntilHittable(_ target: XCUIElement, in app: XCUIApplication) {
    XCTAssertTrue(target.waitForExistence(timeout: galleryUITestTimeout))
    let scrollView = app.scrollViews.firstMatch
    for _ in 0..<16 where !target.isHittable { scrollView.swipeUp(velocity: .slow) }
    XCTAssertTrue(target.isHittable)
  }

  @MainActor
  func scrollUntilVisibleState(_ target: XCUIElement, in app: XCUIApplication) {
    XCTAssertTrue(target.waitForExistence(timeout: galleryUITestTimeout))
    let initialMinY = target.frame.minY
    app.scrollViews.firstMatch.swipeUp(velocity: .slow)
    XCTAssertLessThan(target.frame.minY, initialMinY)
    XCTAssertTrue(target.frame.intersects(app.frame))
  }

  @MainActor
  func assertReady(_ identifier: String, in app: XCUIApplication) {
    XCTAssertTrue(element(identifier, in: app).waitForExistence(timeout: galleryUITestTimeout))
  }

  @MainActor
  func element(_ identifier: String, in app: XCUIApplication) -> XCUIElement {
    app.descendants(matching: .any)[identifier]
  }

  @MainActor
  func capture(_ name: String, app: XCUIApplication) {
    let attachment = XCTAttachment(screenshot: app.screenshot())
    attachment.name = name
    attachment.lifetime = .keepAlways
    add(attachment)
  }
}

struct MiniAppFlow {
  let slug: String
  let cardID: String
  let entryID: String
  let transitionID: String?
  let detailID: String
  var preparationID: String?
  var usesScrollTransition = false

  static let all: [Self] = [
    .init(
      slug: "thoughtful-chat", cardID: "design-os.gallery.demo.assistant.thoughtful-chat",
      entryID: "design-os.demo.assistant.thoughtful-chat.new-conversation",
      transitionID: "design-os.demo.assistant.thoughtful-chat.transition.working-thread",
      detailID: "design-os.demo.assistant.thoughtful-chat.working-thread"),
    .init(
      slug: "visual-assistant", cardID: "design-os.gallery.demo.assistant.visual",
      entryID: "design-os.demo.assistant.visual.prompt-home",
      transitionID: "design-os.demo.assistant.visual.transition.answer-canvas",
      detailID: "design-os.demo.assistant.visual.answer-canvas"),
    .init(
      slug: "flight-tracker", cardID: "design-os.gallery.demo.mobility.flight-tracker",
      entryID: "design-os.demo.mobility.flight-tracker.board",
      transitionID: "design-os.demo.mobility.flight-tracker.open-live",
      detailID: "design-os.demo.mobility.flight-tracker.live"),
    .init(
      slug: "city-ride", cardID: "design-os.gallery.demo.mobility.city-ride",
      entryID: "design-os.demo.mobility.city-ride.selection",
      transitionID: "design-os.demo.mobility.city-ride.open-tracking",
      detailID: "design-os.demo.mobility.city-ride.tracking",
      preparationID: "design-os.demo.mobility.city-ride.option.eco"),
    .init(
      slug: "streaming-library", cardID: "design-os.gallery.demo.entertainment.streaming-library",
      entryID: "design-os.demo.entertainment.streaming-library.highlighted-hero",
      transitionID: nil,
      detailID: "design-os.demo.entertainment.streaming-library.scrolled-library",
      usesScrollTransition: true),
    .init(
      slug: "song-finder", cardID: "design-os.gallery.demo.entertainment.song-finder",
      entryID: "design-os.demo.entertainment.song-finder.listening",
      transitionID: "design-os.demo.entertainment.song-finder.open-result",
      detailID: "design-os.demo.entertainment.song-finder.result"),
  ]
}
