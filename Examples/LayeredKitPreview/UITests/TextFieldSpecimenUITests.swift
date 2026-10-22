import XCTest

@MainActor
final class TextFieldSpecimenUITests: XCTestCase {
    private func launch(state: String, appearance: String = "light", editingDiagnostics: Bool = false) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchEnvironment["LAYERED_KIT_SPECIMEN"] = "text-fields"
        app.launchEnvironment["LAYERED_KIT_FIELD_STATE"] = state
        app.launchEnvironment["LAYERED_KIT_APPEARANCE"] = appearance
        if editingDiagnostics { app.launchEnvironment["LAYERED_KIT_EDITING_DIAGNOSTICS"] = "1" }
        app.launch()
        return app
    }

    private func capture(_ name: String, app: XCUIApplication) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    /// Only used by the nonsecure focused reference. Never call after secure entry.
    private func attachFocusedFieldDiagnostics(_ name: String, field: XCUIElement, app: XCUIApplication) {
        capture(name, app: app)
        var facts = ["appState=\(app.state.rawValue)", "fieldExists=\(field.exists)"]
        if field.exists {
            facts.append("fieldFrame=\(field.frame) enabled=\(field.isEnabled) hittable=\(field.isHittable)")
        }
        let attachment = XCTAttachment(string: facts.joined(separator: "\n") + "\n\n" + app.debugDescription)
        attachment.name = name + "-accessibility"
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    private func focusReferenceField(_ field: XCUIElement, appearance: String, app: XCUIApplication) -> Bool {
        guard app.wait(for: .runningForeground, timeout: 5) else {
            attachFocusedFieldDiagnostics("failure-field-foreground-\(appearance)", field: field, app: app)
            XCTFail("The focused reference app must be foreground before its one native field tap.")
            return false
        }
        let ready = XCTNSPredicateExpectation(
            predicate: NSPredicate(format: "exists == true AND enabled == true AND hittable == true"),
            object: field)
        guard XCTWaiter.wait(for: [ready], timeout: 5) == .completed,
              app.state == .runningForeground else {
            attachFocusedFieldDiagnostics("failure-field-readiness-\(appearance)", field: field, app: app)
            XCTFail("The focused reference field must be enabled and hittable in the foreground app.")
            return false
        }
        // Readiness is a precondition, not proof of focus. The observed iPad miss
        // remains unexplained; retain before/after evidence and never retry its tap.
        attachFocusedFieldDiagnostics("before-field-focus-\(appearance)", field: field, app: app)
        field.tap()
        #if os(iOS)
        let keyboardAppeared = app.keyboards.firstMatch.waitForExistence(timeout: 5)
        if !keyboardAppeared {
            attachFocusedFieldDiagnostics("failure-field-focus-\(appearance)", field: field, app: app)
        }
        XCTAssertTrue(keyboardAppeared, "One native field tap must show the keyboard before a focused reference is captured.")
        return keyboardAppeared
        #else
        return true
        #endif
    }

    func testTextFieldReferenceStates() {
        for appearance in ["light", "dark"] {
            for state in ["normal", "focused", "disabled", "error", "secure", "multiline", "nested"] {
                let app = launch(state: state, appearance: appearance)
                let identifier: String
                switch state {
                case "secure": identifier = "fieldSecure"
                case "multiline": identifier = "fieldMultiline"
                case "nested": identifier = "fieldNested"
                default: identifier = "fieldSingleLine"
                }
                let field = app.descendants(matching: .any).matching(identifier: identifier).firstMatch
                XCTAssertTrue(field.waitForExistence(timeout: 10))
                XCTAssertEqual(field.isEnabled, state != "disabled")
                if state == "error" {
                    XCTAssertTrue(app.staticTexts["fieldValidation"].exists)
                }
                if state == "secure" {
                    XCTAssertTrue(app.secureTextFields["fieldSecure"].exists)
                }
                if state == "focused" {
                    guard focusReferenceField(field, appearance: appearance, app: app) else {
                        app.terminate()
                        continue
                    }
                }
                capture("text-field-\(state)-\(appearance)", app: app)
                app.terminate()
            }
        }
    }

    private enum KeyboardVisibility: String { case absent, visible, unknown }

    /// Geometry is conservative: zero, missing, infinite or NaN observations are
    /// unknown, never evidence that an existing keyboard has disappeared.
    private static func keyboardVisibility(window: CGRect?, frames: [CGRect]) -> KeyboardVisibility {
        func finiteArea(_ frame: CGRect) -> Bool {
            !frame.isNull && !frame.isInfinite && !frame.isEmpty
                && frame.minX.isFinite && frame.minY.isFinite
                && frame.width.isFinite && frame.height.isFinite
        }
        guard let window, finiteArea(window) else { return .unknown }
        var unknown = false
        for frame in frames {
            guard finiteArea(frame) else { unknown = true; continue }
            if finiteArea(frame.intersection(window)) { return .visible }
        }
        return unknown ? .unknown : .absent
    }

    private static func acceptsDismissal(focusReceipt: String?, visibility: KeyboardVisibility,
                                         foreground: Bool, textRetained: Bool, elapsed: TimeInterval) -> Bool {
        focusReceipt == "focus=none;finish=1" && visibility == .absent
            && foreground && textRetained && elapsed.isFinite && elapsed >= 0 && elapsed < 5
    }

    private func flattened(_ snapshot: XCUIElementSnapshot) -> [XCUIElementSnapshot] {
        [snapshot] + snapshot.children.flatMap { flattened($0) }
    }

    private struct EditingObservation {
        var focusReceipt: String?
        var visibility: KeyboardVisibility = .unknown
        var textRetained = false
        var foreground = false
        var elapsed: TimeInterval = 0
        var completedUptime: TimeInterval = 0
    }

    /// Diagnostic only. A single hierarchy snapshot binds the DEBUG receipt and
    /// geometry to one native observation, but does not prove whole-screen state.
    private func observeEditing(_ name: String, app: XCUIApplication) -> EditingObservation {
        let started = ProcessInfo.processInfo.systemUptime
        var observation = EditingObservation()
        var facts = ["editing-diagnostic/v1 observation=\(name) scope=app-window-only acceptance=legacy-waiter-unchanged"]
        let stateBefore = app.state
        do {
            let nodes = flattened(try app.snapshot())
            let field = nodes.first { $0.identifier == "fieldSingleLine" }
            let receipt = nodes.first { $0.identifier == "fieldFinishEditing" }?.value as? String
            let windows = nodes.filter { $0.elementType == .window }
            let window = windows.first { candidate in
                guard let field else { return false }
                return candidate.frame.contains(field.frame)
            }?.frame
            let keyboards = nodes.filter { $0.elementType == .keyboard }
            let inputs = nodes.filter { $0.elementType == .keyboard || $0.elementType == .key }
            let fieldGeometryKnown = Self.keyboardVisibility(window: field?.frame, frames: []) == .absent
            observation.focusReceipt = receipt
            observation.visibility = fieldGeometryKnown
                ? Self.keyboardVisibility(window: window, frames: inputs.map { $0.frame }) : .unknown
            observation.textRetained = (field?.value as? String)?.contains("local") == true
            let stateAfter = app.state
            observation.foreground = stateBefore == .runningForeground && stateAfter == .runningForeground
            observation.completedUptime = ProcessInfo.processInfo.systemUptime
            observation.elapsed = observation.completedUptime - started
            facts.append("elapsed=\(observation.elapsed) stateBefore=\(stateBefore.rawValue) stateAfter=\(stateAfter.rawValue) receipt=\(String(describing: receipt)) snapshotKeyboardExists=\(!keyboards.isEmpty) window=\(String(describing: window)) fieldFrame=\(String(describing: field?.frame)) visibility=\(observation.visibility.rawValue) textRetained=\(observation.textRetained)")
            for (index, input) in inputs.enumerated() {
                // No input values/labels are exported, only native geometry/type.
                facts.append("input=\(index) type=\(input.elementType.rawValue) frame=\(input.frame) enabled=\(input.isEnabled)")
            }
        } catch {
            observation.completedUptime = ProcessInfo.processInfo.systemUptime
            observation.elapsed = observation.completedUptime - started
            facts.append("elapsed=\(observation.elapsed) snapshotError=\(error) visibility=unknown")
        }
        let attachment = XCTAttachment(string: facts.joined(separator: "\n"))
        attachment.name = "field-editing-\(name)-observations"
        attachment.lifetime = .keepAlways
        add(attachment)
        capture("field-editing-\(name)", app: app)
        return observation
    }

    func testKeyboardDismissalPolicy() {
        let window = CGRect(x: 0, y: 0, width: 1024, height: 768)
        let docked = CGRect(x: 0, y: 500, width: 1024, height: 268)
        let floating = CGRect(x: 600, y: 180, width: 300, height: 240)
        XCTAssertEqual(Self.keyboardVisibility(window: window, frames: []), .absent)
        XCTAssertEqual(Self.keyboardVisibility(window: window, frames: [docked]), .visible)
        XCTAssertEqual(Self.keyboardVisibility(window: window, frames: [floating]), .visible)
        XCTAssertEqual(Self.keyboardVisibility(window: nil, frames: []), .unknown)
        XCTAssertEqual(Self.keyboardVisibility(window: .zero, frames: []), .unknown)
        XCTAssertEqual(Self.keyboardVisibility(window: window, frames: [.zero]), .unknown)
        XCTAssertEqual(Self.keyboardVisibility(window: window, frames: [.infinite]), .unknown)
        XCTAssertEqual(Self.keyboardVisibility(window: window, frames: [.null]), .unknown)
        XCTAssertEqual(Self.keyboardVisibility(window: window, frames: [CGRect(x: CGFloat.nan, y: 0, width: 1, height: 1)]), .unknown)
        XCTAssertEqual(Self.keyboardVisibility(window: window, frames: [docked.offsetBy(dx: 0, dy: 768)]), .absent)
        XCTAssertFalse(Self.acceptsDismissal(focusReceipt: nil, visibility: .absent, foreground: true, textRetained: true, elapsed: 1))
        XCTAssertFalse(Self.acceptsDismissal(focusReceipt: "focus=name;finish=1", visibility: .absent, foreground: true, textRetained: true, elapsed: 1))
        XCTAssertFalse(Self.acceptsDismissal(focusReceipt: "focus=none;finish=0", visibility: .absent, foreground: true, textRetained: true, elapsed: 1))
        XCTAssertFalse(Self.acceptsDismissal(focusReceipt: "focus=none;finish=1", visibility: .visible, foreground: true, textRetained: true, elapsed: 1))
        XCTAssertFalse(Self.acceptsDismissal(focusReceipt: "focus=none;finish=1", visibility: .unknown, foreground: true, textRetained: true, elapsed: 1))
        XCTAssertFalse(Self.acceptsDismissal(focusReceipt: "focus=none;finish=1", visibility: .absent, foreground: false, textRetained: true, elapsed: 1))
        XCTAssertFalse(Self.acceptsDismissal(focusReceipt: "focus=none;finish=1", visibility: .absent, foreground: true, textRetained: false, elapsed: 1))
        XCTAssertFalse(Self.acceptsDismissal(focusReceipt: "focus=none;finish=1", visibility: .absent, foreground: true, textRetained: true, elapsed: 5))
        XCTAssertTrue(Self.acceptsDismissal(focusReceipt: "focus=none;finish=1", visibility: .absent, foreground: true, textRetained: true, elapsed: 4.999))
    }

    func testFieldRetainsEditingAndFocus() {
        let app = launch(state: "normal", editingDiagnostics: true)
        let field = app.textFields["fieldSingleLine"]
        XCTAssertTrue(field.waitForExistence(timeout: 10))
        field.tap()
        field.typeText(" local")
        XCTAssertTrue((field.value as? String)?.contains("local") == true)
        #if os(iOS)
        let before = observeEditing("before-finish", app: app)
        #endif
        app.buttons["fieldFinishEditing"].tap() // Exactly one native action.
        #if os(iOS)
        let keyboardDismissed = XCTNSPredicateExpectation(
            predicate: NSPredicate(format: "exists == false"), object: app.keyboards.firstMatch)
        let waitStarted = ProcessInfo.processInfo.systemUptime
        let waiterResult = XCTWaiter.wait(for: [keyboardDismissed], timeout: 5)
        let waitCompleted = ProcessInfo.processInfo.systemUptime
        let waitElapsed = waitCompleted - waitStarted
        // Preserve the decisive result before any later AX/screenshot request can
        // stall. The Boolean of each predicate evaluation remains unavailable.
        let waiterReceipt = XCTAttachment(string:
            "legacyWaiterRaw=\(waiterResult.rawValue) waitStartedUptime=\(waitStarted) waitCompletedUptime=\(waitCompleted) waitElapsed=\(waitElapsed) timeout=5 predicate=keyboard.exists==false")
        waiterReceipt.name = "field-editing-original-waiter-result"
        waiterReceipt.lifetime = .keepAlways
        add(waiterReceipt)
        let after = observeEditing("after-wait", app: app)
        // Sidecar only: this candidate NEVER overrides the actual legacy result.
        // The active baseline requires prior positive detection; completeness of
        // a later snapshot remains unproved. Scope is explicitly app-window only.
        let sawActiveBaseline = before.focusReceipt == "focus=name;finish=0" && before.visibility == .visible
        let candidateElapsed = after.completedUptime - waitStarted
        let candidate = sawActiveBaseline && Self.acceptsDismissal(
            focusReceipt: after.focusReceipt, visibility: after.visibility,
            foreground: after.foreground, textRetained: after.textRetained,
            elapsed: candidateElapsed)
        let diagnostic = XCTAttachment(string:
            "legacyWaiterRaw=\(waiterResult.rawValue) waitElapsed=\(waitElapsed) postWaitObservationElapsed=\(after.elapsed) candidateElapsed=\(candidateElapsed) sawActiveBaseline=\(sawActiveBaseline) semanticCandidateOnly=\(candidate) candidateScope=app-window-only passFail=legacy-waiter")
        diagnostic.name = "field-editing-dismissal-result"
        diagnostic.lifetime = .keepAlways
        add(diagnostic)
        XCTAssertEqual(waiterResult, .completed) // Original functional gate, unchanged.
        #endif
        field.tap()
        field.typeText(" again")
        XCTAssertTrue((field.value as? String)?.contains("again") == true)
        #if os(iOS)
        _ = observeEditing("after-refocus", app: app)
        #endif
    }

    func testSecureFieldKeepsNativeSecureEntry() {
        let app = launch(state: "secure")
        let field = app.secureTextFields["fieldSecure"]
        XCTAssertTrue(field.waitForExistence(timeout: 10))
        let status = app.staticTexts["fieldSecureStatus"]
        XCTAssertTrue(status.waitForExistence(timeout: 5))
        // AppKit exposes this native StaticText's displayed content through AX value;
        // UIKit exposes it through label. Check the actual binding transition on each.
        #if os(macOS)
        let statusAttribute = "value"
        #else
        let statusAttribute = "label"
        #endif
        let initiallyEmpty = XCTNSPredicateExpectation(
            predicate: NSPredicate(format: "%K == %@", statusAttribute, "No text entered"),
            object: status)
        XCTAssertEqual(XCTWaiter.wait(for: [initiallyEmpty], timeout: 5), .completed,
                       "The caller-owned secure binding must start empty")
        field.tap()
        let fixtureText = "fixture-only"
        field.typeText(fixtureText)
        let entered = XCTNSPredicateExpectation(
            predicate: NSPredicate(format: "%K == %@", statusAttribute, "Text entered"),
            object: status)
        XCTAssertEqual(XCTWaiter.wait(for: [entered], timeout: 5), .completed,
                       "Native typing must update the caller-owned secure binding")
        XCTAssertTrue(field.exists, "The edited control must remain a native secure text field")
        // XCUI value is optional raw Accessibility data; do not assume a platform's masking glyph.
        // Binding-state evidence above prevents nil, empty or unchanged AX values from faking editing.
        let exposesPlaintext = (field.value as? String) == fixtureText
        XCTAssertFalse(exposesPlaintext, "Secure Accessibility value must not expose entered content")
        // Deliberately no screenshot or accessibility dump after secure text entry.
    }
}
