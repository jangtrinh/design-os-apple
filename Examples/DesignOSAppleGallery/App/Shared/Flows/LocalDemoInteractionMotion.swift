import SwiftUI

enum LocalDemoInteractionMotion {
  static func animation(reduceMotion: Bool) -> Animation? {
    reduceMotion ? nil : .snappy(duration: 0.24, extraBounce: 0.04)
  }

  static func disclosure(reduceMotion: Bool) -> AnyTransition {
    reduceMotion ? .opacity : .move(edge: .top).combined(with: .opacity)
  }
}

struct LocalDemoPressButtonStyle: ButtonStyle {
  @Environment(\.accessibilityReduceMotion) private var reduceMotion

  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .scaleEffect(reduceMotion || !configuration.isPressed ? 1 : 0.97)
      .opacity(configuration.isPressed ? 0.82 : 1)
      .animation(
        LocalDemoInteractionMotion.animation(reduceMotion: reduceMotion),
        value: configuration.isPressed
      )
  }
}
