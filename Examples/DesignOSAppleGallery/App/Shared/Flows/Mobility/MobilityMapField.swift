import MapKit
import SwiftUI

enum MobilityMapStyle: Equatable {
  case flightBoard
  case flightLive
  case citySelection
  case cityTracking
}

struct MobilityMapField: View {
  let style: MobilityMapStyle
  var showsRoute = true
  var showsWeather = false

  var body: some View {
    NativeMobilityMap(style: style, showsRoute: showsRoute)
      .overlay { cityMarkerOverlay }
      .overlay { weatherOverlay }
      .accessibilityElement(children: .ignore)
      .accessibilityLabel(mapLabel)
      .accessibilityIdentifier(mapIdentifier)
  }

  @ViewBuilder private var weatherOverlay: some View {
    if style == .flightLive && showsWeather {
      GeometryReader { proxy in
        ZStack {
          cloud(at: CGPoint(x: proxy.size.width * 0.28, y: proxy.size.height * 0.32))
          cloud(at: CGPoint(x: proxy.size.width * 0.72, y: proxy.size.height * 0.55))
        }
      }
      .allowsHitTesting(false)
      .transition(.opacity)
      .accessibilityHidden(true)
    }
  }

  private func cloud(at point: CGPoint) -> some View {
    Image(systemName: "cloud.fill")
      .font(.title2)
      .foregroundStyle(.white.opacity(0.72))
      .shadow(color: .black.opacity(0.3), radius: 4, y: 2)
      .position(point)
  }

  @ViewBuilder private var cityMarkerOverlay: some View {
    if style == .citySelection || style == .cityTracking {
      GeometryReader { proxy in
        ZStack {
          mapMarker(
            symbol: style == .cityTracking ? "car.side.fill" : "car.top.radiowaves.front.fill",
            tint: style == .cityTracking ? .black : MobilityDemoTheme.cityGreen
          )
          .position(x: proxy.size.width * 0.44, y: proxy.size.height * 0.44)

          if style == .citySelection {
            mapMarker(symbol: "car.side.fill", tint: MobilityDemoTheme.cityGreen)
              .position(x: proxy.size.width * 0.68, y: proxy.size.height * 0.60)
          }
        }
      }
      .allowsHitTesting(false)
    }
  }

  private func mapMarker(symbol: String, tint: Color) -> some View {
    Image(systemName: symbol)
      .font(.caption.weight(.bold)).foregroundStyle(tint)
      .frame(width: 30, height: 30)
      .background(MobilityDemoTheme.controlFill, in: Circle())
      .shadow(color: .black.opacity(0.24), radius: 3, y: 2)
  }

  private var mapLabel: String {
    switch style {
    case .flightBoard: "Map showing scheduled flight paths"
    case .flightLive: "Live flight map with route arc"
    case .citySelection: "City map showing nearby vehicles"
    case .cityTracking: "City map showing the driver's route"
    }
  }

  private var mapIdentifier: String {
    switch style {
    case .flightBoard: "design-os.demo.mobility.flight-map-board"
    case .flightLive: "design-os.demo.mobility.flight-route-arc"
    case .citySelection: "design-os.demo.mobility.city-map-selection"
    case .cityTracking: "design-os.demo.mobility.city-route"
    }
  }

}
