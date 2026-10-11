import SwiftUI

/// A quiet, full-pill content action with standard native `Button` interaction.
///
/// Defaults to primary-action sizing and a quiet fill. Use compact outlined actions for
/// content-sized category chips; their visible capsule retains a 44-point interaction target.
/// Native activation, roles, accessibility, focus, and disabled state remain caller-owned.
public struct DesignOSSecondaryButtonStyle: ButtonStyle {
  /// The relationship between the visible action and its surrounding layout.
  public enum Size: Hashable, Sendable {
    /// Full-width action using the app style's minimum action height.
    case regular
    /// Content-sized action with a separate minimum 44-by-44-point interaction target.
    case compact
  }

  /// The semantic surface drawn inside the capsule.
  public enum Treatment: Hashable, Sendable {
    /// A quiet secondary surface.
    case filled
    /// An opaque canvas-colored surface and adaptive separator outline.
    case outlined
  }

  internal let size: Size
  internal let treatment: Treatment

  /// Existing call sites keep the regular filled appearance.
  public init(size: Size = .regular, treatment: Treatment = .filled) {
    self.size = size
    self.treatment = treatment
  }

  @ViewBuilder
  public func makeBody(configuration: Configuration) -> some View {
    if size == .regular && treatment == .filled {
      DesignOSActionButtonContent(configuration: configuration, prominence: .secondary)
    } else {
      DesignOSSecondaryButtonContent(configuration: configuration, size: size, treatment: treatment)
    }
  }
}

private struct DesignOSSecondaryButtonContent: View {
  @Environment(\.designOSAppStyle) private var style
  @Environment(\.isEnabled) private var isEnabled
  @Environment(\.isFocused) private var isFocused
  @State private var isHovered = false
  let configuration: ButtonStyleConfiguration
  let size: DesignOSSecondaryButtonStyle.Size
  let treatment: DesignOSSecondaryButtonStyle.Treatment

  var body: some View {
    let layout = DesignOSSecondaryButtonLayout(metrics: style.metrics, size: size)
    configuration.label
      .font(layout.typography.font(profile: style.profile))
      .foregroundStyle(foreground.color)
      .multilineTextAlignment(.center)
      .fixedSize(horizontal: false, vertical: true)
      .padding(.horizontal, layout.horizontalInset)
      .padding(.vertical, layout.verticalInset)
      .frame(maxWidth: layout.maximumWidth, minHeight: layout.minimumVisualHeight)
      .background {
        shape.fill(background.color)
          .overlay {
            shape.fill(
              foreground.color.opacity(
                DesignOSPrimaryButtonAppearance.highlightOpacity(
                  isEnabled: isEnabled,
                  isPressed: configuration.isPressed,
                  isHovered: isHovered
                )
              )
            )
          }
          .allowsHitTesting(false)
          .accessibilityHidden(true)
      }
      .overlay {
        if treatment == .outlined {
          shape.strokeBorder(style.palette.separator.color, lineWidth: 1)
            .allowsHitTesting(false)
            .accessibilityHidden(true)
        }
      }
      .overlay {
        if isFocused && isEnabled {
          shape.stroke(style.palette.ink.color, lineWidth: 2)
            .padding(-4)
            .allowsHitTesting(false)
            .accessibilityHidden(true)
        }
      }
      // Put the interaction frame after the artwork so compact capsules stay visually quiet.
      .frame(
        minWidth: DesignOSSecondaryButtonLayout.minimumInteractionSize,
        minHeight: DesignOSSecondaryButtonLayout.minimumInteractionSize
      )
      .contentShape(Rectangle())
      .onHover { isHovered = $0 }
  }

  private var foreground: DesignOSAdaptiveColor {
    DesignOSPrimaryButtonAppearance.foreground(
      palette: style.palette, prominence: .secondary, isEnabled: isEnabled,
      isDestructive: configuration.role == .destructive
    )
  }

  private var background: DesignOSAdaptiveColor {
    DesignOSSecondaryButtonAppearance.background(
      palette: style.palette, treatment: treatment, isEnabled: isEnabled
    )
  }

  private var shape: Capsule {
    Capsule(style: .continuous)
  }
}

internal struct DesignOSSecondaryButtonLayout {
  static let minimumInteractionSize: CGFloat = 44
  let horizontalInset: CGFloat
  let verticalInset: CGFloat
  let maximumWidth: CGFloat?
  let minimumVisualHeight: CGFloat?
  let typography: DesignOSTypographyRole

  init(metrics: DesignOSAppMetrics, size: DesignOSSecondaryButtonStyle.Size) {
    switch size {
    case .regular:
      horizontalInset = metrics.pageInset
      verticalInset = metrics.itemSpacing
      maximumWidth = .infinity
      minimumVisualHeight = metrics.actionMinHeight
      typography = .headline
    case .compact:
      horizontalInset = metrics.contentInset
      verticalInset = metrics.contentInset / 2
      maximumWidth = nil
      minimumVisualHeight = nil
      typography = .body
    }
  }
}

internal enum DesignOSSecondaryButtonAppearance {
  static func background(
    palette: DesignOSAppPalette,
    treatment: DesignOSSecondaryButtonStyle.Treatment,
    isEnabled: Bool
  ) -> DesignOSAdaptiveColor {
    guard isEnabled else {
      return DesignOSPrimaryButtonAppearance.background(
        palette: palette, prominence: .secondary, isEnabled: false, isDestructive: false
      )
    }
    switch treatment {
    case .filled: return palette.subtleSurface
    case .outlined: return palette.canvas
    }
  }
}
