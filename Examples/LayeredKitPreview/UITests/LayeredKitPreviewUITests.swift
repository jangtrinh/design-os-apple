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

    private func openOptions(in app: XCUIApplication) -> Bool {
        let options = app.buttons["previewOptions"].firstMatch
        // Bound native observations rather than assuming AX queries finish in milliseconds.
        let started = Date()
        var previousFrame: CGRect?
        var stableSamples = 0
        var ready = false
        var samples: [String] = []
        var outcome = "Six observations did not establish three consecutive stable frames"
        defer {
            let attachment = XCTAttachment(string: samples.joined(separator: "\n") + "\nOutcome: " + outcome)
            attachment.name = "preview-options-readiness-samples"
            attachment.lifetime = .keepAlways
            add(attachment)
        }
        for observation in 1...6 {
            let sampleStarted = Date().timeIntervalSince(started)
            do {
                let target = try options.snapshot()
                let window = try app.windows.firstMatch.snapshot()
                let frame = target.frame
                let enabled = target.isEnabled
                let hittable = options.isHittable
                let contained = !frame.isEmpty && !frame.isNull && !frame.isInfinite && window.frame.contains(frame)
                let unchanged = previousFrame == frame
                samples.append("sample=\(observation) start=\(sampleStarted)s end=\(Date().timeIntervalSince(started))s exists=true enabled=\(enabled) hittable=\(hittable) contained=\(contained) unchanged=\(unchanged) frame=\(frame) window=\(window.frame)")
                if enabled && hittable && contained {
                    stableSamples = unchanged ? stableSamples + 1 : 1
                    previousFrame = frame
                    if stableSamples >= 3 {
                        ready = true
                        outcome = "Ready: three consecutive stable enabled, hittable, contained observations"
                        break
                    }
                } else {
                    stableSamples = 0
                    previousFrame = nil
                }
            } catch {
                outcome = "Native snapshot failed: \(error.localizedDescription)"
                samples.append("sample=\(observation) start=\(sampleStarted)s end=\(Date().timeIntervalSince(started))s \(outcome)")
                diagnose("failure-preview-options-snapshot", app: app)
                XCTFail(outcome)
                return false
            }
        }
        guard ready else {
            diagnose("failure-preview-options-readiness", app: app)
            XCTFail("Preview options must be enabled, hittable and settled inside the actual window"); return false
        }
        // One native tap only. A failed presentation remains a failure, never a retry.
        options.tap()
        let done = app.buttons["closePreviewOptions"].firstMatch
        let presentationDeadline = Date().addingTimeInterval(5)
        while !(done.exists && done.isHittable) && Date() < presentationDeadline {
            RunLoop.current.run(until: Date().addingTimeInterval(0.1))
        }
        guard done.exists && done.isHittable else {
            diagnose("failure-preview-options-presentation", app: app)
            XCTFail("One native options tap must present the options sheet before querying its controls"); return false
        }
        return true
    }

    private func setAppearance(_ appearance: String, in app: XCUIApplication) -> Bool {
        guard openOptions(in: app) else { return false }
        let option = nativeChoice(appearance, picker: "previewAppearance", in: app)
        guard option.waitForExistence(timeout: 5) else { diagnose("failure-appearance-choice", app: app); XCTFail("Missing appearance choice \(appearance)"); return false }
        option.tap()
        let done = app.buttons["closePreviewOptions"].firstMatch
        guard done.waitForExistence(timeout: 5) else { XCTFail("Missing options completion"); return false }
        done.tap()
        return true
    }

    func testEighteenScreenTypesInLightAndDark() {
        continueAfterFailure = true
        for specimen in implementedScreens {
            for appearance in ["Light", "Dark"] {
                XCTContext.runActivity(named: "\(specimen) / \(appearance)") { _ in
                    verifyScreenScenario(specimen, appearance: appearance)
                }
            }
        }
    }

    private func verifyScreenScenario(_ specimen: String, appearance: String) {
        // A fresh process isolates each scenario, including a failed options presentation.
        // Returning from this helper records that failure without hiding later scenarios.
        let failuresBeforeScenario = testRun?.totalFailureCount ?? 0
        let app = launch(specimen)
        defer { app.terminate() }
        let evidenceName = "\(specimen)-\(appearance.lowercased())"
        guard setAppearance(appearance, in: app) else {
            diagnose("failure-\(evidenceName)-appearance", app: app)
            return
        }
        let title = specimen.replacingOccurrences(of: "-", with: " ").capitalized
        #if os(iOS)
        let route = app.navigationBars[title]
        #else
        let route = app.windows[title]
        #endif
        guard route.waitForExistence(timeout: 5) else {
            diagnose("failure-\(evidenceName)-navigation", app: app)
            XCTFail("Native navigation must show the requested specimen"); return
        }
        guard !app.descendants(matching: .any)["pendingSpecimen"].exists else {
            diagnose("failure-\(evidenceName)-pending", app: app)
            XCTFail("A planned placeholder cannot count as a rendered specimen"); return
        }
        if ["media-detail", "media-composer"].contains(specimen) {
            guard app.images["fixtureMedia"].waitForExistence(timeout: 5) else {
                diagnose("failure-\(evidenceName)-media", app: app)
                XCTFail("Media specimen must load original bundled imagery"); return
            }
        }
        let expected = contentWitness(for: specimen, in: app)
        guard expected.waitForExistence(timeout: 5) else {
            diagnose("failure-\(evidenceName)-missing-content", app: app)
            XCTFail("Real content missing for \(specimen)"); return
        }
        guard waitForVisibleNavigationTitle(title, in: app) else {
            diagnose("failure-\(evidenceName)-title-visibility", app: app)
            XCTFail("Native title must be visible, settled and clear of toolbar controls before capture"); return
        }
        guard (testRun?.totalFailureCount ?? 0) == failuresBeforeScenario else {
            diagnose("failure-\(evidenceName)-recorded-issue", app: app)
            return
        }
        capture("screen-\(evidenceName)", app: app)
    }

    private func waitForVisibleNavigationTitle(_ title: String, in app: XCUIApplication) -> Bool {
        #if os(iOS)
        let bar = app.navigationBars[title]
        let label = bar.staticTexts.matching(NSPredicate(format: "label == %@ OR value == %@", title, title)).firstMatch
        // One AX observation took ~11 seconds; another attempt completed only two
        // across ~6 seconds. Count observations instead of budgeting synchronous AX cost.
        let started = Date()
        var previousFrame: CGRect?
        var stableSamples = 0
        var samples: [String] = []
        var outcome = "Six observations did not establish three consecutive stable frames"
        defer {
            let attachment = XCTAttachment(string: samples.joined(separator: "\n") + "\nOutcome: " + outcome)
            attachment.name = "navigation-title-readiness-" + title
            attachment.lifetime = .keepAlways
            add(attachment)
        }
        for observation in 1...6 {
            let sampleStarted = Date().timeIntervalSince(started)
            do {
                let barSnapshot = try bar.snapshot()
                let labelSnapshot = try label.snapshot()
                let windowSnapshot = try app.windows.firstMatch.snapshot()
                let frame = labelSnapshot.frame
                let viewport = barSnapshot.frame.intersection(windowSnapshot.frame)
                var overlapsControl = false
                var controlFrames: [CGRect] = []
                for button in bar.buttons.allElementsBoundByIndex {
                    let buttonSnapshot = try button.snapshot()
                    controlFrames.append(buttonSnapshot.frame)
                    // Only an intersecting control needs the separate native hit query.
                    if buttonSnapshot.frame.intersects(frame) && button.isHittable {
                        overlapsControl = true
                    }
                }
                let hittable = label.isHittable
                let contained = !frame.isEmpty && !frame.isNull && !frame.isInfinite && viewport.contains(frame)
                let unchanged = previousFrame == frame
                samples.append("sample=\(observation) start=\(sampleStarted)s end=\(Date().timeIntervalSince(started))s exists=true hittable=\(hittable) contained=\(contained) overlapsControl=\(overlapsControl) unchanged=\(unchanged) titleFrame=\(frame) viewport=\(viewport) controlFrames=\(controlFrames)")
                if contained && hittable && !overlapsControl {
                    stableSamples = unchanged ? stableSamples + 1 : 1
                    previousFrame = frame
                    if stableSamples >= 3 {
                        outcome = "Ready: three stable visible native title observations, clear of hittable controls"
                        return true
                    }
                    outcome = "Only \(stableSamples) stable observations completed within six observations"
                } else {
                    stableSamples = 0
                    previousFrame = nil
                    outcome = "Not ready: hittable=\(hittable), contained=\(contained), overlapsControl=\(overlapsControl)"
                }
            } catch {
                stableSamples = 0
                previousFrame = nil
                outcome = "Native snapshot unavailable: \(error.localizedDescription)"
                samples.append("sample=\(observation) start=\(sampleStarted)s end=\(Date().timeIntervalSince(started))s \(outcome)")
                return false
            }
        }
        return false
        #else
        return app.windows[title].exists
        #endif
    }

    private func renderedText(_ expected: String, in app: XCUIApplication) -> XCUIElement {
        // Native AppKit text can expose its exact string through value or label.
        // Identifier subscripting does not consistently match heading labels.
        app.descendants(matching: .any).matching(
            NSPredicate(format: "label == %@ OR value == %@", expected, expected)
        ).firstMatch
    }

    private func contentWitness(for specimen: String, in app: XCUIApplication) -> XCUIElement {
        switch specimen {
        case "flat-collection": renderedText("Community lunch", in: app)
        case "media-detail": renderedText("Community lunch", in: app)
        case "media-composer", "grouped-form", "focused-task": app.textFields["fixtureTitle"].firstMatch
        case "onboarding": renderedText("Welcome to your neighborhood", in: app)
        case "discovery": renderedText("Find your next gathering", in: app)
        case "profile-detail": renderedText("Neighborhood studio", in: app)
        case "hero-collection": renderedText("Good food, good company", in: app)
        case "freeform-editor": app.textViews["Gathering description"].firstMatch
        case "search-selection": renderedText("Gathering 1", in: app)
        case "confirmation": renderedText("Clear the local draft?", in: app)
        case "status": renderedText("Preview status", in: app)
        case "message-thread": app.descendants(matching: .any)["messageDraft"].firstMatch
        case "utility-canvas": app.sliders["photoZoom"].firstMatch
        case "provider-host": app.buttons["Open native share options"].firstMatch
        case "record-detail": renderedText("Fixture receipt", in: app)
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
            if route == "media-composer" {
                let cover = app.images["fixtureMedia"].firstMatch
                XCTAssertTrue(cover.waitForExistence(timeout: 5))
                XCTAssertGreaterThan(cover.frame.width, 0)
                XCTAssertEqual(cover.frame.width, cover.frame.height, accuracy: 1,
                               "The original composer must use the same square cover geometry as its isolated component")
                let edit = app.buttons["composerMediaAction"].firstMatch
                XCTAssertTrue(edit.isHittable)
                XCTAssertEqual(edit.value as? String, "Original colors")
                edit.tap()
                let changed = XCTNSPredicateExpectation(
                    predicate: NSPredicate(format: "value == %@", "Alternate colors"), object: edit)
                XCTAssertEqual(XCTWaiter.wait(for: [changed], timeout: 5), .completed)
                XCTAssertTrue(cover.exists, "Editing sample colors must retain the original local image")
                edit.tap()
                let restored = XCTNSPredicateExpectation(
                    predicate: NSPredicate(format: "value == %@", "Original colors"), object: edit)
                XCTAssertEqual(XCTWaiter.wait(for: [restored], timeout: 5), .completed)
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
            guard openOptions(in: app) else { return }
            let choice = nativeChoice(state, picker: "previewState", in: app)
            guard choice.waitForExistence(timeout: 5) else { XCTFail("Missing state choice"); return }
            choice.tap()
            app.buttons["closePreviewOptions"].firstMatch.tap()
            guard renderedText(expected, in: app).waitForExistence(timeout: 5) else {
                diagnose("failure-collection-\(state.lowercased())", app: app)
                XCTFail("Expected exact rendered \(state) content: \(expected)"); return
            }
            capture("flat-collection-\(state.lowercased())", app: app)
        }
    }

    private func visibleMediaGeometry(in app: XCUIApplication) -> (media: CGRect, title: CGRect)? {
        let media = app.images["foundationMedia"].firstMatch
        let title = app.staticTexts["foundationMediaTitle"].firstMatch
        guard media.waitForExistence(timeout: 5), title.waitForExistence(timeout: 5) else { return nil }
        let scroll = app.scrollViews.containing(.image, identifier: "foundationMedia").firstMatch
        guard scroll.exists else { return nil }
        for _ in 0..<6 {
            var viewport = scroll.frame.intersection(app.windows.firstMatch.frame)
            #if os(iOS)
            let navigation = app.navigationBars["Foundations"]
            if navigation.exists {
                let top = max(viewport.minY, navigation.frame.maxY)
                viewport = CGRect(x: viewport.minX, y: top, width: viewport.width, height: max(0, viewport.maxY - top))
            }
            #endif
            let action = app.buttons["fixtureSave"].firstMatch
            if action.exists && action.frame.minY > viewport.minY {
                viewport.size.height = max(0, min(viewport.maxY, action.frame.minY) - viewport.minY)
            }
            let imageFrame = media.frame
            let titleFrame = title.frame
            if !imageFrame.isEmpty && !titleFrame.isEmpty && viewport.contains(imageFrame) && viewport.contains(titleFrame) {
                return (imageFrame, titleFrame)
            }
            #if os(macOS)
            scroll.scroll(byDeltaX: 0, deltaY: imageFrame.minY < viewport.minY ? 180 : -180)
            #else
            guard !viewport.isEmpty && !viewport.isNull else { return nil }
            let towardTop = imageFrame.minY < viewport.minY
            let needed = towardTop ? viewport.minY - imageFrame.minY : max(imageFrame.maxY, titleFrame.maxY) - viewport.maxY
            let distance = min(max(needed + 16, 40), viewport.height * 0.45)
            let startY = viewport.minY + viewport.height * (towardTop ? 0.25 : 0.75)
            let endY = startY + (towardTop ? distance : -distance)
            let origin = scroll.coordinate(withNormalizedOffset: .zero)
            let start = origin.withOffset(CGVector(dx: viewport.midX - scroll.frame.minX, dy: startY - scroll.frame.minY))
            let end = origin.withOffset(CGVector(dx: viewport.midX - scroll.frame.minX, dy: endY - scroll.frame.minY))
            start.press(forDuration: 0.05, thenDragTo: end)
            #endif
        }
        return nil
    }

    private func exactToggleState(_ raw: Any?) -> Bool? {
        if let text = raw as? String {
            switch text {
            case "0": return false
            case "1": return true
            default: return nil
            }
        }
        if let number = raw as? NSNumber, number.doubleValue.isFinite {
            if number.compare(NSNumber(value: 0)) == .orderedSame { return false }
            if number.compare(NSNumber(value: 1)) == .orderedSame { return true }
        }
        return nil
    }

    private func recordToggleState(_ stage: String, control: XCUIElement, raw: Any?,
                                   exists: Bool, enabled: Bool, hittable: Bool) {
        let rawType = raw.map { String(reflecting: type(of: $0)) } ?? "nil"
        let numberType = (raw as? NSNumber).map { String(cString: $0.objCType) } ?? "not NSNumber"
        let attachment = XCTAttachment(string:
            "exists=\(exists), enabled=\(enabled), hittable=\(hittable), frame=\(exists ? String(describing: control.frame) : "unavailable")\n"
            + "rawType=\(rawType), rawValue=\(String(reflecting: raw)), numberType=\(numberType), exactState=\(String(describing: exactToggleState(raw)))")
        attachment.name = "accessibility-toggle-" + stage
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    func testExactToggleScalarContract() {
        for raw in ["0", NSNumber(value: 0), NSNumber(value: false)] as [Any] {
            XCTAssertEqual(exactToggleState(raw), false)
        }
        for raw in ["1", NSNumber(value: 1), NSNumber(value: true)] as [Any] {
            XCTAssertEqual(exactToggleState(raw), true)
        }
        for raw in ["", "false", "true", "01", "0.0", " 1", NSNumber(value: 2),
                         NSNumber(value: -1), NSNumber(value: 0.5), NSNumber(value: Double.nan),
                         NSNumber(value: Double.infinity), [0]] as [Any] {
            XCTAssertNil(exactToggleState(raw))
        }
        XCTAssertNil(exactToggleState(nil))
    }

    func testAccessibleLayoutAndStateControls() {
        let app = launch("foundations")
        guard let before = visibleMediaGeometry(in: app), before.title.minX >= before.media.maxX else {
            diagnose("failure-accessibility-baseline", app: app)
            XCTFail("Normal-size media and title must be visibly arranged horizontally"); return
        }
        capture("foundations-normal-text", app: app)
        guard openOptions(in: app) else { return }
        // Current AppKit and UIKit both expose this Toggle as a Switch. Accept
        // AppKit's alternate native CheckBox role without falling back to any row.
        let row = app.switches["previewLargeText"].firstMatch
        #if os(macOS)
        let nativeControl = row.exists ? row : app.checkBoxes["previewLargeText"].firstMatch
        #else
        let nativeControl = row
        #endif
        guard nativeControl.waitForExistence(timeout: 5) else {
            diagnose("failure-accessibility-native-control", app: app)
            XCTFail("Missing native accessibility switch or checkbox"); return
        }
        let thumb = nativeControl.switches.firstMatch
        let largeType = thumb.exists ? thumb : nativeControl
        let existsBefore = largeType.waitForExistence(timeout: 5)
        let enabledBefore = existsBefore && largeType.isEnabled
        let hittableBefore = existsBefore && largeType.isHittable
        let rawBefore = existsBefore ? largeType.value : nil
        recordToggleState("before", control: largeType, raw: rawBefore,
                          exists: existsBefore, enabled: enabledBefore, hittable: hittableBefore)
        guard existsBefore else { XCTFail("Native accessibility control disappeared"); return }
        guard enabledBefore && hittableBefore else {
            diagnose("failure-accessibility-switch-reachability", app: app)
            XCTFail("Native accessibility control must be enabled and hittable"); return
        }
        guard exactToggleState(rawBefore) == false else {
            diagnose("failure-accessibility-switch-off", app: app)
            XCTFail("Native accessibility control must expose exact off state 0"); return
        }
        largeType.tap()
        let deadline = Date().addingTimeInterval(5)
        var rawAfter: Any?
        repeat {
            rawAfter = largeType.exists ? largeType.value : nil
            if exactToggleState(rawAfter) == true { break }
            RunLoop.current.run(until: Date().addingTimeInterval(0.1))
        } while Date() < deadline
        let existsAfter = largeType.exists
        let enabledAfter = existsAfter && largeType.isEnabled
        let hittableAfter = existsAfter && largeType.isHittable
        recordToggleState("after", control: largeType, raw: rawAfter,
                          exists: existsAfter, enabled: enabledAfter, hittable: hittableAfter)
        guard existsAfter && enabledAfter && hittableAfter else {
            diagnose("failure-accessibility-switch-after-reachability", app: app)
            XCTFail("Enabled native accessibility control must remain reachable after the tap"); return
        }
        guard exactToggleState(rawAfter) == true else {
            diagnose("failure-accessibility-switch-on", app: app)
            XCTFail("Native accessibility control did not change to exact on state 1"); return
        }
        capture("accessibility-option-enabled", app: app)
        app.buttons["closePreviewOptions"].firstMatch.tap()
        guard let after = visibleMediaGeometry(in: app), after.title.minY >= after.media.maxY,
              after.title.minX < after.media.maxX else {
            diagnose("failure-accessibility-reflow", app: app)
            XCTFail("Accessibility size must visibly reflow the same media/title into a vertical layout"); return
        }
        let measurements = XCTAttachment(string: "Normal media=\(before.media), title=\(before.title)\nAccessibility media=\(after.media), title=\(after.title)")
        measurements.name = "accessibility-layout-measurements"
        measurements.lifetime = .keepAlways
        add(measurements)
        capture("foundations-accessibility-text", app: app)
    }
}
