import SwiftUI

/// Opt-in editorial appearance for a caller-owned native `TextField` or `SecureField`.
///
/// Apply directly with `.modifier(DesignOSAppTextFieldModifier())`. Single-line fields use a
/// soft filled capsule; multiline fields use a continuous rounded rectangle. Leave inline
/// editors in native Form/Section rows plain rather than adding a second field surface.
/// Text, labels, focus, keyboard, validation, and secure-entry semantics remain caller-owned.
/// Focus is shown by the native insertion point, not an invented persistent border. Display
/// validation text beside the control; this modifier never replaces accessibility values.
public struct DesignOSAppTextFieldModifier: ViewModifier {
  @Environment(\.designOSAppStyle) private var style
  @Environment(\.isEnabled) private var isEnabled
  @Environment(\.colorSchemeContrast) private var contrast
  private let multiline: Bool
  private let cornerRadius: CGFloat?

  /// Pass a radius only for a genuinely nested surface, derived from its actual edge inset
  /// with `DesignOSCornerGeometry.innerRadius(outerRadius:inset:)`. Unrelated sibling
  /// controls do not inherit their container's radius. Invalid overrides fail closed to zero.
  public init(multiline: Bool = false, cornerRadius: CGFloat? = nil) {
    self.multiline = multiline
    self.cornerRadius = cornerRadius
  }

  public func body(content: Content) -> some View {
    content
      .textFieldStyle(.plain)
      .foregroundStyle((isEnabled ? style.palette.ink : style.palette.secondaryInk).color)
      .padding(.horizontal, style.metrics.contentInset)
      .padding(.vertical, style.metrics.itemSpacing)
      .frame(minHeight: 44, alignment: multiline ? .topLeading : .leading)
      .background {
        shape.fill((cornerRadius == nil ? style.palette.surface : style.palette.subtleSurface).color)
          .allowsHitTesting(false)
          .accessibilityHidden(true)
      }
      .overlay {
        // Accessibility fallback only: ordinary reference fields have no outline.
        if contrast == .increased {
          shape.stroke(style.palette.secondaryInk.color, lineWidth: 1)
            .padding(0.5)
            .allowsHitTesting(false)
            .accessibilityHidden(true)
        }
      }
  }

  private var shape: AnyShape {
    if !multiline && cornerRadius == nil {
      return AnyShape(Capsule(style: .continuous))
    }
    return AnyShape(
      RoundedRectangle(
        cornerRadius: DesignOSAppTextFieldAppearance.radius(
          override: cornerRadius, surfaceRadius: style.metrics.surfaceRadius
        ),
        style: .continuous
      ))
  }
}

internal enum DesignOSAppTextFieldAppearance {
  static func radius(override: CGFloat?, surfaceRadius: CGFloat) -> CGFloat {
    guard let override else { return surfaceRadius }
    return override.isFinite && override >= 0 ? override : 0
  }
}
