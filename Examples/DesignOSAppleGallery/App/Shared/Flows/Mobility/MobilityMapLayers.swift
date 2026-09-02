import MapKit
import SwiftUI

struct NativeMobilityMap: View {
  let style: MobilityMapStyle
  var showsRoute = true

  var body: some View {
    Map(initialPosition: cameraPosition, interactionModes: []) {
      if showsRoute {
        MapPolyline(coordinates: route)
          .stroke(routeColor.opacity(0.22), lineWidth: routeHaloWidth)
        MapPolyline(coordinates: route)
          .stroke(
            routeColor,
            style: StrokeStyle(lineWidth: routeLineWidth, lineCap: .round, lineJoin: .round)
          )

        if style == .cityTracking {
          MapPolyline(coordinates: trafficSegment)
            .stroke(.red, style: StrokeStyle(lineWidth: 5, lineCap: .round))
        }

        ForEach(markers) { marker in
          Annotation(marker.label, coordinate: marker.coordinate, anchor: .center) {
            Image(systemName: marker.symbol)
              .font(.caption.weight(.bold))
              .foregroundStyle(marker.tint)
              .frame(width: 30, height: 30)
              .background(MobilityDemoTheme.controlFill, in: Circle())
              .shadow(color: .black.opacity(0.24), radius: 3, y: 2)
          }
        }
      }
    }
    .mapStyle(mapStyle)
    .mapControlVisibility(.hidden)
    .ignoresSafeArea()
  }

  private var cameraPosition: MapCameraPosition {
    switch style {
    case .citySelection:
      .camera(MapCamera(centerCoordinate: .cityCenter, distance: 1_750, heading: 8, pitch: 0))
    case .cityTracking:
      .camera(MapCamera(centerCoordinate: .cityCenter, distance: 1_500, heading: 4, pitch: 0))
    case .flightBoard:
      .camera(MapCamera(centerCoordinate: .hudsonBay, distance: 5_700_000, heading: 12, pitch: 0))
    case .flightLive:
      .camera(MapCamera(centerCoordinate: .indianOcean, distance: 23_000_000, heading: 8, pitch: 0))
    }
  }

  private var mapStyle: MapStyle {
    switch style {
    case .citySelection, .cityTracking:
      .standard(elevation: .flat, emphasis: .muted, pointsOfInterest: .all, showsTraffic: true)
    case .flightBoard:
      .imagery(elevation: .flat)
    case .flightLive:
      .imagery(elevation: .realistic)
    }
  }

  private var route: [CLLocationCoordinate2D] {
    switch style {
    case .citySelection: [.cityPickup, .cityCenter, .cityNorth]
    case .cityTracking: [.cityPickup, .cityWest, .cityNorth, .cityCenter]
    case .flightBoard: [.vancouver, .hudsonBay, .reykjavik]
    case .flightLive: [.jakarta, .southChinaSea, .seoul]
    }
  }

  private var trafficSegment: [CLLocationCoordinate2D] {
    [.cityWest, CLLocationCoordinate2D(latitude: -6.245, longitude: 106.651)]
  }

  private var routeColor: Color {
    switch style {
    case .flightBoard, .flightLive: MobilityDemoTheme.flightBlue
    case .citySelection, .cityTracking: MobilityDemoTheme.cityGreen
    }
  }

  private var routeHaloWidth: CGFloat {
    switch style {
    case .flightBoard: 5
    case .flightLive: 6
    case .citySelection, .cityTracking: 10
    }
  }

  private var routeLineWidth: CGFloat {
    switch style {
    case .flightBoard: 2
    case .flightLive: 2.5
    case .citySelection, .cityTracking: 4
    }
  }

  private var markers: [MobilityMapMarker] {
    switch style {
    case .citySelection:
      [
        .init(label: "Pickup", coordinate: .cityPickup, symbol: "location.fill", tint: .blue),
        .init(
          label: "Eco", coordinate: .cityCenter, symbol: "car.side.fill",
          tint: MobilityDemoTheme.cityGreen),
        .init(
          label: "Plus", coordinate: .cityNorth, symbol: "car.side.fill",
          tint: MobilityDemoTheme.cityGreen),
      ]
    case .cityTracking:
      [
        .init(label: "You", coordinate: .cityPickup, symbol: "location.fill", tint: .blue),
        .init(label: "Driver", coordinate: .cityWest, symbol: "car.side.fill", tint: .black),
      ]
    case .flightBoard:
      [
        .init(
          label: "Vancouver", coordinate: .vancouver, symbol: "airplane.departure", tint: .white),
        .init(label: "Reykjavik", coordinate: .reykjavik, symbol: "airplane.arrival", tint: .white),
      ]
    case .flightLive:
      [
        .init(label: "Jakarta", coordinate: .jakarta, symbol: "airplane.departure", tint: .white),
        .init(label: "Seoul", coordinate: .seoul, symbol: "airplane.arrival", tint: .white),
      ]
    }
  }
}

private struct MobilityMapMarker: Identifiable {
  var id: String { label }
  let label: String
  let coordinate: CLLocationCoordinate2D
  let symbol: String
  let tint: Color
}

extension CLLocationCoordinate2D {
  fileprivate static let cityCenter = Self(latitude: -6.244, longitude: 106.655)
  fileprivate static let cityPickup = Self(latitude: -6.249, longitude: 106.656)
  fileprivate static let cityWest = Self(latitude: -6.243, longitude: 106.648)
  fileprivate static let cityNorth = Self(latitude: -6.237, longitude: 106.658)
  fileprivate static let vancouver = Self(latitude: 49.2827, longitude: -123.1207)
  fileprivate static let hudsonBay = Self(latitude: 57.0, longitude: -84.0)
  fileprivate static let reykjavik = Self(latitude: 64.1466, longitude: -21.9426)
  fileprivate static let jakarta = Self(latitude: -6.2088, longitude: 106.8456)
  fileprivate static let southChinaSea = Self(latitude: 13.0, longitude: 112.0)
  fileprivate static let seoul = Self(latitude: 37.5665, longitude: 126.9780)
  fileprivate static let indianOcean = Self(latitude: -8.0, longitude: 93.0)
}
