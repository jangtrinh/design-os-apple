import SwiftUI

struct FlightTrackerLiveDemoView: View {
  @Environment(\.accessibilityReduceMotion) private var reduceMotion
  @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
  @State private var isMapLayerActive = true
  @State private var isWeatherVisible = true
  @State private var searchQuery = ""
  @State private var selectedFilter: FlightTripFilter = .myTrips
  @State private var showsFilters = false

  var body: some View {
    GeometryReader { proxy in
      ZStack(alignment: .bottom) {
        MobilityMapField(
          style: .flightLive,
          showsRoute: isMapLayerActive,
          showsWeather: isWeatherVisible
        )
        .frame(height: proxy.size.height * 0.69)
        .frame(maxHeight: .infinity, alignment: .top)
        liveMapControls
        MobilitySheet { flightCard }
          .frame(height: proxy.size.height * 0.36)
      }
    }
    .background(.black)
    .ignoresSafeArea(edges: [.top, .bottom])
    #if os(iOS)
      .toolbarBackground(.hidden, for: .navigationBar)
      .toolbarColorScheme(.dark, for: .navigationBar)
    #endif
    .localDemoRootIdentifier("design-os.demo.mobility.flight-tracker.live")
  }

  private var liveMapControls: some View {
    VStack {
      HStack {
        Spacer()
        VStack(spacing: 0) {
          mapToggle(
            isMapLayerActive ? "map.fill" : "map",
            label: "Route layer",
            identifier: "design-os.demo.mobility.flight-tracker.route-layer",
            isActive: $isMapLayerActive)
          Divider().frame(width: 24)
          mapToggle(
            isWeatherVisible ? "cloud.fill" : "cloud",
            label: "Weather layer",
            identifier: "design-os.demo.mobility.flight-tracker.weather-layer",
            isActive: $isWeatherVisible)
        }
        .foregroundStyle(.white)
        .background(reduceTransparency ? .black : .black.opacity(0.68), in: Capsule())
      }
      Spacer()
    }
    .padding(.horizontal, 16)
    .padding(.top, 52)
  }

  private func mapToggle(
    _ symbol: String, label: String, identifier: String, isActive: Binding<Bool>
  ) -> some View {
    Button {
      withAnimation(LocalDemoInteractionMotion.animation(reduceMotion: reduceMotion)) {
        isActive.wrappedValue.toggle()
      }
    } label: {
      Image(systemName: symbol)
        .contentTransition(.symbolEffect(.replace))
        .frame(width: 44, height: 44)
    }
    .buttonStyle(LocalDemoPressButtonStyle())
    .accessibilityLabel(label)
    .accessibilityValue(isActive.wrappedValue ? "On" : "Off")
    .accessibilityIdentifier(identifier)
  }

  private var flightCard: some View {
    ZStack(alignment: .topLeading) {
      VStack(spacing: 14) {
        FlightTripHeader(showsFilters: $showsFilters, selectedFilter: $selectedFilter)

        HStack(spacing: 8) {
          Image(systemName: "magnifyingglass").foregroundStyle(.secondary)
          TextField("Search to add flights", text: $searchQuery)
            .font(.subheadline)
        }
        .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
        .padding(.horizontal, 12)
        .background(MobilityDemoTheme.softFill, in: RoundedRectangle(cornerRadius: 12))
        .accessibilityLabel("Search to add flights")

        HStack(alignment: .bottom, spacing: 14) {
          VStack(spacing: -1) {
            Text("5h").font(.title.bold())
            Text("41 MINUTES").font(.caption).foregroundStyle(.secondary)
          }
          VStack(alignment: .leading, spacing: 5) {
            HStack(spacing: 0) {
              Label("NX 438", systemImage: "point.3.connected.trianglepath.dotted")
              Spacer()
              Text("Departs ").foregroundStyle(.secondary)
              Text("On Time").foregroundStyle(.green)
            }
            .font(.caption)
            Text("Jakarta to Seoul").font(.subheadline.weight(.semibold))
            HStack(spacing: 8) {
              airport("CKG", "9:50 PM")
              Image(systemName: "arrow.right").font(.caption).foregroundStyle(.secondary)
              airport("ICN", "6:50 AM +1")
            }
          }
        }
        .accessibilityIdentifier("design-os.demo.mobility.flight-tracker.airport-status")
      }

      if showsFilters {
        FlightTripFilterPanel(selectedFilter: $selectedFilter)
          .offset(x: -6, y: 48)
          .transition(LocalDemoInteractionMotion.disclosure(reduceMotion: reduceMotion))
      }
    }
  }

  private func airport(_ code: String, _ time: String) -> some View {
    HStack(spacing: 4) {
      Image(systemName: "arrow.up.right.circle.fill").foregroundStyle(.green)
      Text(code).foregroundStyle(.secondary)
      Text(time).fontWeight(.semibold)
    }
    .font(.caption)
  }
}
