extension LocalDemoDefinition {
  static let mobilityDefinitions: [Self] = [
    .init(
      id: "demo.mobility.flight-tracker", section: .mobility,
      title: "Flight Tracker", flowLabel: "Trips board → live flight",
      symbolName: "airplane", imageAssetName: "demo-flight-tracker-thumbnail",
      tint: .flightBlue, entryDestination: .flightTrackerBoard,
      detailDestination: .flightTrackerLive,
      states: [
        .init(
          id: "flight-tracker.trips-board", title: "Trips board", view: "FlightTrackerBoardDemoView"
        ),
        .init(
          id: "flight-tracker.live-flight", title: "Live flight", view: "FlightTrackerLiveDemoView"),
      ],
      patterns: ["Dense trip board", "Live route and status card"],
      nativeAPIs: ["MapKit", "MapPolyline", "NavigationLink", "ScrollView", "Button"],
      sourcePaths: flightTrackerPaths,
      assetNames: ["demo-flight-tracker-thumbnail"],
      platforms: applePlatforms, distribution: .localOnly),
    .init(
      id: "demo.mobility.city-ride", section: .mobility,
      title: "City Ride", flowLabel: "Vehicle selection → driver tracking",
      symbolName: "car.fill", imageAssetName: "demo-city-ride-thumbnail",
      tint: .cityGreen, entryDestination: .cityRideSelection,
      detailDestination: .cityRideTracking,
      states: [
        .init(
          id: "city-ride.vehicle-selection", title: "Vehicle selection",
          view: "CityRideSelectionDemoView"),
        .init(
          id: "city-ride.driver-tracking", title: "Driver tracking",
          view: "CityRideTrackingDemoView"),
      ],
      patterns: ["Map-backed vehicle sheet", "Driver ETA and contact card"],
      nativeAPIs: ["MapKit", "MapPolyline", "NavigationLink", "ScrollView", "Button"],
      sourcePaths: cityRidePaths,
      assetNames: ["demo-city-ride-thumbnail", "city-ride-arrival-essentials"],
      platforms: applePlatforms, distribution: .localOnly),
  ]

  private static let sharedPaths = ["MobilityDemoTheme", "MobilityMapField", "MobilityMapLayers"]
    .map { "App/Shared/Flows/Mobility/\($0).swift" }
  private static let flightTrackerPaths =
    ["FlightTrackerBoardDemoView", "FlightTrackerLiveDemoView", "FlightTripPicker"]
    .map { "App/Shared/Flows/Mobility/\($0).swift" } + sharedPaths + sharedMotionPaths
  private static let cityRidePaths =
    ["CityRideSelectionDemoView", "CityRideTrackingDemoView", "CityRideNotice"]
    .map { "App/Shared/Flows/Mobility/\($0).swift" } + sharedPaths + sharedMotionPaths
}
