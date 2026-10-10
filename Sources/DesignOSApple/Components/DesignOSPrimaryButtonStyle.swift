import SwiftUI

/// Monochrome primary-action appearance with standard native `Button` interaction.
///
/// Apply only to a screen's main content action. Keep toolbar, menu, and destructive actions
/// in their native styles. This style does not install gestures or replace activation.
public struct DesignOSPrimaryButtonStyle: ButtonStyle {
  public init() {}

  public func makeBody(configuration: Configuration) -> some View {
    DesignOSPrimaryButtonContent(configuration: configuration)
  }
}

private struct DesignOSPrimaryButtonContent: View {
  @Environment(\.designOSAppStyle) private var style
  @Environment(\.isEnabled) private var isEnabled
  @Environment(\.isFocused) private var isFocused
  @State private var isHovered = false
  let configuration: ButtonStyleConfiguration

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
          RoundedRectangle(cornerRadius: style.metrics.actionRadius + 4, style: .continuous)
            .stroke(style.palette.ink.color, lineWidth: 2)
            .padding(-4)
        }
      }
      .contentShape(shape)
      .onHover { isHovered = $0 }
  }

  private var foreground: DesignOSAdaptiveColor {
    isEnabled ? style.palette.actionInk : style.palette.secondaryInk
  }

  private var background: DesignOSAdaptiveColor {
    isEnabled ? style.palette.action : style.palette.subtleSurface
  }

  private var shape: RoundedRectangle {
    RoundedRectangle(cornerRadius: style.metrics.actionRadius, style: .continuous)
  }
}

internal enum DesignOSPrimaryButtonAppearance {
  static func highlightOpacity(isEnabled: Bool, isPressed: Bool, isHovered: Bool) -> Double {
    guard isEnabled else { return 0 }
    return isPressed ? 0.12 : (isHovered ? 0.06 : 0)
  }
}
