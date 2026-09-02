import SwiftUI

enum ThoughtfulChatTheme {
  static let paper = Color.localDemoAdaptive(
    light: .init(red: 0.975, green: 0.968, blue: 0.945),
    dark: .init(red: 0.10, green: 0.09, blue: 0.08)
  )
  static let card = Color.localDemoAdaptive(
    light: .init(red: 0.995, green: 0.99, blue: 0.975),
    dark: .init(red: 0.15, green: 0.13, blue: 0.12)
  )
  static let ink = Color.localDemoAdaptive(
    light: .init(red: 0.16, green: 0.145, blue: 0.13),
    dark: .init(red: 0.94, green: 0.91, blue: 0.86)
  )
  static let clay = Color.localDemoAdaptive(
    light: .init(red: 0.73, green: 0.34, blue: 0.24),
    dark: .init(red: 0.92, green: 0.50, blue: 0.38)
  )
  static let subdued = Color.localDemoAdaptive(
    light: .init(red: 0.46, green: 0.44, blue: 0.41),
    dark: .init(red: 0.72, green: 0.69, blue: 0.65)
  )
  static let outline = Color.localDemoAdaptive(
    light: .init(red: 0.93, green: 0.91, blue: 0.87),
    dark: .init(red: 0.29, green: 0.26, blue: 0.23)
  )
  static let secondaryControlFill = Color.localDemoAdaptive(
    light: .init(red: 0.955, green: 0.945, blue: 0.92),
    dark: .init(red: 0.10, green: 0.085, blue: 0.075)
  )
  static let primaryControlFill = Color.localDemoAdaptive(
    light: .init(red: 0.16, green: 0.145, blue: 0.13),
    dark: .init(red: 0.08, green: 0.07, blue: 0.06)
  )
  static let primaryControlInk = Color.localDemoAdaptive(
    light: .init(red: 0.98, green: 0.97, blue: 0.94),
    dark: .init(red: 0.98, green: 0.97, blue: 0.94)
  )
}

struct ThoughtfulChatCircleControl: View {
  let symbol: String
  let label: String

  var body: some View {
    Image(systemName: symbol)
      .font(.body.weight(.medium))
      .foregroundStyle(ThoughtfulChatTheme.ink)
      .frame(width: 44, height: 44)
      .background(ThoughtfulChatTheme.card, in: Circle())
      .shadow(color: .black.opacity(0.06), radius: 12, y: 5)
      .accessibilityLabel(label)
  }
}
