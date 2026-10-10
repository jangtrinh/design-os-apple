/// Semantic application colors that adapt independently of native system controls.
public struct DesignOSAppPalette: Hashable, Sendable {
  public let canvas: DesignOSAdaptiveColor
  public let surface: DesignOSAdaptiveColor
  public let subtleSurface: DesignOSAdaptiveColor
  public let ink: DesignOSAdaptiveColor
  public let secondaryInk: DesignOSAdaptiveColor
  public let separator: DesignOSAdaptiveColor
  public let action: DesignOSAdaptiveColor
  public let actionInk: DesignOSAdaptiveColor

  /// Creates a palette. Callers must verify foreground/background contrast for custom pairs.
  public init(
    canvas: DesignOSAdaptiveColor,
    surface: DesignOSAdaptiveColor,
    subtleSurface: DesignOSAdaptiveColor,
    ink: DesignOSAdaptiveColor,
    secondaryInk: DesignOSAdaptiveColor,
    separator: DesignOSAdaptiveColor,
    action: DesignOSAdaptiveColor,
    actionInk: DesignOSAdaptiveColor
  ) {
    self.canvas = canvas
    self.surface = surface
    self.subtleSurface = subtleSurface
    self.ink = ink
    self.secondaryInk = secondaryInk
    self.separator = separator
    self.action = action
    self.actionInk = actionInk
  }
}
