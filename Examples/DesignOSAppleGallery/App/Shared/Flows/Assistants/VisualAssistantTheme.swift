import SwiftUI

enum VisualAssistantTheme {
  static let canvas = Color.localDemoAdaptive(
    light: .init(red: 1, green: 1, blue: 1),
    dark: .init(red: 0.08, green: 0.09, blue: 0.11)
  )
  static let ink = Color.localDemoAdaptive(
    light: .init(red: 0.10, green: 0.11, blue: 0.13),
    dark: .init(red: 0.92, green: 0.94, blue: 0.97)
  )
  static let muted = Color.localDemoAdaptive(
    light: .init(red: 0.42, green: 0.43, blue: 0.46),
    dark: .init(red: 0.66, green: 0.69, blue: 0.74)
  )
  static let field = Color.localDemoAdaptive(
    light: .init(red: 0.965, green: 0.975, blue: 0.99),
    dark: .init(red: 0.14, green: 0.16, blue: 0.20)
  )
  static let blue = Color(red: 0.18, green: 0.47, blue: 0.94)
  static let violet = Color(red: 0.49, green: 0.32, blue: 0.86)
  static let rose = Color(red: 0.82, green: 0.34, blue: 0.53)

  static let spectrum = LinearGradient(
    colors: [blue, violet, rose],
    startPoint: .leading,
    endPoint: .trailing
  )
}

struct VisualAssistantCircleControl: View {
  let symbol: String
  let label: String

  var body: some View {
    Image(systemName: symbol)
      .font(.body.weight(.medium))
      .foregroundStyle(VisualAssistantTheme.ink)
      .frame(width: 44, height: 44)
      .contentShape(Circle())
      .accessibilityLabel(label)
  }
}
