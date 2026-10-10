import XCTest

@MainActor
final class LayeredKitPreviewUITests: XCTestCase {
    private let implementedScreens = [
        "flat-collection", "media-detail", "media-composer", "grouped-form", "focused-task",
        "onboarding", "discovery", "profile-detail", "hero-collection", "freeform-editor",
        "search-selection", "confirmation", "status", "message-thread", "utility-canvas",
        "provider-host", "record-detail", "native-presentation"
    ]

    private func launch(_ specimen: String) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchEnvironment["LAYERED_KIT_SPECIMEN"] = specimen
        app.launch()
        return app
    }

    private func capture(_ name: String, app: XCUIApplication) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    private func setAppearance(_ appearance: String, in app: XCUIApplication) -> Bool {
        let options = app.buttons["previewOptions"].firstMatch
        guard options.waitForExistence(timeout: 5) else { XCTFail("Missing native preview options"); return false }
        options.tap()
        let picker = app.segmentedControls["previewAppearance"].firstMatch
        let option = picker.buttons[appearance]
        guard option.waitForExistence(timeout: 5) else { XCTFail("Missing appearance choice \(appearance)"); return false }
        option.tap()
        let done = app.buttons["closePreviewOptions"].firstMatch
        guard done.waitForExistence(timeout: 5) else { XCTFail("Missing options completion"); return false }
        done.tap()
        return true
    }

    func testEighteenScreenTypesInLightAndDark() {
        for specimen in implementedScreens {
            let app = launch(specimen)
            defer { app.terminate() }
            for appearance in ["Light", "Dark"] {
                guard setAppearance(appearance, in: app) else { return }
                let surface = app.descendants(matching: .any)["specimen-\(specimen)"].firstMatch
                guard surface.waitForExistence(timeout: 5) else { XCTFail("Missing real specimen \(specimen)"); return }
                XCTAssertFalse(app.descendants(matching: .any)["pendingSpecimen"].exists)
                if ["media-detail", "media-composer"].contains(specimen) {
                    guard app.images["fixtureMedia"].waitForExistence(timeout: 5) else {
                        XCTFail("Media specimen must load original bundled imagery"); return
                    }
                }
                let expected = contentWitness(for: specimen, in: app)
                guard expected.waitForExistence(timeout: 5) else {
                    capture("failure-\(specimen)-missing-content", app: app)
                    XCTFail("Real content missing for \(specimen)"); return
                }
                capture("screen-\(specimen)-\(appearance.lowercased())", app: app)
            }
        }
    }

    private func contentWitness(for specimen: String, in app: XCUIApplication) -> XCUIElement {
        switch specimen {
        case "flat-collection": app.staticTexts["Community lunch"].firstMatch
        case "media-detail": app.staticTexts["Community lunch"].firstMatch
        case "media-composer", "grouped-form", "focused-task": app.textFields["fixtureTitle"].firstMatch
        case "onboarding": app.staticTexts["Welcome to your neighborhood"].firstMatch
        case "discovery": app.staticTexts["Find your next gathering"].firstMatch
        case "profile-detail": app.staticTexts["Neighborhood studio"].firstMatch
        case "hero-collection": app.staticTexts["Good food, good company"].firstMatch
        case "freeform-editor": app.textViews["Gathering description"].firstMatch
        case "search-selection": app.staticTexts["Gathering 1"].firstMatch
        case "confirmation": app.staticTexts["Clear the local draft?"].firstMatch
        case "status": app.staticTexts["Preview status"].firstMatch
        case "message-thread": app.descendants(matching: .any)["messageDraft"].firstMatch
        case "utility-canvas": app.sliders["photoZoom"].firstMatch
        case "provider-host": app.buttons["Open native share options"].firstMatch
        case "record-detail": app.staticTexts["Fixture receipt"].firstMatch
        default: app.buttons["showNativeAlert"].firstMatch
        }
    }

    func testNativeSelectionAndPresentation() {
        let app = launch("search-selection")
        let choice = app.staticTexts["Gathering 2"].firstMatch
        guard choice.waitForExistence(timeout: 5) else { XCTFail("Missing selectable row"); return }
        choice.tap()
        XCTAssertTrue(app.staticTexts["Selected gathering 2"].waitForExistence(timeout: 5))
        capture("search-selection-selected", app: app)
        app.terminate()
        app.launchEnvironment["LAYERED_KIT_SPECIMEN"] = "native-presentation"
        app.launch()
        let show = app.buttons["showNativeAlert"].firstMatch
        guard show.waitForExistence(timeout: 5) else { XCTFail("Missing native alert anchor"); return }
        show.tap()
        let message = app.staticTexts["This is a real system alert, presented by the host."].firstMatch
        let close = app.buttons["Close"].firstMatch
        guard message.waitForExistence(timeout: 5), close.waitForExistence(timeout: 5) else {
            XCTFail("The native alert's message and dismissal action must appear"); return
        }
        capture("native-presentation-alert", app: app)
        close.tap()
        XCTAssertTrue(show.waitForExistence(timeout: 5))
    }

    func testReusableLayerSpecimens() {
        for (route, witness) in [("foundations", "Editorial foundations"), ("composites", "Editable facts"), ("shells", "Native List row")] {
            let app = launch(route)
            guard app.staticTexts[witness].waitForExistence(timeout: 5) else {
                XCTFail("Missing actual layer specimen \(route)"); return
            }
            capture("layer-\(route)", app: app)
            app.terminate()
        }
    }

    func testNativeFieldAndActionBelongToHost() {
        let app = launch("focused-task")
        let field = app.textFields["fixtureTitle"].firstMatch
        guard field.waitForExistence(timeout: 5) else { XCTFail("Missing native text field"); return }
        field.tap()
        field.typeText(" fixture")
        XCTAssertTrue((field.value as? String)?.contains("fixture") == true)
        capture("focused-task-keyboard", app: app)
        #if os(iOS)
        let done = app.buttons["finishFixtureEditing"].firstMatch
        guard done.waitForExistence(timeout: 5) else { XCTFail("Missing native keyboard Done"); return }
        done.tap()
        #else
        field.typeText("\n")
        #endif
        let save = app.buttons["fixtureSave"].firstMatch
        guard save.waitForExistence(timeout: 5), save.isHittable else { XCTFail("Task action must be reachable"); return }
        save.tap()
        XCTAssertTrue(app.staticTexts["Fixture saved"].waitForExistence(timeout: 5))
        capture("focused-task-saved", app: app)
    }

    func testCollectionEmptyErrorAndBusyStates() {
        let app = launch("flat-collection")
        for (state, expected) in [("Empty", "Nothing here yet"), ("Error", "Fixture error: check the gathering name."), ("Busy", "Fixture loading state")] {
            let options = app.buttons["previewOptions"].firstMatch
            guard options.waitForExistence(timeout: 5) else { XCTFail("Missing options"); return }
            options.tap()
            let choice = app.segmentedControls["previewState"].buttons[state]
            guard choice.waitForExistence(timeout: 5) else { XCTFail("Missing state choice"); return }
            choice.tap()
            app.buttons["closePreviewOptions"].firstMatch.tap()
            guard app.descendants(matching: .any).matching(NSPredicate(format: "label == %@", expected)).firstMatch.waitForExistence(timeout: 5) else {
                XCTFail("Expected actual rendered \(state) content"); return
            }
            capture("flat-collection-\(state.lowercased())", app: app)
        }
    }

    func testAccessibleLayoutAndStateControls() {
        let app = launch("media-composer")
        let options = app.buttons["previewOptions"].firstMatch
        guard options.waitForExistence(timeout: 5) else { XCTFail("Missing options"); return }
        options.tap()
        let largeType = app.descendants(matching: .any)["previewLargeText"].firstMatch
        guard largeType.waitForExistence(timeout: 5) else { XCTFail("Missing real layout control"); return }
        largeType.tap()
        app.buttons["closePreviewOptions"].firstMatch.tap()
        guard app.textFields["fixtureTitle"].waitForExistence(timeout: 5) else { XCTFail("Fields must survive text reflow"); return }
        capture("media-composer-accessibility-text", app: app)
    }
}
