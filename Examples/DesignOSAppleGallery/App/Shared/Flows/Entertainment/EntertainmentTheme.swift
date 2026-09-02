import SwiftUI

enum EntertainmentTheme {
  static let black = Color.black
  static let ink = Color.white
  static let subdued = Color.white.opacity(0.68)
  static let panel = Color(red: 0.075, green: 0.075, blue: 0.085)
  static let panelRaised = Color(red: 0.12, green: 0.12, blue: 0.14)
  static let action = Color(red: 1.0, green: 0.23, blue: 0.12)
  static let listeningBlue = LinearGradient(
    colors: [
      Color(red: 0.02, green: 0.62, blue: 0.97),
      Color(red: 0.04, green: 0.18, blue: 0.98),
    ],
    startPoint: .top,
    endPoint: .bottom
  )
}

struct EntertainmentCircleControl: View {
  let symbol: String
  let label: String
  var foreground = EntertainmentTheme.ink
  var fill = Color.white.opacity(0.12)

  var body: some View {
    Image(systemName: symbol)
      .font(.body.weight(.semibold))
      .foregroundStyle(foreground)
      .frame(width: 44, height: 44)
      .background(fill, in: Circle())
      .contentShape(Circle())
      .accessibilityLabel(label)
  }
}
