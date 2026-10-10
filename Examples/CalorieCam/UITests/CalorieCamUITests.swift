import XCTest

/// Run against both schemes on Apple tooling. Each test uses an isolated journal.
@MainActor
final class CalorieCamUITests: XCTestCase {
    private func launch(journalID: String = UUID().uuidString) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchEnvironment["CALORIECAM_TEST_JOURNAL"] = journalID
        app.launchEnvironment["CALORIECAM_ANALYSIS_URL"] = ""
        app.launch()
        return app
    }

    /// Attach the rendered app, never a mock or reconstructed image. CI must run the test
    /// and retain its xcresult bundle before these become visual evidence.
    private func attachScreenshot(_ name: String, of app: XCUIApplication) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    /// The row owns a concise VoiceOver summary and stable identity, while its
    /// concrete native accessibility element type may differ between destinations.
    private func savedMeal(named name: String, in app: XCUIApplication) -> XCUIElement {
        app.descendants(matching: .any).matching(
            NSPredicate(format: "identifier BEGINSWITH %@ AND label CONTAINS %@", "savedMeal-", name)
        ).firstMatch
    }

    /// AppKit exposes Text through value; UIKit can provide an empty value with
    /// the actual text in label. Preserve exact comparisons after extracting it.
    private func displayedText(of element: XCUIElement) -> String {
        if let value = element.value as? String, !value.isEmpty { return value }
        return element.label
    }

    private func overlapsVisibleWindow(_ frame: CGRect, window: CGRect) -> Bool {
        guard !frame.isNull, !frame.isInfinite, !frame.isEmpty,
              !window.isNull, !window.isInfinite, !window.isEmpty else { return false }
        let overlap = frame.intersection(window)
        return !overlap.isNull && overlap.width > 0 && overlap.height > 0
    }

    private func hasVisibleKeyboardOrAccessory(in app: XCUIApplication, doneIdentifier: String = "finishFoodEditing") -> Bool {
        let window = app.windows.firstMatch.frame
        let done = app.buttons[doneIdentifier]
        if done.exists && overlapsVisibleWindow(done.frame, window: window) && done.isHittable { return true }
        for keyboard in app.keyboards.allElementsBoundByIndex {
            guard keyboard.exists else { continue }
            if overlapsVisibleWindow(keyboard.frame, window: window) && keyboard.isHittable { return true }
            // A floating keyboard or a non-hittable container can still own active keys.
            for key in keyboard.keys.allElementsBoundByIndex {
                if key.exists && overlapsVisibleWindow(key.frame, window: window) && key.isHittable { return true }
            }
        }
        return false
    }

    private func attachKeyboardDiagnostics(in app: XCUIApplication, doneIdentifier: String = "finishFoodEditing") {
        attachScreenshot("failure-keyboard-dismissal", of: app)
        let window = app.windows.firstMatch.frame
        var facts = ["window=\(window)"]
        let done = app.buttons[doneIdentifier]
        if done.exists {
            facts.append("Done exists=true frame=\(done.frame) hittable=\(done.isHittable) intersects=\(overlapsVisibleWindow(done.frame, window: window))")
        } else {
            facts.append("Done exists=false")
        }
        for (index, keyboard) in app.keyboards.allElementsBoundByIndex.enumerated() {
            facts.append("Keyboard[\(index)] exists=\(keyboard.exists) frame=\(keyboard.frame) hittable=\(keyboard.isHittable) intersects=\(overlapsVisibleWindow(keyboard.frame, window: window))")
            for key in keyboard.keys.allElementsBoundByIndex {
                facts.append("key frame=\(key.frame) hittable=\(key.isHittable) intersects=\(overlapsVisibleWindow(key.frame, window: window))")
            }
        }
        let attachment = XCTAttachment(string: facts.joined(separator: "\n") + "\n\n" + app.debugDescription)
        attachment.name = "failure-keyboard-accessibility"
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    private func finishKeyboardEditing(in app: XCUIApplication, doneIdentifier: String = "finishFoodEditing") -> Bool {
        #if os(iOS)
        guard hasVisibleKeyboardOrAccessory(in: app, doneIdentifier: doneIdentifier) else { return true }
        let done = app.buttons[doneIdentifier]
        guard done.waitForExistence(timeout: 5) else {
            attachKeyboardDiagnostics(in: app, doneIdentifier: doneIdentifier)
            XCTFail("Expected the native keyboard Done action.")
            return false
        }
        done.tap()
        // Native video proved iOS can retain an inert AX Keyboard after dismissal.
        // Require no onscreen, hittable keyboard/keys or active editing accessory,
        // rather than requiring deletion of that accessibility node.
        let deadline = Date().addingTimeInterval(5)
        repeat {
            if !hasVisibleKeyboardOrAccessory(in: app, doneIdentifier: doneIdentifier) { return true }
            RunLoop.current.run(until: Date().addingTimeInterval(0.1))
        } while Date() < deadline
        attachKeyboardDiagnostics(in: app, doneIdentifier: doneIdentifier)
        XCTFail("Done left a visible active keyboard or editing accessory.")
        return false
        #else
        return true
        #endif
    }

    func testKeyboardVisibilityGeometryIncludesFloatingKeyboards() {
        let window = CGRect(x: 0, y: 0, width: 1024, height: 768)
        XCTAssertTrue(overlapsVisibleWindow(CGRect(x: 0, y: 500, width: 1024, height: 268), window: window))
        XCTAssertTrue(overlapsVisibleWindow(CGRect(x: 600, y: 180, width: 300, height: 240), window: window))
        XCTAssertTrue(overlapsVisibleWindow(CGRect(x: 1000, y: 200, width: 100, height: 100), window: window))
        XCTAssertFalse(overlapsVisibleWindow(CGRect(x: 0, y: 768, width: 1024, height: 268), window: window))
        XCTAssertFalse(overlapsVisibleWindow(CGRect(x: -400, y: 100, width: 300, height: 200), window: window))
        XCTAssertFalse(overlapsVisibleWindow(.zero, window: window))
        XCTAssertFalse(overlapsVisibleWindow(.null, window: window))
        XCTAssertFalse(overlapsVisibleWindow(.infinite, window: window))
    }

    /// The photo-led capture screen scrolls on smaller windows; let the native
    /// ScrollView reveal the action instead of assuming every button is above the fold.
    private func tapCaptureAction(_ identifier: String, in app: XCUIApplication) -> Bool {
        let action = app.descendants(matching: .any).matching(identifier: identifier).firstMatch
        guard action.waitForExistence(timeout: 5) else {
            XCTFail("Missing capture action: \(identifier)")
            return false
        }
        let scroll = app.descendants(matching: .any).matching(identifier: "mealCaptureScroll").firstMatch
        for _ in 0..<5 {
            // AppKit can report an offscreen scroll descendant as hittable.
            // Require its actual tap point inside the visible viewport as well.
            let center = CGPoint(x: action.frame.midX, y: action.frame.midY)
            let visibleBounds = scroll.frame.intersection(app.windows.firstMatch.frame).insetBy(dx: 2, dy: 2)
            if action.isHittable && visibleBounds.contains(center) {
                action.tap()
                return true
            }
            #if os(macOS)
            scroll.scroll(byDeltaX: 0, deltaY: -240)
            #else
            scroll.swipeUp()
            #endif
        }
        XCTFail("Capture action did not become reachable by scrolling: \(identifier)")
        return false
    }

    private func chooseSamplePhoto(in app: XCUIApplication) -> Bool {
        guard tapCaptureAction("sourceOptions", in: app) else { return false }
        let sample = app.descendants(matching: .any).matching(identifier: "trySampleMeal").firstMatch
        guard sample.waitForExistence(timeout: 5) else {
            XCTFail("The source menu must offer the explicit sample option.")
            return false
        }
        sample.tap()
        guard app.images["selectedMealPhoto"].waitForExistence(timeout: 5),
              app.staticTexts["Sample illustration · fixed demo values"].exists else {
            XCTFail("Selecting the sample must show the photo stage with sample provenance.")
            return false
        }
        return true
    }

    func testEmptyJournalAndCancelCapture() {
        let app = launch()
        guard app.staticTexts["No meals logged"].waitForExistence(timeout: 5) else {
            XCTFail("Expected the empty diary before capturing evidence.")
            return
        }
        attachScreenshot("01-empty-diary", of: app)
        app.buttons["addMeal"].tap()
        guard app.staticTexts["On-device demo"].waitForExistence(timeout: 5) else {
            XCTFail("Expected the capture screen before capturing evidence.")
            return
        }
        XCTAssertFalse(app.buttons["demoEstimate"].exists)
        XCTAssertTrue(app.descendants(matching: .any).matching(identifier: "sourceOptions").firstMatch.exists)
        attachScreenshot("02-capture-photo-choices", of: app)
        app.buttons["cancelMeal"].tap()
        XCTAssertTrue(app.staticTexts["No meals logged"].waitForExistence(timeout: 5))
    }

    func testManualMealSaveAndPersistence() {
        let id = UUID().uuidString
        let app = launch(journalID: id)
        app.buttons["addMeal"].tap()
        guard tapCaptureAction("enterManually", in: app) else { return }
        let name = app.textFields["foodName"]
        XCTAssertTrue(name.waitForExistence(timeout: 5))
        name.tap()
        name.typeText("Test apple")
        guard finishKeyboardEditing(in: app) else { return }
        let portion = app.textFields["foodPortion"]
        portion.tap()
        portion.typeText("1 medium")
        guard finishKeyboardEditing(in: app) else { return }
        let calories = app.textFields["foodCalories"]
        #if os(macOS)
        calories.tap()
        app.typeKey("a", modifierFlags: .command)
        #else
        // Use the visible native keyboard action instead of assuming a caret or
        // selection position; double-tap selection varies on iPad.
        calories.tap()
        let clear = app.buttons["clearCalories"]
        guard clear.waitForExistence(timeout: 5) else {
            XCTFail("The calorie field did not acquire focus and show its Clear action.")
            return
        }
        clear.tap()
        guard app.staticTexts["foodCaloriesError"].waitForExistence(timeout: 5),
              !app.buttons["saveMeal"].isEnabled else {
            XCTFail("An incomplete calorie value must remain visible and block Save.")
            return
        }
        #endif
        calories.typeText("95")
        guard calories.value as? String == "95" else {
            XCTFail("Calorie replacement failed; expected exactly 95 before saving or capturing evidence.")
            return
        }
        let save = app.buttons["saveMeal"]
        #if os(iOS)
        guard finishKeyboardEditing(in: app) else { return }
        let form = app.descendants(matching: .any).matching(identifier: "mealReviewForm").firstMatch
        for _ in 0..<3 {
            if app.staticTexts["Manually entered"].isHittable { break }
            form.swipeDown()
        }
        guard name.isHittable else {
            XCTFail("The review screenshot must show the food name.")
            return
        }
        #endif
        guard save.isEnabled else {
            XCTFail("Expected a valid editable meal before capturing evidence.")
            return
        }
        attachScreenshot("03-editable-meal-review", of: app)
        save.tap()
        let reviewClosed = XCTNSPredicateExpectation(predicate: NSPredicate(format: "exists == false"), object: name)
        guard XCTWaiter.wait(for: [reviewClosed], timeout: 5) == .completed else {
            XCTFail("Saving did not close the editable review.")
            return
        }
        let row = savedMeal(named: "Test apple", in: app)
        guard row.waitForExistence(timeout: 5) else {
            XCTFail("Expected the saved diary entry before capturing evidence.")
            return
        }
        guard row.label.contains("95 kcal") else {
            XCTFail("The saved row does not contain the reviewed 95 kcal value.")
            return
        }
        attachScreenshot("04-saved-diary", of: app)
        app.terminate()
        let reopened = launch(journalID: id)
        let persistedRow = savedMeal(named: "Test apple", in: reopened)
        guard persistedRow.waitForExistence(timeout: 5),
              persistedRow.label.contains("95 kcal"),
              persistedRow.label.contains("Manually entered") else {
            XCTFail("The reviewed meal, exact calorie value and provenance must survive relaunch.")
            return
        }
        persistedRow.tap()
        let detailName = reopened.staticTexts["mealDetailFoodName"]
        guard detailName.waitForExistence(timeout: 5) else {
            XCTFail("Selecting the saved row did not open meal details.")
            return
        }
        let detailPortion = reopened.staticTexts["mealDetailPortion"]
        let detailCalories = reopened.staticTexts["mealDetailCalories"]
        guard displayedText(of: detailName) == "Test apple",
              displayedText(of: detailPortion) == "1 medium",
              displayedText(of: detailCalories) == "95 kcal" else {
            attachScreenshot("failure-persisted-detail-values", of: reopened)
            let hierarchy = XCTAttachment(string: reopened.debugDescription)
            hierarchy.name = "failure-persisted-detail-accessibility"
            hierarchy.lifetime = .keepAlways
            add(hierarchy)
            XCTFail("Meal details must show the persisted name, portion and exact calorie value. Name label=\(detailName.label), value=\(String(describing: detailName.value)); portion label=\(detailPortion.label), value=\(String(describing: detailPortion.value)); calories label=\(detailCalories.label), value=\(String(describing: detailCalories.value))")
            return
        }
        attachScreenshot("08-meal-detail", of: reopened)
    }

    func testBlankMealCannotBeSavedAndDiscardNeedsConfirmation() {
        let app = launch()
        app.buttons["addMeal"].tap()
        guard tapCaptureAction("enterManually", in: app) else { return }
        guard app.buttons["saveMeal"].waitForExistence(timeout: 5) else {
            XCTFail("Expected review Save before checking blank-meal validation.")
            return
        }
        XCTAssertFalse(app.buttons["saveMeal"].isEnabled)
        let portion = app.textFields["foodPortion"]
        portion.tap()
        portion.typeText("Unsaved portion")
        guard finishKeyboardEditing(in: app) else { return }
        let cancel = app.buttons["cancelMeal"]
        cancel.tap()
        #if os(macOS)
        // App-wide queries also find the native Touch Bar's mirrored action.
        let discard = app.windows.buttons["Discard meal"]
        #else
        let discard = app.buttons["Discard meal"]
        #endif
        guard discard.waitForExistence(timeout: 5) else {
            XCTFail("Leaving an unfinished meal must offer explicit discard confirmation.")
            return
        }
        attachScreenshot("06-discard-confirmation", of: app)

        #if os(macOS)
        let keepEditing = app.windows.buttons["Keep editing"]
        #else
        let keepEditing = app.buttons["Keep editing"]
        #endif
        if keepEditing.exists && keepEditing.isHittable {
            keepEditing.tap()
        } else {
            // SwiftUI omits the cancel-role button in a native popover. Preserve that
            // platform behavior: Escape on Mac, or an outside tap on the iOS toolbar
            // anchor. Never tap a destructive action as a dismissal fallback.
            #if os(macOS)
            app.typeKey(XCUIKeyboardKey.escape, modifierFlags: [])
            #else
            cancel.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
            #endif
        }
        let dialogDismissed = XCTNSPredicateExpectation(predicate: NSPredicate(format: "exists == false"), object: discard)
        guard XCTWaiter.wait(for: [dialogDismissed], timeout: 5) == .completed else {
            XCTFail("Native cancellation did not dismiss the discard confirmation.")
            return
        }
        XCTAssertTrue(app.textFields["foodName"].exists)
        XCTAssertEqual(portion.value as? String, "Unsaved portion", "Cancelling discard must preserve the draft.")
        attachScreenshot("07-draft-preserved-after-cancel", of: app)

        // Confirm the separate destructive path still requires the explicit button.
        cancel.tap()
        guard discard.waitForExistence(timeout: 5) else {
            XCTFail("Expected discard confirmation again before removing the draft.")
            return
        }
        discard.tap()
        let reviewClosed = XCTNSPredicateExpectation(predicate: NSPredicate(format: "exists == false"), object: app.textFields["foodName"])
        XCTAssertEqual(XCTWaiter.wait(for: [reviewClosed], timeout: 5), .completed)
        XCTAssertTrue(app.staticTexts["No meals logged"].waitForExistence(timeout: 5))
    }

    func testConfiguredAIRequiresPhotoBeforeUploadAction() {
        let app = XCUIApplication()
        app.launchEnvironment["CALORIECAM_TEST_JOURNAL"] = UUID().uuidString
        app.launchEnvironment["CALORIECAM_ANALYSIS_URL"] = "https://example.com/analyze"
        app.launch()
        app.buttons["addMeal"].tap()
        XCTAssertTrue(app.staticTexts["Photo meal entry"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.buttons["remoteEstimate"].exists, "AI estimation is unavailable until a photo is selected.")
        XCTAssertFalse(app.buttons["Send photo and estimate"].exists)
        XCTAssertFalse(app.buttons["saveMeal"].exists)
        XCTAssertTrue(app.buttons["enterManually"].exists)
        XCTAssertTrue(app.descendants(matching: .any).matching(identifier: "choosePhoto").firstMatch.exists)
        app.buttons["cancelMeal"].tap()
    }

    func testOutOfRangeCaloriesBlockSaving() {
        let app = launch()
        app.buttons["addMeal"].tap()
        guard tapCaptureAction("enterManually", in: app) else { return }
        let name = app.textFields["foodName"]
        guard name.waitForExistence(timeout: 5) else {
            XCTFail("Expected manual meal review.")
            return
        }
        name.tap()
        name.typeText("Test food")
        guard finishKeyboardEditing(in: app) else { return }
        let portion = app.textFields["foodPortion"]
        portion.tap()
        portion.typeText("1 serving")
        guard finishKeyboardEditing(in: app) else { return }
        let save = app.buttons["saveMeal"]
        let valid = XCTNSPredicateExpectation(predicate: NSPredicate(format: "enabled == true"), object: save)
        guard XCTWaiter.wait(for: [valid], timeout: 5) == .completed else {
            XCTFail("The named, portioned zero-calorie entry was not valid before editing.")
            return
        }
        let calories = app.textFields["foodCalories"]
        calories.tap()
        // Digits work with both the iOS decimal keyboard and the Mac keyboard. Whether
        // inserted before or after the initial zero, this exceeds the 10,000 kcal limit.
        calories.typeText("100001")
        let blocked = XCTNSPredicateExpectation(predicate: NSPredicate(format: "enabled == false"), object: save)
        guard XCTWaiter.wait(for: [blocked], timeout: 5) == .completed else {
            XCTFail("Save remained enabled after entering out-of-range calories.")
            return
        }
        XCTAssertTrue(app.staticTexts["foodCaloriesError"].exists)
        attachScreenshot("05-invalid-calorie-review", of: app)
        XCTAssertFalse(save.isEnabled, "Invalid calories must not save a previous valid value.")
    }

    func testSamplePhotoReviewKeepsDemoProvenance() {
        let app = launch()
        app.buttons["addMeal"].tap()
        guard chooseSamplePhoto(in: app) else { return }
        XCTAssertFalse(app.buttons["saveMeal"].exists, "Selecting a sample alone must not start review or save.")
        attachScreenshot("12-selected-sample-stage", of: app)
        guard tapCaptureAction("demoEstimate", in: app) else { return }
        guard app.staticTexts["Demo · sample numbers"].waitForExistence(timeout: 5),
              app.images["Meal photo, for your reference only"].exists else {
            XCTFail("Sample review must show its photo and explicit demo provenance.")
            return
        }
        let save = app.buttons["saveMeal"]
        guard save.isEnabled else {
            XCTFail("Expected the valid, clearly labeled sample to be reviewable before saving.")
            return
        }
        attachScreenshot("09-sample-photo-review", of: app)

        // Deliberately activate Save in this isolated test journal. The sample path
        // itself must never save automatically or send a network request.
        save.tap()
        let reviewClosed = XCTNSPredicateExpectation(
            predicate: NSPredicate(format: "exists == false"),
            object: app.textFields.matching(identifier: "foodName").firstMatch
        )
        guard XCTWaiter.wait(for: [reviewClosed], timeout: 5) == .completed else {
            XCTFail("Explicit sample Save did not close review.")
            return
        }
        // Match a stable title fragment rather than its visual wrapping into two lines.
        let sampleRow = savedMeal(named: "Example rice", in: app)
        guard sampleRow.waitForExistence(timeout: 5),
              sampleRow.label.contains("Example chicken"),
              sampleRow.label.contains("430 kcal"),
              sampleRow.label.contains("Demo · sample numbers") else {
            XCTFail("The saved sample must retain its fixture foods, 430 kcal and explicit demo provenance.")
            return
        }
        attachScreenshot("10-sample-diary", of: app)
        sampleRow.tap()
        guard app.images["sampleDetailImage"].waitForExistence(timeout: 5),
              app.staticTexts["Sample illustration · original photo not stored"].exists else {
            XCTFail("Sample detail must show the actual decoded illustration and its privacy caption.")
            return
        }
        attachScreenshot("11-sample-detail", of: app)
    }

    func testChangingPhotoCanReturnWithoutLosingSelection() {
        let app = launch()
        app.buttons["addMeal"].tap()
        guard chooseSamplePhoto(in: app) else { return }
        XCTAssertFalse(app.buttons["saveMeal"].exists)
        guard tapCaptureAction("changePhoto", in: app) else { return }
        guard app.descendants(matching: .any).matching(identifier: "sourceOptions").firstMatch.waitForExistence(timeout: 5) else {
            XCTFail("Changing a photo must reopen source choices.")
            return
        }
        XCTAssertTrue(app.images["selectedMealPhoto"].exists, "The current photo remains until a replacement succeeds.")
        attachScreenshot("13-replace-photo-stage", of: app)
        guard tapCaptureAction("keepCurrentPhoto", in: app) else { return }
        XCTAssertTrue(app.images["selectedMealPhoto"].exists)
        XCTAssertTrue(app.buttons["demoEstimate"].exists)
        XCTAssertFalse(app.buttons["saveMeal"].exists)
        guard tapCaptureAction("selectedPhotoOptions", in: app) else { return }
        let remove = app.descendants(matching: .any).matching(identifier: "removePhoto").firstMatch
        guard remove.waitForExistence(timeout: 5) else {
            XCTFail("Photo actions must expose explicit local removal.")
            return
        }
        remove.tap()
        XCTAssertTrue(app.staticTexts["Start with a photo"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.images["selectedMealPhoto"].exists)
        XCTAssertFalse(app.buttons["demoEstimate"].exists)
        XCTAssertFalse(app.buttons["saveMeal"].exists)
        app.buttons["cancelMeal"].tap()
        XCTAssertTrue(app.staticTexts["No meals logged"].waitForExistence(timeout: 5))
    }

    private func openSettings(in app: XCUIApplication) -> Bool {
        app.buttons["openAISettings"].tap()
        guard app.buttons["saveAISettings"].waitForExistence(timeout: 5) else {
            attachScreenshot("failure-settings-open", of: app)
            XCTFail("Settings did not open; remaining settings assertions cannot run.")
            return false
        }
        return true
    }

    private func settingsElement(_ identifier: String, in app: XCUIApplication) -> XCUIElement {
        app.descendants(matching: .any).matching(identifier: identifier).firstMatch
    }

    private func revealSettingsElement(_ element: XCUIElement, in app: XCUIApplication, towardTop: Bool = false, requiresHittable: Bool = true) -> Bool {
        // Form's AX frame can extend behind the keyboard. Dismiss through the actual
        // user-facing Done action before asking native scrolling to reveal a field.
        guard finishKeyboardEditing(in: app, doneIdentifier: "finishSettingsEditing") else { return false }
        let form = settingsElement("aiSettingsForm", in: app)
        for attempt in 0..<8 {
            if element.exists && (!requiresHittable || element.isHittable) && form.frame.intersection(app.windows.firstMatch.frame).contains(CGPoint(x: element.frame.midX, y: element.frame.midY)) { return true }
            // Lazy Form rows can leave the AX tree entirely. Search their known
            // section direction, then reverse within the same eight-gesture bound.
            let above = element.exists
                ? element.frame.maxY < form.frame.minY
                : (attempt < 4 ? towardTop : !towardTop)
            #if os(macOS)
            form.scroll(byDeltaX: 0, deltaY: above ? 220 : -220)
            #else
            if above { form.swipeDown() } else { form.swipeUp() }
            #endif
        }
        attachScreenshot("failure-settings-control-reachability", of: app)
        let details = "target=\(element.identifier) exists=\(element.exists) frame=\(element.exists ? element.frame : .zero) form=\(form.frame) window=\(app.windows.firstMatch.frame)\n\n" + app.debugDescription
        let attachment = XCTAttachment(string: details)
        attachment.name = "failure-settings-control-accessibility"
        attachment.lifetime = .keepAlways
        add(attachment)
        XCTFail("Settings control did not become reachable: \(element.identifier)")
        return false
    }

    private func verifyStoredKeyStatus(_ hasKey: Bool, in app: XCUIApplication) -> Bool {
        let status = app.staticTexts["storedKeyStatus"]
        guard revealSettingsElement(status, in: app, requiresHittable: false) else { return false }
        let expected = hasKey ? "Key saved securely on this device" : "No key saved for this provider"
        let matches = XCTNSPredicateExpectation(predicate: NSPredicate(format: "label == %@ OR value == %@", expected, expected), object: status)
        guard XCTWaiter.wait(for: [matches], timeout: 5) == .completed else {
            attachScreenshot("failure-provider-key-status", of: app)
            let attachment = XCTAttachment(string: app.debugDescription)
            attachment.name = "failure-provider-key-status-accessibility"
            attachment.lifetime = .keepAlways
            add(attachment)
            XCTFail("Expected exact provider key status: \(expected); actual: \(displayedText(of: status)). Storage errors must not be treated as missing keys or success.")
            return false
        }
        return true
    }

    private func selectAnalysisMode(_ label: String, in app: XCUIApplication) {
        let mode = settingsElement("analysisMode", in: app)
        guard revealSettingsElement(mode, in: app, towardTop: true) else { return }
        mode.tap()
        #if os(macOS)
        app.menuItems[label].firstMatch.tap()
        #else
        app.buttons[label].firstMatch.tap()
        #endif
    }

    private func selectSettingsSegment(_ label: String, picker: String, in app: XCUIApplication) {
        let control = settingsElement(picker, in: app)
        guard revealSettingsElement(control, in: app, towardTop: true) else { return }
        control.descendants(matching: .any).matching(NSPredicate(format: "label == %@", label)).firstMatch.tap()
    }

    private func saveSettings(in app: XCUIApplication) -> Bool {
        app.buttons["saveAISettings"].tap()
        let closed = XCTNSPredicateExpectation(predicate: NSPredicate(format: "exists == false"), object: app.buttons["saveAISettings"])
        guard XCTWaiter.wait(for: [closed], timeout: 5) == .completed else {
            attachScreenshot("failure-settings-save", of: app)
            XCTFail("Settings Save did not finish successfully.")
            return false
        }
        return true
    }

    func testProviderSettingsCancelSaveIsolationAndRemoval() {
        let app = XCUIApplication()
        app.launchEnvironment["CALORIECAM_TEST_JOURNAL"] = UUID().uuidString
        app.launchEnvironment["CALORIECAM_ANALYSIS_URL"] = ""
        app.launchEnvironment["CALORIECAM_TEST_CONNECTION"] = "mock"
        app.launch()
        guard openSettings(in: app) else { return XCTFail("Settings did not open.") }
        attachScreenshot("14-settings-empty", of: app)
        selectAnalysisMode("My provider API key", in: app)
        let model = app.textFields["providerModel"]
        guard revealSettingsElement(model, in: app, towardTop: true) else { return }
        model.tap(); model.typeText("fixture-openai")
        let key = app.secureTextFields["providerKey"]
        guard revealSettingsElement(key, in: app) else { return }
        key.tap(); key.typeText("local-ui-fixture-openai")
        app.buttons["cancelAISettings"].tap()
        guard openSettings(in: app) else { return XCTFail("Settings did not reopen.") }
        selectAnalysisMode("My provider API key", in: app)
        guard verifyStoredKeyStatus(false, in: app) else { return }
        guard revealSettingsElement(model, in: app, towardTop: true) else { return }
        XCTAssertNotEqual(app.textFields["providerModel"].value as? String, "fixture-openai")
        guard revealSettingsElement(key, in: app) else { return }
        key.tap(); key.typeText("local-ui-hidden-draft")
        selectAnalysisMode("Manual and demo only", in: app)
        guard saveSettings(in: app), openSettings(in: app) else { return }
        selectAnalysisMode("My provider API key", in: app)
        guard verifyStoredKeyStatus(false, in: app) else { return }
        guard revealSettingsElement(model, in: app, towardTop: true) else { return }
        model.tap(); model.typeText("fixture-openai")
        guard revealSettingsElement(key, in: app) else { return }
        key.tap(); key.typeText("local-ui-fixture-openai-initial")
        guard saveSettings(in: app), openSettings(in: app) else { return }
        guard verifyStoredKeyStatus(true, in: app) else { return }
        XCTAssertFalse(app.staticTexts["local-ui-fixture-openai-initial"].exists)
        guard revealSettingsElement(key, in: app) else { return }
        key.tap(); key.typeText("local-ui-fixture-openai")
        guard saveSettings(in: app), openSettings(in: app) else { return }
        guard verifyStoredKeyStatus(true, in: app) else { return }
        attachScreenshot("15-settings-saved-key-redacted", of: app)
        selectSettingsSegment("Claude (Anthropic)", picker: "providerPicker", in: app)
        guard verifyStoredKeyStatus(false, in: app) else { return }
        guard revealSettingsElement(model, in: app, towardTop: true) else { return }
        model.tap(); model.typeText("fixture-claude")
        guard revealSettingsElement(key, in: app) else { return }
        key.tap(); key.typeText("local-ui-fixture-claude")
        let test = app.buttons["testProviderConnection"]
        guard revealSettingsElement(test, in: app) else { return }
        test.tap()
        XCTAssertTrue(app.staticTexts["Local test fixture: model metadata available. No network request."].waitForExistence(timeout: 5))
        guard saveSettings(in: app) else { return }
        app.terminate()
        app.launch()
        guard openSettings(in: app) else { return }
        guard verifyStoredKeyStatus(true, in: app) else { return }
        guard revealSettingsElement(model, in: app, towardTop: true) else { return }
        XCTAssertEqual(app.textFields["providerModel"].value as? String, "fixture-claude")
        selectSettingsSegment("OpenAI", picker: "providerPicker", in: app)
        guard verifyStoredKeyStatus(true, in: app) else { return }
        guard revealSettingsElement(model, in: app, towardTop: true) else { return }
        XCTAssertEqual(app.textFields["providerModel"].value as? String, "fixture-openai")
        guard revealSettingsElement(test, in: app) else { return }
        test.tap()
        XCTAssertTrue(app.staticTexts["Local test fixture: model metadata available. No network request."].waitForExistence(timeout: 5), "The matching stored replacement key must reach the selected provider fixture.")
        for provider in ["OpenAI", "Claude (Anthropic)"] {
            if provider != "OpenAI" { selectSettingsSegment(provider, picker: "providerPicker", in: app) }
            guard verifyStoredKeyStatus(true, in: app) else { return }
            let remove = app.buttons["removeProviderKey"]
            guard revealSettingsElement(remove, in: app) else { return }
            remove.tap()
            #if os(macOS)
            app.windows.buttons["Remove key"].firstMatch.tap()
            #else
            app.buttons["Remove key"].firstMatch.tap()
            #endif
            guard verifyStoredKeyStatus(false, in: app) else { return }
        }
        app.buttons["cancelAISettings"].tap()
    }

    func testUnifiedLightAndDarkAppearanceAcrossDetailAndCapture() {
        let app = launch()
        app.buttons["addMeal"].tap()
        guard chooseSamplePhoto(in: app), tapCaptureAction("demoEstimate", in: app) else { return }
        guard app.buttons["saveMeal"].waitForExistence(timeout: 5) else { return XCTFail("Sample review missing.") }
        app.buttons["saveMeal"].tap()
        let row = savedMeal(named: "Example rice", in: app)
        guard row.waitForExistence(timeout: 5) else { return XCTFail("Sample diary entry missing.") }
        for (appearance, detailName, captureName) in [("Light", "16-unified-light-detail", "17-unified-light-capture"), ("Dark", "18-unified-dark-detail", "19-unified-dark-capture")] {
            guard openSettings(in: app) else { return XCTFail("Appearance settings missing.") }
            selectSettingsSegment(appearance, picker: "appearancePicker", in: app)
            guard saveSettings(in: app), openSettings(in: app) else { return }
            attachScreenshot(appearance == "Light" ? "20-unified-light-settings" : "21-unified-dark-settings", of: app)
            app.buttons["cancelAISettings"].tap()
            row.tap()
            XCTAssertTrue(app.images["sampleDetailImage"].waitForExistence(timeout: 5))
            attachScreenshot(detailName, of: app)
            #if os(iOS)
            if !app.buttons["addMeal"].isHittable { app.navigationBars.buttons.element(boundBy: 0).tap() }
            #endif
            app.buttons["addMeal"].tap()
            XCTAssertTrue(app.staticTexts["On-device demo"].waitForExistence(timeout: 5))
            attachScreenshot(captureName, of: app)
            app.buttons["cancelMeal"].tap()
        }
    }

}
