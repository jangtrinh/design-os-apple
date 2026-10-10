import SwiftUI

/// A full-pill primary action with standard native `Button` interaction.
///
/// Apply to app-owned content actions. Destructive roles retain a red visual cue. Native
/// alerts and menus retain their system styles. This style does not replace activation.
public struct DesignOSPrimaryButtonStyle: ButtonStyle {
  public init() {}

  public func makeBody(configuration: Configuration) -> some View {
    DesignOSActionButtonContent(configuration: configuration, prominence: .primary)
  }
}

internal struct DesignOSActionButtonContent: View {
  @Environment(\.designOSAppStyle) private var style
  @Environment(\.isEnabled) private var isEnabled
  @Environment(\.isFocused) private var isFocused
  @State private var isHovered = false
  let configuration: ButtonStyleConfiguration
  let prominence: DesignOSActionButtonProminence

  internal init(
    configuration: ButtonStyleConfiguration,
    prominence: DesignOSActionButtonProminence
  ) {
    self.configuration = configuration
    self.prominence = prominence
  }

  var body: some View {
    configuration.label
      .font(DesignOSTypographyRole.headline.font(profile: style.profile))
      .foregroundStyle(foreground.color)
      .multilineTextAlignment(.center)
      .fixedSize(horizontal: false, vertical: true)
      .padding(.horizontal, style.metrics.pageInset)
      .padding(.vertical, style.metrics.itemSpacing)
      .frame(minWidth: 44, maxWidth: .infinity, minHeight: style.metrics.actionMinHeight)
      .background {
        shape
          .fill(background.color)
          .overlay {
            shape
              .fill(
                foreground.color.opacity(
                  DesignOSPrimaryButtonAppearance.highlightOpacity(
                    isEnabled: isEnabled,
                    isPressed: configuration.isPressed,
                    isHovered: isHovered
                  )
                )
              )
          }
      }
      .overlay {
        if isFocused && isEnabled {
          Capsule(style: .continuous)
            .stroke(style.palette.ink.color, lineWidth: 2)
            .padding(-4)
        }
      }
      .contentShape(shape)
      .onHover { isHovered = $0 }
  }

  private var foreground: DesignOSAdaptiveColor {
    DesignOSPrimaryButtonAppearance.foreground(
      palette: style.palette, prominence: prominence, isEnabled: isEnabled,
      isDestructive: configuration.role == .destructive
    )
  }

  private var background: DesignOSAdaptiveColor {
    DesignOSPrimaryButtonAppearance.background(
      palette: style.palette, prominence: prominence, isEnabled: isEnabled,
      isDestructive: configuration.role == .destructive
    )
  }

  private var shape: Capsule {
    Capsule(style: .continuous)
  }
}

internal enum DesignOSActionButtonProminence {
  case primary
  case secondary
}

internal enum DesignOSPrimaryButtonAppearance {
  // Accessible semantic danger colors, not claimed reference-app measurements.
  static let destructiveInk = DesignOSAdaptiveColor(
    uncheckedLightRGB: 0xB4_2318,
    darkRGB: 0xFF_B4AB,
    increasedContrastLightRGB: 0x8C_0D05,
    increasedContrastDarkRGB: 0xFF_DAD6
  )

  static func foreground(
    palette: DesignOSAppPalette,
    prominence: DesignOSActionButtonProminence,
    isEnabled: Bool,
    isDestructive: Bool
  ) -> DesignOSAdaptiveColor {
    guard isEnabled else { return palette.secondaryInk }
    switch prominence {
    case .primary: return palette.actionInk
    case .secondary: return isDestructive ? destructiveInk : palette.ink
    }
  }

  static func background(
    palette: DesignOSAppPalette,
    prominence: DesignOSActionButtonProminence,
    isEnabled: Bool,
    isDestructive: Bool
  ) -> DesignOSAdaptiveColor {
    guard isEnabled else { return palette.subtleSurface }
    switch prominence {
    case .primary: return isDestructive ? destructiveInk : palette.action
    case .secondary: return palette.subtleSurface
    }
  }

  static func highlightOpacity(isEnabled: Bool, isPressed: Bool, isHovered: Bool) -> Double {
    guard isEnabled else { return 0 }
    return isPressed ? 0.12 : (isHovered ? 0.06 : 0)
  }
}
