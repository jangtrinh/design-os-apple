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

    private func nativeChoice(_ label: String, picker identifier: String, in app: XCUIApplication) -> XCUIElement {
        // AppKit exposes native segmented pickers as RadioGroup/RadioButton;
        // UIKit exposes SegmentedControl/Button. Preserve each platform's control.
        app.descendants(matching: .any).matching(identifier: identifier).firstMatch
            .descendants(matching: .any).matching(NSPredicate(format: "label == %@", label)).firstMatch
    }

    private func diagnose(_ name: String, app: XCUIApplication) {
        capture(name, app: app)
        let attachment = XCTAttachment(string: app.debugDescription)
        attachment.name = name + "-accessibility"
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    private func setAppearance(_ appearance: String, in app: XCUIApplication) -> Bool {
        let options = app.buttons["previewOptions"].firstMatch
        guard options.waitForExistence(timeout: 5) else { diagnose("failure-preview-options", app: app); XCTFail("Missing native preview options"); return false }
        options.tap()
        let option = nativeChoice(appearance, picker: "previewAppearance", in: app)
        guard option.waitForExistence(timeout: 5) else { diagnose("failure-appearance-choice", app: app); XCTFail("Missing appearance choice \(appearance)"); return false }
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
                let title = specimen.replacingOccurrences(of: "-", with: " ").capitalized
                #if os(iOS)
                let route = app.navigationBars[title]
                #else
                let route = app.windows[title]
                #endif
                guard route.waitForExistence(timeout: 5) else {
                    diagnose("failure-\(specimen)-navigation", app: app)
                    XCTFail("Native navigation must show the requested specimen"); return
                }
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
        let clear = app.buttons["clearFixtureSelection"].firstMatch
        guard clear.waitForExistence(timeout: 5), clear.isEnabled else { XCTFail("Selection action must be enabled"); return }
        clear.tap()
        XCTAssertTrue(app.staticTexts["Select a gathering"].waitForExistence(timeout: 5))
        XCTAssertFalse(clear.isEnabled)
        app.terminate()
        app.launchEnvironment["LAYERED_KIT_SPECIMEN"] = "native-presentation"
        app.launch()
        let show = app.buttons["showNativeAlert"].firstMatch
        guard show.waitForExistence(timeout: 5) else { diagnose("failure-alert-anchor", app: app); XCTFail("Missing native alert anchor"); return }
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

    func testCompositeContentAndNativeActions() {
        let witnesses = [
            ("onboarding", "choiceTips"), ("discovery", "category-food"),
            ("media-detail", "detailHeaderMetadata"), ("media-composer", "composerMediaAction"),
            ("search-selection", "clearFixtureSelection"), ("message-thread", "addLocalMessage"),
            ("record-detail", "recordSampleStatus"), ("utility-canvas", "resetPhotoZoom")
        ]
        for (route, identifier) in witnesses {
            let app = launch(route)
            let content = app.descendants(matching: .any)[identifier].firstMatch
            guard content.waitForExistence(timeout: 5) else {
                XCTFail("Composite content missing for \(route)"); return
            }
            if route == "message-thread" {
                guard app.staticTexts["Original local fixture"].waitForExistence(timeout: 5),
                      app.staticTexts["Added locally"].exists else {
                    XCTFail("Incoming/outgoing bubbles must expose actual local metadata"); return
                }
            }
            if route == "discovery" {
                app.buttons["category-art"].tap()
                XCTAssertEqual(app.staticTexts["selectedCategory"].label, "Art")
            }
            capture("composite-\(route)", app: app)
            app.terminate()
        }
    }

    func testNativeBackRetainsPreviewOptions() {
        let app = launch("flat-collection")
        guard setAppearance("Light", in: app) else { return }
        #if os(iOS)
        let back = app.buttons["BackButton"].firstMatch
        let directoryRoute = app.descendants(matching: .any)["route-flat-collection"].firstMatch
        if !(directoryRoute.exists && directoryRoute.isHittable) {
            guard back.exists && back.isHittable else {
                diagnose("failure-native-back-control", app: app)
                XCTFail("Compact detail requires a reachable native Back action"); return
            }
            back.tap()
            guard app.navigationBars["Native kit"].waitForExistence(timeout: 5) else {
                diagnose("failure-native-back", app: app)
                XCTFail("Back must return to the native specimen directory"); return
            }
            guard setAppearance("Dark", in: app) else { return }
            capture("navigation-directory-options-after-back", app: app)
            let row = app.descendants(matching: .any)["route-flat-collection"].firstMatch
            guard row.waitForExistence(timeout: 5), row.isHittable else {
                XCTFail("Native directory route must remain selectable"); return
            }
            row.tap()
            XCTAssertTrue(app.navigationBars["Flat Collection"].waitForExistence(timeout: 5))
        }
        #endif
        guard setAppearance("System", in: app) else { return }
        XCTAssertTrue(app.staticTexts["Community lunch"].waitForExistence(timeout: 5))
        capture("navigation-detail-options", app: app)
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
        guard save.waitForExistence(timeout: 5), save.isHittable else { diagnose("failure-task-action", app: app); XCTFail("Task action must be reachable"); return }
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
            let choice = nativeChoice(state, picker: "previewState", in: app)
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
