import SwiftUI

struct FlightTripHeader: View {
  @Environment(\.accessibilityReduceMotion) private var reduceMotion
  @Binding var showsFilters: Bool
  @Binding var selectedFilter: FlightTripFilter
  @State private var notice: FlightHeaderNotice?

  var body: some View {
    HStack(spacing: 8) {
      HStack(spacing: 2) {
        Text(selectedFilter.title)
          .font(.title2.bold())
          .accessibilityIdentifier("design-os.demo.mobility.flight-tracker.trip-list-title")
        Button {
          withAnimation(LocalDemoInteractionMotion.animation(reduceMotion: reduceMotion)) {
            showsFilters.toggle()
          }
        } label: {
          Image(systemName: showsFilters ? "chevron.up" : "chevron.down")
            .font(.caption.bold())
            .frame(width: 44, height: 44)
        }
        .buttonStyle(LocalDemoPressButtonStyle())
        .accessibilityLabel("Choose trip list")
        .accessibilityValue(showsFilters ? "Expanded" : "Collapsed")
        .accessibilityIdentifier("design-os.demo.mobility.flight-tracker.trip-filter-toggle")
      }

      Spacer()
      HStack(spacing: 8) {
        headerAction("square.and.arrow.up", label: "Share trips", notice: .share)
        headerAction("person.crop.circle.fill", label: "Profile", notice: .profile)
      }
    }
    .alert(item: $notice) { notice in
      Alert(
        title: Text(notice.title),
        message: Text(notice.message),
        dismissButton: .cancel(Text("Done")))
    }
  }

  private func headerAction(
    _ symbol: String, label: String, notice: FlightHeaderNotice
  ) -> some View {
    Button {
      self.notice = notice
    } label: {
      Image(systemName: symbol)
        .font(.body)
        .foregroundStyle(.primary)
        .frame(width: 44, height: 44)
    }
    .buttonStyle(LocalDemoPressButtonStyle())
    .accessibilityLabel(label)
  }
}

private enum FlightHeaderNotice: String, Identifiable {
  case share, profile

  var id: String { rawValue }
  var title: String { self == .share ? "Share trips" : "Traveler profile" }
  var message: String {
    self == .share
      ? "Trip sharing is ready for this local demo."
      : "Your local traveler profile keeps these fixtures private."
  }
}

struct FlightTripFilterPanel: View {
  @Environment(\.accessibilityReduceMotion) private var reduceMotion
  @Binding var selectedFilter: FlightTripFilter

  var body: some View {
    VStack(spacing: 0) {
      row(.myTrips, symbol: "airplane")
      Divider()
      row(.sharedTrips, symbol: "person.2")
      Divider()
      row(.today, symbol: "calendar")
    }
    .frame(width: 258)
    .background(
      MobilityDemoTheme.controlFill.opacity(0.97),
      in: RoundedRectangle(cornerRadius: 12)
    )
    .shadow(color: .black.opacity(0.16), radius: 16, y: 6)
    .accessibilityElement(children: .contain)
    .accessibilityIdentifier("design-os.demo.mobility.flight-tracker.trip-filter-panel")
  }

  private func row(_ filter: FlightTripFilter, symbol: String) -> some View {
    Button {
      withAnimation(LocalDemoInteractionMotion.animation(reduceMotion: reduceMotion)) {
        selectedFilter = filter
      }
    } label: {
      HStack {
        Image(systemName: selectedFilter == filter ? "checkmark" : symbol).frame(width: 18)
        Text(filter.title).font(.subheadline)
        Spacer()
      }
      .padding(.horizontal, 12)
      .frame(height: 44)
      .contentShape(Rectangle())
    }
    .buttonStyle(LocalDemoPressButtonStyle())
    .foregroundStyle(.primary)
    .accessibilityValue(selectedFilter == filter ? "Selected" : "Not selected")
    .accessibilityIdentifier(
      "design-os.demo.mobility.flight-tracker.filter.\(filter.rawValue)")
  }
}

enum FlightTripFilter: String, CaseIterable {
  case myTrips
  case sharedTrips
  case today

  var title: String {
    switch self {
    case .myTrips: "My Trips"
    case .sharedTrips: "Shared Trips"
    case .today: "Today"
    }
  }
}
