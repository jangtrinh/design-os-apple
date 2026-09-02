import SwiftUI

struct CityRideSelectionDemoView: View {
  @Environment(\.accessibilityReduceMotion) private var reduceMotion
  @State private var selectedRide: String?

  private let rides = [
    CityRideOption(
      name: "Eco", seats: "4 seats", eta: "4 min", fare: "$12.40", symbol: "car.side.fill"),
    CityRideOption(
      name: "Plus", seats: "6 seats", eta: "7 min", fare: "$18.90", symbol: "suv.side.fill"),
  ]

  var body: some View {
    GeometryReader { proxy in
      VStack(spacing: 0) {
        MobilityMapField(style: .citySelection)
          .frame(height: proxy.size.height * 0.40)
        MobilitySheet { selectionSheet }
          .frame(maxHeight: .infinity)
      }
      .frame(width: proxy.size.width, height: proxy.size.height)
    }
    .background(MobilityDemoTheme.paper)
    .ignoresSafeArea(edges: [.top, .bottom])
    #if os(iOS)
      .toolbarBackground(.hidden, for: .navigationBar)
    #endif
    .localDemoRootIdentifier("design-os.demo.mobility.city-ride.selection")
  }

  private var selectionSheet: some View {
    VStack(spacing: 12) {
      Capsule().fill(.secondary.opacity(0.55)).frame(width: 40, height: 4)
      HStack(alignment: .bottom) {
        VStack(alignment: .leading, spacing: 4) {
          Text("Choose your ride").font(.headline)
          Text("Standard  |  Electric").font(.caption).foregroundStyle(.secondary)
        }
        Spacer()
        Image(systemName: "car.top.door.front.left.open.fill").font(.title).foregroundStyle(
          MobilityDemoTheme.cityGreen)
      }
      progressRail

      VStack(spacing: 0) {
        VStack(alignment: .leading, spacing: 3) {
          Text("Add more ride types?").font(.subheadline.weight(.semibold))
          Text("We'll match the first available driver.").font(.caption).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        Divider()

        Text("Standard car")
          .font(.caption.weight(.semibold))
          .frame(maxWidth: .infinity, alignment: .leading)
          .padding(.horizontal, 14).frame(height: 28)
        rideButton(rides[0])
        Divider().padding(.leading, 58)
        Text("6 seat car")
          .font(.caption.weight(.semibold))
          .frame(maxWidth: .infinity, alignment: .leading)
          .padding(.horizontal, 14).frame(height: 28)
        rideButton(rides[1])
      }
      .background(MobilityDemoTheme.controlFill, in: RoundedRectangle(cornerRadius: 16))
      .overlay(RoundedRectangle(cornerRadius: 16).stroke(.gray.opacity(0.2)))

      NavigationLink(value: .cityRideTracking as LocalDemoDestination) {
        Text(selectedRide.map { "Confirm \($0)" } ?? "Choose a ride")
          .font(.headline)
          .foregroundStyle(selectedRide == nil ? Color.gray : Color.white)
          .frame(maxWidth: .infinity, minHeight: 50)
          .background(
            selectedRide == nil ? Color.gray.opacity(0.12) : MobilityDemoTheme.cityGreen,
            in: Capsule())
      }
      .buttonStyle(.plain)
      .localDemoTransitionSource(.cityRideTracking)
      .disabled(selectedRide == nil)
      .accessibilityIdentifier("design-os.demo.mobility.city-ride.open-tracking")
    }
    .localDemoRootIdentifier("design-os.demo.mobility.city-ride.vehicle-sheet")
  }

  private func rideButton(_ ride: CityRideOption) -> some View {
    Button {
      withAnimation(LocalDemoInteractionMotion.animation(reduceMotion: reduceMotion)) {
        selectedRide = ride.name
      }
    } label: {
      CityRideOptionRow(ride: ride, isSelected: selectedRide == ride.name)
    }
    .buttonStyle(LocalDemoPressButtonStyle())
    .accessibilityIdentifier(
      "design-os.demo.mobility.city-ride.option.\(ride.name.lowercased())")
  }

  private var progressRail: some View {
    HStack(spacing: 8) {
      Capsule().fill(MobilityDemoTheme.cityGreen).frame(height: 3)
      Capsule().fill(.gray.opacity(0.2)).frame(height: 3)
    }
  }
}

private struct CityRideOption: Identifiable {
  var id: String { name }
  let name: String
  let seats: String
  let eta: String
  let fare: String
  let symbol: String
}

private struct CityRideOptionRow: View {
  let ride: CityRideOption
  let isSelected: Bool

  var body: some View {
    HStack(spacing: 12) {
      Image(systemName: ride.symbol).font(.title2).foregroundStyle(MobilityDemoTheme.cityGreen)
        .frame(width: 42)
      VStack(alignment: .leading, spacing: 3) {
        Text(ride.name).font(.subheadline.weight(.semibold))
        Text("\(ride.seats) · \(ride.eta) away").font(.caption).foregroundStyle(.secondary)
      }
      Spacer()
      Text(ride.fare).font(.subheadline.weight(.semibold))
      Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
        .foregroundStyle(isSelected ? MobilityDemoTheme.cityGreen : .secondary)
    }
    .padding(.horizontal, 14).frame(minHeight: 64)
    .contentShape(Rectangle())
  }
}
