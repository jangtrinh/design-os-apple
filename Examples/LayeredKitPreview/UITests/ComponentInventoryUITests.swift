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
            facts.append("headingFrame=\(heading.frame) hittable=\(heading.isHittable)")
        }
        let hierarchy = XCTAttachment(string: facts.joined(separator: "\n") + "\n\n" + app.debugDescription)
        hierarchy.name = stem + "--accessibility"
        hierarchy.lifetime = .keepAlways
        add(hierarchy)
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
        let rendered = XCTNSPredicateExpectation(
            predicate: NSPredicate(format: "exists == true AND hittable == true"), object: ready)
        guard XCTWaiter.wait(for: [rendered], timeout: 10) == .completed,
              app.state == .runningForeground else {
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
