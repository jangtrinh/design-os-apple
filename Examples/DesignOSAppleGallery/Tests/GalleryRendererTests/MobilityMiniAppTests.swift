import Foundation
import XCTest

final class MobilityMiniAppTests: XCTestCase {
  func testMobilityStatesExposeStableRootsAndValueNavigation() throws {
    let source = try mobilitySource()

    XCTAssertTrue(source.contains("struct FlightTrackerBoardDemoView"))
    XCTAssertTrue(source.contains("struct FlightTrackerLiveDemoView"))
    XCTAssertTrue(source.contains("struct CityRideSelectionDemoView"))
    XCTAssertTrue(source.contains("struct CityRideTrackingDemoView"))
    XCTAssertTrue(source.contains("NavigationLink(value: .flightTrackerLive"))
    XCTAssertTrue(source.contains("NavigationLink(value: .cityRideTracking"))

    let stableIdentifiers = [
      "design-os.demo.mobility.flight-tracker.board",
      "design-os.demo.mobility.flight-tracker.open-live",
      "design-os.demo.mobility.flight-tracker.live",
      "design-os.demo.mobility.city-ride.selection",
      "design-os.demo.mobility.city-ride.open-tracking",
      "design-os.demo.mobility.city-ride.tracking",
    ]
    for identifier in stableIdentifiers {
      XCTAssertTrue(source.contains(identifier), "Missing stable identifier: \(identifier)")
    }
    XCTAssertFalse(source.contains("NavigationStack"))
  }

  func testCriticalReferenceAnchorsRemainCodeNativeAndGeneric() throws {
    let source = try mobilitySource()
    let anchors = [
      "design-os.demo.mobility.flight-route-arc",
      "design-os.demo.mobility.flight-tracker.airport-status",
      "design-os.demo.mobility.city-ride.vehicle-sheet",
      "design-os.demo.mobility.city-route",
      "design-os.demo.mobility.city-ride.driver-eta",
      "design-os.demo.mobility.city-ride.contact-card",
    ]
    for anchor in anchors {
      XCTAssertTrue(source.contains(anchor), "Missing critical anchor: \(anchor)")
    }

    XCTAssertTrue(source.contains("Map(initialPosition:"))
    XCTAssertTrue(source.contains("MapPolyline"))
    XCTAssertTrue(source.contains("Image(\"city-ride-arrival-essentials\")"))
    XCTAssertFalse(source.contains("Image(\"city-map"), "Mobility maps must remain native")

    let forbiddenBrands = ["Flighty", "Mobbin", "Grab", "Uber", "Google Maps", "Apple Maps"]
    for brand in forbiddenBrands {
      XCTAssertFalse(source.localizedCaseInsensitiveContains(brand), "Forbidden brand: \(brand)")
    }
  }

  func testTransientPanelsAndBottomSheetsRespectTheirLayoutState() throws {
    let board = try mobilitySource(named: "FlightTrackerBoardDemoView")
    let tripPicker = try mobilitySource(named: "FlightTripPicker")
    XCTAssertTrue(board.contains("@State private var showsFilters = false"))
    XCTAssertTrue(
      tripPicker.contains("design-os.demo.mobility.flight-tracker.trip-filter-panel"))
    XCTAssertTrue(tripPicker.contains("design-os.demo.mobility.flight-tracker.trip-list-title"))
    XCTAssertTrue(
      tripPicker.contains("accessibilityValue(showsFilters ? \"Expanded\" : \"Collapsed\")"))

    for name in [
      "FlightTrackerBoardDemoView", "FlightTrackerLiveDemoView",
      "CityRideSelectionDemoView", "CityRideTrackingDemoView",
    ] {
      XCTAssertTrue(
        try mobilitySource(named: name).contains(".ignoresSafeArea(edges: [.top, .bottom])"),
        "\(name) must cover both vertical safe areas")
    }

    for name in ["CityRideSelectionDemoView", "CityRideTrackingDemoView"] {
      let source = try mobilitySource(named: name)
      XCTAssertTrue(source.contains("VStack(spacing: 0)"))
      XCTAssertFalse(source.contains("ZStack(alignment: .bottom)"))
    }

    let tracking = try mobilitySource(named: "CityRideTrackingDemoView")
    XCTAssertTrue(tracking.contains("Label(\"Safety Center\", systemImage: \"shield.checkered\")"))
    XCTAssertTrue(tracking.contains("design-os.demo.mobility.city-ride.safety-center"))
    XCTAssertTrue(tracking.contains("design-os.demo.mobility.city-ride.airport-advertisement"))
    XCTAssertFalse(tracking.contains("Text(\"Safety tools\")"))
    XCTAssertTrue(tracking.contains("@State private var activeNotice: CityRideNotice?"))
    XCTAssertTrue(tracking.contains(".alert(item: $activeNotice)"))
    XCTAssertTrue(tracking.contains("activeNotice = .safety"))
    XCTAssertTrue(tracking.contains("activeNotice = .airport"))
    XCTAssertTrue(tracking.contains("activeNotice = .message"))
    XCTAssertTrue(tracking.contains("activeNotice = .call"))
  }

  func testFlightControlsMutateRenderedContentRatherThanOnlyTheirGlyphs() throws {
    let board = try mobilitySource(named: "FlightTrackerBoardDemoView")
    let live = try mobilitySource(named: "FlightTrackerLiveDemoView")
    let map = try mobilitySource(named: "MobilityMapField")
    let controls = try mobilitySource(named: "FlightTripPicker")

    XCTAssertTrue(board.contains("ForEach(Array(filteredTrips.enumerated())"))
    XCTAssertTrue(board.contains("FlightTripFilterPanel(selectedFilter: $selectedFilter)"))
    XCTAssertTrue(live.contains("showsRoute: isMapLayerActive"))
    XCTAssertTrue(live.contains("showsWeather: isWeatherVisible"))
    XCTAssertTrue(map.contains("style == .flightLive && showsWeather"))
    XCTAssertTrue(controls.contains("@Binding var selectedFilter: FlightTripFilter"))
    XCTAssertTrue(live.contains("accessibilityReduceTransparency"))
  }

  func testMobilitySemanticSurfacesAdaptWithoutAForcedLightSubtree() throws {
    let source = try mobilitySource()
    let theme = try mobilitySource(named: "MobilityDemoTheme")

    XCTAssertFalse(source.contains(".environment(\\.colorScheme, .light)"))
    XCTAssertFalse(source.contains(".background(.white"))
    for role in [
      "cityInk", "secondaryInk", "paper", "softFill", "controlFill", "safetyFill",
      "airportFill",
    ] {
      XCTAssertTrue(
        theme.contains("static let \(role) = Color.localDemoAdaptive"),
        "Mobility \(role) must adapt with appearance"
      )
    }
  }

  func testArrivalPromotionPreservesReferenceDensityAndOfferHierarchy() throws {
    let tracking = try mobilitySource(named: "CityRideTrackingDemoView")
    let promotion = try mobilitySource(named: "CityRideArrivalPromotion")

    XCTAssertTrue(tracking.contains("CityRideArrivalPromotion"))
    XCTAssertTrue(promotion.contains("private var arrivalPromotionOverlay"))
    XCTAssertTrue(promotion.contains("Terminal-ready essentials"))
    XCTAssertTrue(promotion.contains("A compact guide for pickup day"))
    XCTAssertTrue(promotion.contains("Button(action: onOptions)"))
    XCTAssertTrue(promotion.contains("dynamicTypeSize.isAccessibilitySize"))
    XCTAssertTrue(promotion.contains("accessibilityPromotion"))
    XCTAssertTrue(promotion.contains(".frame(height: 112)"))
  }

  private func mobilitySource() throws -> String {
    let folder = galleryRoot.appendingPathComponent("App/Shared/Flows/Mobility")
    let files = try FileManager.default.contentsOfDirectory(
      at: folder, includingPropertiesForKeys: nil
    )
    .filter { $0.pathExtension == "swift" }
    .sorted { $0.lastPathComponent < $1.lastPathComponent }
    return try files.map { try String(contentsOf: $0, encoding: .utf8) }.joined(separator: "\n")
  }

  private func mobilitySource(named name: String) throws -> String {
    let file =
      galleryRoot
      .appendingPathComponent("App/Shared/Flows/Mobility")
      .appendingPathComponent("\(name).swift")
    return try String(contentsOf: file, encoding: .utf8)
  }

  private var galleryRoot: URL {
    URL(fileURLWithPath: #filePath)
      .deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
  }
}
