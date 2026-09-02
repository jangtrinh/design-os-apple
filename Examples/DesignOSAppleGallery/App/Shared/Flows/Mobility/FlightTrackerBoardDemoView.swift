import SwiftUI

struct FlightTrackerBoardDemoView: View {
  @Environment(\.accessibilityReduceMotion) private var reduceMotion
  @State private var showsFilters = false
  @State private var showsMapOptions = false
  @State private var selectedFilter: FlightTripFilter = .myTrips

  private let trips = [
    FlightBoardTrip(
      dayOffset: "2", number: "NX 204", date: "Fri, 15 Sep", from: "OSL", departure: "4:00 PM",
      to: "LIS", arrival: "8:15 PM", route: "Oslo to Lisbon"),
    FlightBoardTrip(
      dayOffset: "8", number: "NX 622", date: "Thu, 21 Sep", from: "DFW", departure: "12:15 PM",
      to: "DXB", arrival: "11:55 AM", route: "Dallas to Dubai"),
  ]

  var body: some View {
    GeometryReader { proxy in
      ZStack(alignment: .bottom) {
        MobilityMapField(style: .flightBoard)
          .frame(height: proxy.size.height * 0.48)
          .frame(maxHeight: .infinity, alignment: .top)
        mapControl
        MobilitySheet { boardContent }
          .frame(height: proxy.size.height * 0.55)
      }
    }
    .background(MobilityDemoTheme.flightOcean)
    .ignoresSafeArea(edges: [.top, .bottom])
    #if os(iOS)
      .toolbarBackground(.hidden, for: .navigationBar)
    #endif
    .localDemoRootIdentifier("design-os.demo.mobility.flight-tracker.board")
    .alert("Map options", isPresented: $showsMapOptions) {
      Button("Done", role: .cancel) {}
    } message: {
      Text("Route layers are ready for this local flight demo.")
    }
  }

  private var mapControl: some View {
    VStack {
      HStack {
        Spacer()
        Button {
          showsMapOptions = true
        } label: {
          MobilityCircularControl(symbol: "map.fill", label: "Map options")
        }
        .buttonStyle(LocalDemoPressButtonStyle())
      }
      Spacer()
    }
    .padding(.horizontal, 16)
    .padding(.top, 52)
  }

  private var boardContent: some View {
    ZStack(alignment: .topLeading) {
      VStack(spacing: 0) {
        header
        Color.clear.frame(height: 4)
        ForEach(Array(filteredTrips.enumerated()), id: \.element.id) { index, trip in
          NavigationLink(value: .flightTrackerLive as LocalDemoDestination) {
            FlightBoardTripRow(trip: trip)
          }
          .buttonStyle(.plain)
          .localDemoTransitionSource(.flightTrackerLive)
          .accessibilityIdentifier(
            index == 0
              ? "design-os.demo.mobility.flight-tracker.open-live"
              : "design-os.demo.mobility.flight-tracker.open-live-secondary")
          Divider().padding(.leading, 70)
        }
      }

      if showsFilters {
        FlightTripFilterPanel(selectedFilter: $selectedFilter)
          .offset(x: -6, y: 42)
          .transition(LocalDemoInteractionMotion.disclosure(reduceMotion: reduceMotion))
      }
    }
  }

  private var header: some View {
    FlightTripHeader(showsFilters: $showsFilters, selectedFilter: $selectedFilter)
  }

  private var filteredTrips: [FlightBoardTrip] {
    switch selectedFilter {
    case .myTrips: trips
    case .sharedTrips: Array(trips.suffix(1))
    case .today: Array(trips.prefix(1))
    }
  }
}

private struct FlightBoardTrip: Identifiable {
  var id: String { number }
  let dayOffset: String
  let number: String
  let date: String
  let from: String
  let departure: String
  let to: String
  let arrival: String
  let route: String
}

private struct FlightBoardTripRow: View {
  let trip: FlightBoardTrip

  var body: some View {
    HStack(spacing: 12) {
      VStack(spacing: 0) {
        Text(trip.dayOffset).font(.title.bold())
        Text("DAYS").font(.caption).foregroundStyle(.secondary)
      }
      .frame(width: 48)

      VStack(alignment: .leading, spacing: 7) {
        HStack {
          Label(trip.number, systemImage: "airplane.departure").font(.caption).foregroundStyle(
            .secondary)
          Spacer()
          Text(trip.date).font(.caption).foregroundStyle(.secondary)
        }
        Text(trip.route).font(.subheadline.weight(.semibold))
        HStack(spacing: 8) {
          flightTime(trip.from, trip.departure)
          Image(systemName: "arrow.right").font(.caption).foregroundStyle(.secondary)
          flightTime(trip.to, trip.arrival)
          Spacer()
          Text("+1").font(.caption).foregroundStyle(.secondary)
        }
      }
    }
    .padding(.vertical, 13)
    .frame(minHeight: 138)
    .contentShape(Rectangle())
  }

  private func flightTime(_ code: String, _ time: String) -> some View {
    HStack(spacing: 3) {
      Text(code).font(.caption).foregroundStyle(.secondary)
      Text(time).font(.subheadline.weight(.semibold))
    }
  }
}
