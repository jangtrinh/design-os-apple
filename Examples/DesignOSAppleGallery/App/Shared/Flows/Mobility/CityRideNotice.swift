import Foundation

enum CityRideNotice: String, Identifiable {
  case safety, airport, message, call, route, recenter, arrival

  var id: String { rawValue }

  var title: String {
    switch self {
    case .safety: "Safety Center"
    case .airport: "Airport ride planning"
    case .message: "Message driver"
    case .call: "Call driver"
    case .route: "Route options"
    case .recenter: "Route centered"
    case .arrival: "Arrival options"
    }
  }

  var message: String {
    switch self {
    case .safety: "Share this trip or contact local emergency services."
    case .airport: "Choose a pickup time before your next airport trip."
    case .message: "A local message composer is ready for this reusable demo."
    case .call: "A local call handoff is ready for this reusable demo."
    case .route: "Directions and route alternatives are ready for this local demo."
    case .recenter: "The map is centered on the active route."
    case .arrival: "Arrival essentials can be saved or shared from this local demo."
    }
  }
}
