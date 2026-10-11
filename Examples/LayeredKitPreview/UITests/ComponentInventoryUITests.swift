import XCTest

/// Separate class so CI can shard isolated components independently from 18 screen-family tests.
@MainActor
final class ComponentInventoryUITests: XCTestCase {
    /// Initial component fixtures contain no entered secrets. Failure evidence is
    /// deliberately separate from successful component captures and their bindings.
    private func attachReadinessFailure(_ id: String, state: String, appearance: String,
                                        heading: XCUIElement, app: XCUIApplication) {
        let stem = "failure-readiness--" + id.replacingOccurrences(of: "/", with: "--") + "--" + state + "--" + appearance
        let screenshot = XCTAttachment(screenshot: app.screenshot())
        screenshot.name = stem
        screenshot.lifetime = .keepAlways
        add(screenshot)
        var facts = ["appState=\(app.state.rawValue)", "headingExists=\(heading.exists)"]
        if heading.exists {
            let frame = heading.frame
            let window = app.windows.firstMatch.frame
            facts.append("headingFrame=\(frame) windowFrame=\(window)")
            if hasFiniteArea(frame), hasFiniteArea(window), hasFiniteArea(frame.intersection(window)) {
                facts.append("hittable=\(heading.isHittable)")
            } else {
                facts.append("hittable=notQueriedInvalidGeometry")
            }
        }
        let hierarchy = XCTAttachment(string: facts.joined(separator: "\n") + "\n\n" + app.debugDescription)
        hierarchy.name = stem + "--accessibility"
        hierarchy.lifetime = .keepAlways
        add(hierarchy)
    }

    private struct ReadinessProgress {
        static let maximumObservations = 6
        static let maximumElapsed: TimeInterval = 120
        static let minimumObservationInterval: TimeInterval = 2
        var observations = 0
        var stableSamples = 0
        private var previousWindow: CGRect?
        private var previousHeading: CGRect?

        static func finiteArea(_ frame: CGRect) -> Bool {
            !frame.isNull && !frame.isInfinite && !frame.isEmpty
                && frame.origin.x.isFinite && frame.origin.y.isFinite
                && frame.width.isFinite && frame.height.isFinite
        }

        static func usable(window: CGRect?, heading: CGRect?) -> Bool {
            guard let window, let heading else { return false }
            return finiteArea(window) && finiteArea(heading) && finiteArea(window.intersection(heading))
        }

        private func stable(_ lhs: CGRect?, _ rhs: CGRect) -> Bool {
            guard let lhs else { return false }
            // Permit subpixel settling, but never a moving/offscreen layout.
            return abs(lhs.minX - rhs.minX) <= 1 && abs(lhs.minY - rhs.minY) <= 1
                && abs(lhs.width - rhs.width) <= 1 && abs(lhs.height - rhs.height) <= 1
        }

        func canObserve(elapsed: TimeInterval) -> Bool {
            observations < Self.maximumObservations && elapsed.isFinite && elapsed >= 0 && elapsed < Self.maximumElapsed
        }

        /// Pace completed AX observations without spending the count in a tight loop.
        /// A nil delay means no new observation can start before the deadline.
        func nextObservationDelay(elapsed: TimeInterval, lastStarted: TimeInterval?) -> TimeInterval? {
            guard canObserve(elapsed: elapsed) else { return nil }
            guard let lastStarted else { return 0 }
            guard lastStarted.isFinite, lastStarted >= 0 else { return nil }
            let nextStart = max(elapsed, lastStarted + Self.minimumObservationInterval)
            guard nextStart < Self.maximumElapsed else { return nil }
            return nextStart - elapsed
        }

        mutating func observe(window: CGRect?, heading: CGRect?, foreground: Bool,
                              hittable: Bool, elapsed: TimeInterval) -> Bool {
            observations += 1
            guard observations <= Self.maximumObservations, elapsed < Self.maximumElapsed,
                  foreground, hittable, Self.usable(window: window, heading: heading),
                  let window, let heading else {
                stableSamples = 0
                previousWindow = nil
                previousHeading = nil
                return false
            }
            if stable(previousWindow, window) && stable(previousHeading, heading) {
                stableSamples += 1
            } else {
                stableSamples = 1
                // Anchor the streak so a series of 1-point moves cannot accumulate drift.
                previousWindow = window
                previousHeading = heading
            }
            return stableSamples >= 3
        }
    }

    private func hasFiniteArea(_ frame: CGRect) -> Bool { ReadinessProgress.finiteArea(frame) }

    /// The prior 10-second waiter interrupted individual AX requests before they
    /// completed. This explicitly changes synchronization budget to six completed
    /// observations / 120 seconds, not a claim about application responsiveness.
    /// No invalid snapshot, timeout, or failed hit test is accepted as readiness.
    private func waitForRenderedHeading(_ heading: XCUIElement, id: String,
                                        state: String, appearance: String, app: XCUIApplication) -> Bool {
        let started = ProcessInfo.processInfo.systemUptime
        func elapsed() -> TimeInterval { ProcessInfo.processInfo.systemUptime - started }
        var progress = ReadinessProgress()
        var observations = ["policy=completed-observations/v2 maximumObservations=6 maximumElapsed=120 minimumObservationInterval=2 requiredStableSamples=3"]
        var lastObservationStarted: TimeInterval?
        var succeeded = false
        var outcome = "observation_or_elapsed_budget_exhausted"
        while let delay = progress.nextObservationDelay(elapsed: elapsed(), lastStarted: lastObservationStarted) {
            if delay > 0 {
                // This pauses only the test runner; the app continues settling.
                // Recalculate against monotonic time after waking (including early wakes).
                Thread.sleep(forTimeInterval: delay)
                continue
            }
            let before = elapsed()
            guard progress.canObserve(elapsed: before) else { break }
            lastObservationStarted = before
            let stateBefore = app.state
            let headingExists = heading.exists
            let afterHeadingExists = elapsed()
            let windowElement = app.windows.firstMatch
            let windowExists = windowElement.exists
            let afterWindowExists = elapsed()
            guard headingExists && windowExists else {
                _ = progress.observe(window: nil, heading: nil, foreground: stateBefore == .runningForeground,
                                     hittable: false, elapsed: elapsed())
                observations.append("before=\(before) afterHeadingExists=\(afterHeadingExists) afterWindowExists=\(afterWindowExists) headingExists=\(headingExists) windowExists=\(windowExists) stateBefore=\(stateBefore.rawValue) result=missing")
                continue
            }
            var stage = "windowSnapshot"
            var knownWindow: CGRect?
            var completedWindowAt: TimeInterval?
            do {
                let window = try windowElement.snapshot().frame
                let afterWindowSnapshot = elapsed()
                knownWindow = window
                completedWindowAt = afterWindowSnapshot
                stage = "headingSnapshot"
                let frame = try heading.snapshot().frame
                let afterHeadingSnapshot = elapsed()
                let usable = ReadinessProgress.usable(window: window, heading: frame)
                // Short circuit prevents AX hit-point errors for infinite/empty geometry.
                let hittable = usable && heading.isHittable
                let stateAfter = app.state
                let after = elapsed()
                succeeded = progress.observe(window: window, heading: frame,
                    foreground: stateBefore == .runningForeground && stateAfter == .runningForeground,
                    hittable: hittable, elapsed: after)
                observations.append("before=\(before) afterHeadingExists=\(afterHeadingExists) afterWindowExists=\(afterWindowExists) afterWindowSnapshot=\(afterWindowSnapshot) afterHeadingSnapshot=\(afterHeadingSnapshot) after=\(after) stateBefore=\(stateBefore.rawValue) stateAfter=\(stateAfter.rawValue) window=\(window) heading=\(frame) usable=\(usable) hittable=\(hittable) stableSamples=\(progress.stableSamples)")
                if succeeded { outcome = "three_stable_visible_observations"; break }
            } catch {
                outcome = "snapshot_error"
                observations.append("before=\(before) afterHeadingExists=\(afterHeadingExists) afterWindowExists=\(afterWindowExists) headingExists=\(headingExists) windowExists=\(windowExists) completedWindowAt=\(String(describing: completedWindowAt)) knownWindow=\(String(describing: knownWindow)) stateBefore=\(stateBefore.rawValue) failedStage=\(stage) after=\(elapsed()) result=snapshotError error=\(error)")
                break
            }
        }
        let finalState = app.state
        let finalElapsed = elapsed()
        let accepted = succeeded && finalElapsed < ReadinessProgress.maximumElapsed && finalState == .runningForeground
        observations.append("outcome=\(outcome) accepted=\(accepted) observations=\(progress.observations) elapsed=\(finalElapsed) finalAppState=\(finalState.rawValue)")
        let diagnostic = XCTAttachment(string: observations.joined(separator: "\n"))
        diagnostic.name = "diagnostics--readiness--" + id.replacingOccurrences(of: "/", with: "--") + "--" + state + "--" + appearance
        diagnostic.lifetime = .keepAlways
        add(diagnostic)
        return accepted
    }

    /// Capture only app-observed, nonsecret fixture inputs. Never infer these from
    /// the requested launch appearance or treat supplied media as rendered media.
    private func backdropPolicyDiagnostics(_ id: String, app: XCUIApplication) -> [String: String]? {
        guard id == "semantic/media-backdrop" || id == "shell/ambient-scroll" else { return nil }
        var facts = ["backdrop_policy_inputs_status": "unavailable",
                     "backdrop_policy_inputs_scope": "inputs_only_not_render_verification"]
        let witness = app.staticTexts["component-backdrop-policy-inputs"].firstMatch
        guard witness.waitForExistence(timeout: 5) else {
            facts["backdrop_policy_inputs_error"] = "witness_missing"
            return facts
        }
        facts["backdrop_policy_inputs_hittable"] = String(witness.isHittable)
        facts["backdrop_policy_inputs_frame"] = String(describing: witness.frame)
        // Native Text commonly uses AXValue on macOS and AXLabel on iOS. Keep
        // both actual queries, then identify which one supplied the complete witness.
        let value = witness.value as? String
        let label = witness.label
        facts["backdrop_policy_inputs_ax_value"] = value
        facts["backdrop_policy_inputs_ax_label"] = label
        let requiredKeys: Set<String> = ["colorScheme", "contrast", "reduceTransparency",
                                         "profileTranslucency", "mediaSource", "mediaPresent"]
        let candidates: [(String, String?)] = [("value", value), ("label", label)]
        for (attribute, candidate) in candidates {
            guard let text = candidate else { continue }
            let parts = text.components(separatedBy: "; ")
            guard parts.first == "backdrop-inputs/v1", parts.count == requiredKeys.count + 1 else { continue }
            let pairs = parts.dropFirst().map { $0.split(separator: "=", maxSplits: 1).map(String.init) }
            guard pairs.allSatisfy({ $0.count == 2 && !$0[1].isEmpty }),
                  Set(pairs.map { $0[0] }) == requiredKeys else { continue }
            facts["backdrop_policy_inputs_witness"] = text
            facts["backdrop_policy_inputs_ax_attribute"] = attribute
            guard witness.isHittable else {
                facts["backdrop_policy_inputs_error"] = "witness_not_visible"
                return facts
            }
            facts["backdrop_policy_inputs_status"] = "observed"
            return facts
        }
        facts["backdrop_policy_inputs_error"] = "witness_text_unavailable_or_malformed"
        return facts
    }

    private func capture(_ id: String, state: String = "default", appearance: String) throws {
        continueAfterFailure = false
        executionTimeAllowance = 600
        let app = XCUIApplication()
        app.launchEnvironment["LAYERED_KIT_COMPONENT"] = id
        app.launchEnvironment["LAYERED_KIT_COMPONENT_STATE"] = state
        app.launchEnvironment["LAYERED_KIT_APPEARANCE"] = appearance
        app.launch()
        defer { app.terminate() }
        let ready = app.staticTexts["component-ready-" + id].firstMatch
        guard app.wait(for: .runningForeground, timeout: 5) else {
            attachReadinessFailure(id, state: state, appearance: appearance, heading: ready, app: app)
            XCTFail("Component app must be foreground before capture: \(id)")
            return
        }
        // Native AX can expose the heading while the app still renders blank.
        // Observe actual hittability within a deadline; never relaunch or accept
        // mere existence as successful rendered-component evidence.
        guard waitForRenderedHeading(ready, id: id, state: state, appearance: appearance, app: app) else {
            attachReadinessFailure(id, state: state, appearance: appearance, heading: ready, app: app)
            XCTFail("Exact component route heading must exist and be visible/hittable in the foreground native window: \(id)")
            return
        }
        if state == "sheet-open" {
            let open = app.buttons["inventoryOpenSheet"].firstMatch
            XCTAssertTrue(open.isHittable)
            open.tap()
            XCTAssertTrue(app.buttons["inventoryCloseSheet"].firstMatch.waitForExistence(timeout: 5), "A native tap must present the sheet")
        }
        let stem = "component--" + id.replacingOccurrences(of: "/", with: "--") + "--" + state + "--" + appearance
        let backdropDiagnostics = backdropPolicyDiagnostics(id, app: app)
        let screenshot = XCTAttachment(screenshot: app.screenshot())
        screenshot.name = stem
        screenshot.lifetime = .keepAlways
        add(screenshot)
        var metadata: [String: String] = ["component_id": id, "state": state, "appearance": appearance,
            "capture_kind": "native_app_screenshot", "visual_review": "pending", "interaction_coverage": state == "sheet-open" ? "one_native_sheet_open_tap" : "not_implied",
            "source_revision": ProcessInfo.processInfo.environment["LAYERED_KIT_SOURCE_REVISION"] ?? "unrecorded",
            "os_version": ProcessInfo.processInfo.operatingSystemVersionString]
        if let backdropDiagnostics {
            metadata.merge(backdropDiagnostics) { _, observed in observed }
            let diagnostic = XCTAttachment(data: try JSONSerialization.data(withJSONObject: backdropDiagnostics, options: [.sortedKeys]), uniformTypeIdentifier: "public.json")
            // Keep diagnostics outside the reserved component-- capture namespace.
            diagnostic.name = "diagnostics--backdrop-policy-inputs--" + id.replacingOccurrences(of: "/", with: "--") + "--" + state + "--" + appearance
            diagnostic.lifetime = .keepAlways
            add(diagnostic)
        }
        let evidence = XCTAttachment(data: try JSONSerialization.data(withJSONObject: metadata, options: [.sortedKeys]), uniformTypeIdentifier: "public.json")
        evidence.name = stem + "--binding"
        evidence.lifetime = .keepAlways
        add(evidence)
        if let backdropDiagnostics, backdropDiagnostics["backdrop_policy_inputs_status"] != "observed" {
            XCTFail("Backdrop policy-input diagnostic unavailable for \(id); inspect retained input diagnostic and screenshot")
        }
    }

    private func matrix(_ ids: [String]) throws {
        for id in ids { for appearance in ["light", "dark"] { try capture(id, appearance: appearance) } }
    }

    func testSemanticMediaComponents() throws {
        try matrix(["semantic/media-frame", "semantic/avatar", "semantic/media-row", "semantic/media-backdrop"])
    }
    func testSemanticContentComponents() throws {
        try matrix(["semantic/labeled-value-row", "semantic/status-message", "semantic/section-header", "semantic/content-surface", "semantic/list-row", "semantic/sidebar-row"])
    }
    func testSemanticActionAndFieldComponents() throws {
        try matrix(["semantic/primary-action", "semantic/secondary-action", "semantic/text-field-modifier"])
    }
    func testCompositeIdentityAndMediaComponents() throws {
        try matrix(["composite/identity-header", "composite/media-detail-header", "composite/media-composer-header", "composite/category-rail"])
    }
    func testCompositeInputAndSelectionComponents() throws {
        try matrix(["composite/field-group", "composite/choice-row", "composite/selection-summary", "composite/conversation-composer"])
    }
    func testCompositeMessageAndRecordComponents() throws {
        try matrix(["composite/message-bubble", "composite/record-summary", "composite/utility-overlay"])
    }
    func testCompositeNativeRecipes() throws {
        try matrix(["composite/sectioned-media-collection", "composite/form-section", "composite/confirmation-content", "composite/status-content"])
    }
    func testListAndScrollShellComponents() throws {
        try matrix(["shell/flat-list", "shell/flat-scroll", "shell/grouped-form", "shell/ambient-scroll"])
    }
    func testTaskAndConversationShellComponents() throws {
        try matrix(["shell/focused-task", "shell/conversation", "shell/utility-canvas"])
    }
    func testNavigationAndHostShellComponents() throws {
        try matrix(["shell/adaptive-navigation", "shell/native-host"])
    }
    func testResolvedFoundationSamples() throws {
        XCTAssertTrue(hasFiniteArea(CGRect(x: 0, y: 0, width: 390, height: 844)))
        XCTAssertFalse(hasFiniteArea(.zero))
        XCTAssertFalse(hasFiniteArea(.null))
        XCTAssertFalse(hasFiniteArea(.infinite))
        XCTAssertFalse(hasFiniteArea(CGRect(x: CGFloat.infinity, y: 0, width: 20, height: 20)))
        XCTAssertFalse(hasFiniteArea(CGRect(x: 0, y: CGFloat.nan, width: 20, height: 20)))
        let window = CGRect(x: 0, y: 0, width: 390, height: 844)
        let heading = CGRect(x: 16, y: 100, width: 180, height: 20)
        XCTAssertFalse(ReadinessProgress.usable(window: nil, heading: heading))
        XCTAssertFalse(ReadinessProgress.usable(window: window, heading: nil))
        XCTAssertFalse(ReadinessProgress.usable(window: .infinite, heading: heading))
        XCTAssertFalse(ReadinessProgress.usable(window: window, heading: .zero))
        XCTAssertFalse(ReadinessProgress.usable(window: window, heading: heading.offsetBy(dx: 500, dy: 0)))
        let schedule = ReadinessProgress()
        XCTAssertEqual(schedule.nextObservationDelay(elapsed: 0, lastStarted: nil), 0)
        XCTAssertEqual(schedule.nextObservationDelay(elapsed: 0.25, lastStarted: 0), 1.75)
        XCTAssertEqual(schedule.nextObservationDelay(elapsed: 1.5, lastStarted: 0), 0.5,
                       "An early wake must wait the remaining monotonic interval")
        XCTAssertEqual(schedule.nextObservationDelay(elapsed: 2, lastStarted: 0), 0)
        XCTAssertEqual(schedule.nextObservationDelay(elapsed: 8, lastStarted: 0), 0,
                       "A slow AX observation needs no additional interval")
        XCTAssertEqual(schedule.nextObservationDelay(elapsed: 118.5, lastStarted: 117), 0.5)
        XCTAssertNil(schedule.nextObservationDelay(elapsed: 119, lastStarted: 118),
                     "Never request a sleep whose next observation would start at the cap")
        XCTAssertNil(schedule.nextObservationDelay(elapsed: 120, lastStarted: nil))
        XCTAssertNil(schedule.nextObservationDelay(elapsed: .infinity, lastStarted: nil))
        XCTAssertNil(schedule.nextObservationDelay(elapsed: -1, lastStarted: nil))
        var stable = ReadinessProgress()
        XCTAssertFalse(stable.observe(window: window, heading: heading, foreground: true, hittable: true, elapsed: 1))
        XCTAssertFalse(stable.observe(window: window, heading: heading, foreground: true, hittable: true, elapsed: 2))
        XCTAssertTrue(stable.observe(window: window, heading: heading, foreground: true, hittable: true, elapsed: 3))
        var anchored = ReadinessProgress()
        XCTAssertFalse(anchored.observe(window: window, heading: heading, foreground: true, hittable: true, elapsed: 1))
        XCTAssertFalse(anchored.observe(window: window, heading: heading.offsetBy(dx: 1, dy: 0), foreground: true, hittable: true, elapsed: 2))
        XCTAssertFalse(anchored.observe(window: window, heading: heading.offsetBy(dx: 2, dy: 0), foreground: true, hittable: true, elapsed: 3))
        XCTAssertEqual(anchored.stableSamples, 1, "Pairwise subpixel changes must not accumulate beyond the streak anchor")
        var tolerance = ReadinessProgress()
        XCTAssertFalse(tolerance.observe(window: window, heading: heading, foreground: true, hittable: true, elapsed: 1))
        XCTAssertFalse(tolerance.observe(window: window, heading: heading.offsetBy(dx: 1, dy: 0), foreground: true, hittable: true, elapsed: 2))
        XCTAssertTrue(tolerance.observe(window: window, heading: heading.offsetBy(dx: 1, dy: 0), foreground: true, hittable: true, elapsed: 3))
        var interrupted = ReadinessProgress()
        XCTAssertFalse(interrupted.observe(window: window, heading: heading, foreground: true, hittable: true, elapsed: 1))
        XCTAssertFalse(interrupted.observe(window: window, heading: heading, foreground: true, hittable: false, elapsed: 2))
        XCTAssertEqual(interrupted.stableSamples, 0)
        XCTAssertFalse(interrupted.observe(window: window, heading: heading, foreground: false, hittable: true, elapsed: 3))
        XCTAssertFalse(interrupted.observe(window: window, heading: heading, foreground: true, hittable: true, elapsed: 120))
        XCTAssertFalse(interrupted.canObserve(elapsed: 120))
        var exhausted = ReadinessProgress()
        for index in 0..<6 {
            XCTAssertFalse(exhausted.observe(window: nil, heading: nil, foreground: true, hittable: false, elapsed: Double(index)))
        }
        XCTAssertFalse(exhausted.canObserve(elapsed: 6))
        XCTAssertNil(exhausted.nextObservationDelay(elapsed: 6, lastStarted: 5))
        XCTAssertFalse(exhausted.observe(window: window, heading: heading, foreground: true, hittable: true, elapsed: 7))
        var moving = ReadinessProgress()
        for index in 0..<6 {
            XCTAssertFalse(moving.observe(window: window, heading: heading.offsetBy(dx: CGFloat(index * 3), dy: 0),
                                          foreground: true, hittable: true, elapsed: Double(index)))
        }
        try matrix(["primitive/corner-geometry", "foundation/color-role", "foundation/typography-role", "foundation/surface-role"])
    }
    func testExplicitAlternateStates() throws {
        for appearance in ["light", "dark"] {
            try capture("composite/category-rail", state: "empty", appearance: appearance)
            try capture("semantic/status-message", state: "error", appearance: appearance)
        }
    }
    func testAccessibleReflowSamples() throws {
        for id in ["semantic/labeled-value-row", "composite/choice-row", "composite/identity-header", "composite/conversation-composer"] {
            try capture(id, state: "accessibility", appearance: "light")
            try capture(id, state: "rtl", appearance: "dark")
        }
    }
    func testNativeSheetPresentation() throws {
        for appearance in ["light", "dark"] {
            try capture("native/presentation-and-share-recipe", state: "sheet-open", appearance: appearance)
        }
    }
    func testNativeRecipeSamples1() throws {
        try matrix(["native/button-and-toolbar-action-recipe", "native/content-unavailable-view-recipe", "native/elevated-background-recipe", "native/hierarchical-style-recipe"])
    }
    func testNativeRecipeSamples2() throws {
        try matrix(["native/list-sidebar-and-disclosure-recipe", "native/material-and-glass-surface-recipe", "native/menu-context-and-edit-actions-recipe", "native/navigation-tabs-and-toolbars-recipe"])
    }
    func testNativeRecipeSamples3() throws {
        try matrix(["native/picker-and-date-color-input-recipe", "native/presentation-and-share-recipe", "native/progress-slider-stepper-recipe", "native/text-search-and-keyboard-input-recipe"])
    }

}
