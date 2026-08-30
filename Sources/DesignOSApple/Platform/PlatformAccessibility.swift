internal struct PlatformAccessibilityPreferences: Equatable, Sendable {
  internal enum Contrast: Equatable, Sendable {
    case standard
    case increased
  }

  let reduceMotion: Bool
  let reduceTransparency: Bool
  let differentiateWithoutColor: Bool
  let contrast: Contrast
}
