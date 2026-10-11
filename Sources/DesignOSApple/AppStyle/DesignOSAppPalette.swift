/// A foreground and background selected together for a semantic content role.
///
/// Both colors adapt to appearance and contrast. Custom pairs must be contrast-checked
/// together; a foreground is never inferred from a newly supplied background.
/// A disabled-only pair may deliberately have lower contrast than active content.
public struct DesignOSAppColorPair: Hashable, Sendable {
  public let background: DesignOSAdaptiveColor
  public let foreground: DesignOSAdaptiveColor

  public init(background: DesignOSAdaptiveColor, foreground: DesignOSAdaptiveColor) {
    self.background = background
    self.foreground = foreground
  }
}

/// Semantic application colors that adapt independently of native system controls.
public struct DesignOSAppPalette: Hashable, Sendable {
  /// Accessible default for validation text and destructive app-style actions.
  /// This opt-in role does not replace the platform's system red semantic color.
  public static let defaultDangerInk = DesignOSAdaptiveColor(
    uncheckedLightRGB: 0xB4_2318,
    darkRGB: 0xFF_B4AB,
    increasedContrastLightRGB: 0x8C_0D05,
    increasedContrastDarkRGB: 0xFF_DAD6
  )

  public let canvas: DesignOSAdaptiveColor
  public let surface: DesignOSAdaptiveColor
  public let subtleSurface: DesignOSAdaptiveColor
  public let ink: DesignOSAdaptiveColor
  public let secondaryInk: DesignOSAdaptiveColor
  public let separator: DesignOSAdaptiveColor
  public let action: DesignOSAdaptiveColor
  public let actionInk: DesignOSAdaptiveColor
  /// Validation foreground and destructive action color; custom pairings require contrast checks.
  public let dangerInk: DesignOSAdaptiveColor
  /// Used only by explicitly emphasized outgoing message content, never by app-wide actions.
  public let outgoingMessage: DesignOSAppColorPair
  /// Used only while an app-style native Button is disabled, never for active text or fields.
  /// Standard-contrast colors may be subdued; increased-contrast variants should stay readable.
  public let disabledAction: DesignOSAppColorPair

  /// Creates a palette. Callers must verify foreground/background contrast for custom pairs.
  /// Omitting outgoingMessage preserves the supplied surface/ink pair for existing palettes.
  /// Omitting dangerInk preserves the existing destructive-button colors in every appearance.
  /// Omitting disabledAction preserves the supplied subtleSurface/secondaryInk disabled pair.
  public init(
    canvas: DesignOSAdaptiveColor,
    surface: DesignOSAdaptiveColor,
    subtleSurface: DesignOSAdaptiveColor,
    ink: DesignOSAdaptiveColor,
    secondaryInk: DesignOSAdaptiveColor,
    separator: DesignOSAdaptiveColor,
    action: DesignOSAdaptiveColor,
    actionInk: DesignOSAdaptiveColor,
    outgoingMessage: DesignOSAppColorPair? = nil,
    dangerInk: DesignOSAdaptiveColor = DesignOSAppPalette.defaultDangerInk,
    disabledAction: DesignOSAppColorPair? = nil
  ) {
    self.canvas = canvas
    self.surface = surface
    self.subtleSurface = subtleSurface
    self.ink = ink
    self.secondaryInk = secondaryInk
    self.separator = separator
    self.action = action
    self.actionInk = actionInk
    self.dangerInk = dangerInk
    self.outgoingMessage =
      outgoingMessage ?? DesignOSAppColorPair(background: surface, foreground: ink)
    self.disabledAction =
      disabledAction ?? DesignOSAppColorPair(background: subtleSurface, foreground: secondaryInk)
  }
}
