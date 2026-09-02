import SwiftUI

enum MobilityDemoTheme {
  static let flightBlue = Color(red: 0.20, green: 0.52, blue: 1.00)
  static let flightOcean = Color(red: 0.10, green: 0.27, blue: 0.39)
  static let cityGreen = Color(red: 0.02, green: 0.66, blue: 0.36)
  static let cityInk = Color.localDemoAdaptive(
    light: .init(red: 0.08, green: 0.10, blue: 0.11),
    dark: .init(red: 0.93, green: 0.94, blue: 0.95)
  )
  static let secondaryInk = Color.localDemoAdaptive(
    light: .init(red: 0.38, green: 0.40, blue: 0.42),
    dark: .init(red: 0.67, green: 0.69, blue: 0.72)
  )
  static let paper = Color.localDemoAdaptive(
    light: .init(red: 1, green: 1, blue: 1),
    dark: .init(red: 0.08, green: 0.09, blue: 0.10)
  )
  static let softFill = Color.localDemoAdaptive(
    light: .init(red: 0.96, green: 0.96, blue: 0.97),
    dark: .init(red: 0.14, green: 0.15, blue: 0.17)
  )
  static let controlFill = Color.localDemoAdaptive(
    light: .init(red: 1, green: 1, blue: 1),
    dark: .init(red: 0.17, green: 0.18, blue: 0.20)
  )
  static let safetyFill = Color.localDemoAdaptive(
    light: .init(red: 0.85, green: 0.96, blue: 0.94),
    dark: .init(red: 0.08, green: 0.24, blue: 0.19)
  )
  static let airportFill = Color.localDemoAdaptive(
    light: .init(red: 0.91, green: 0.98, blue: 0.98),
    dark: .init(red: 0.08, green: 0.20, blue: 0.21)
  )
}

struct MobilitySheet<Content: View>: View {
  let content: Content

  init(@ViewBuilder content: () -> Content) {
    self.content = content()
  }

  var body: some View {
    ScrollView {
      content.frame(maxWidth: .infinity, alignment: .top)
    }
    .scrollIndicators(.hidden)
    .padding(.horizontal, 16)
    .padding(.top, 16)
    .padding(.bottom, 12)
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    .background(
      MobilityDemoTheme.paper,
      in: UnevenRoundedRectangle(
        topLeadingRadius: 20, bottomLeadingRadius: 0, bottomTrailingRadius: 0,
        topTrailingRadius: 20)
    )
  }
}

struct MobilityCircularControl: View {
  @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
  let symbol: String
  let label: String

  var body: some View {
    Image(systemName: symbol)
      .font(.body.weight(.semibold))
      .foregroundStyle(MobilityDemoTheme.cityInk)
      .frame(width: 44, height: 44)
      .background(
        reduceTransparency
          ? MobilityDemoTheme.controlFill : MobilityDemoTheme.controlFill.opacity(0.94),
        in: Circle()
      )
      .shadow(color: .black.opacity(0.12), radius: 6, y: 2)
      .accessibilityLabel(label)
  }
}
