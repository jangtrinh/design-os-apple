import Foundation

struct StreamingLibraryTitle: Hashable, Identifiable {
  let id: String
  let title: String
  let subtitle: String
  let crop: StreamingMediaCrop
}

enum StreamingLibraryFixtures {
  static let featured = StreamingLibraryTitle(
    id: "night-atlas",
    title: "Night Atlas",
    subtitle: "A signal from the far ridge changes three lives before dawn.",
    crop: .mountain
  )

  static let topTen: [StreamingLibraryTitle] = [
    .init(
      id: "signal-ridge", title: "Signal Ridge", subtitle: "Limited series", crop: .neonDetective),
    .init(id: "after-rain", title: "After Rain", subtitle: "New episodes", crop: .oceanDive),
    .init(id: "blue-descent", title: "Blue Descent", subtitle: "Documentary", crop: .orbit),
    .init(id: "last-orbit", title: "Last Orbit", subtitle: "Drama", crop: .kitchenRomance),
  ]

  static let weekend: [StreamingLibraryTitle] = [
    .init(id: "electric-corners", title: "Electric Corners", subtitle: "8 episodes", crop: .desert),
    .init(id: "below-light", title: "Below the Light", subtitle: "1 h 42 min", crop: .arctic),
    .init(id: "distant-weather", title: "Distant Weather", subtitle: "6 episodes", crop: .jazzClub),
  ]

  static let freshEpisodes: [StreamingLibraryTitle] = [
    .init(id: "city-frequency", title: "City Frequency", subtitle: "New today", crop: .forest),
    .init(id: "open-water", title: "Open Water", subtitle: "New today", crop: .courtroom),
    .init(id: "quiet-signal", title: "Quiet Signal", subtitle: "New today", crop: .coast),
  ]

  static let criticsPicks: [StreamingLibraryTitle] = [
    .init(id: "deep-field", title: "Deep Field", subtitle: "Critics' pick", crop: .futureTrain),
    .init(id: "bright-unknown", title: "Bright Unknown", subtitle: "Critics' pick", crop: .volcano),
    .init(
      id: "night-crossing", title: "Night Crossing", subtitle: "Critics' pick", crop: .moonDance),
  ]
}
