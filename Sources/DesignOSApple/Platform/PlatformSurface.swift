import CoreGraphics
import SwiftUI

extension View {
  /// Applies profile-owned styling to custom non-interactive content only.
  public func designOSCustomSurface() -> some View {
    modifier(DesignOSCustomSurfaceModifier())
  }
}

private struct DesignOSCustomSurfaceModifier: ViewModifier {
  @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
  @Environment(\.designOSProfile) private var profile

  func body(content: Content) -> some View {
    content
      .background { background }
      .clipShape(.rect(cornerRadius: PlatformSurfacePolicy.cornerRadius(for: profile)))
  }

  @ViewBuilder private var background: some View {
    switch PlatformSurfacePolicy.presentation(
      for: profile,
      preferences: PlatformAccessibilityPreferences(
        reduceMotion: false,
        reduceTransparency: reduceTransparency,
        differentiateWithoutColor: false,
        contrast: .standard
      )
    ) {
    case .content:
      DesignOSColorRole.backgroundSecondary.color
    case .groupedContent:
      DesignOSColorRole.groupedBackgroundSecondary.color
    case .material:
      Rectangle().fill(.regularMaterial)
    }
  }
}

internal enum PlatformSurfacePresentation: Equatable, Sendable {
  case content
  case groupedContent
  case material
}

internal enum PlatformSurfacePolicy {
  static func cornerRadius(for profile: DesignOSProfile) -> CGFloat {
    profile.radius.customContent
  }

  static func presentation(
    for profile: DesignOSProfile,
    preferences: PlatformAccessibilityPreferences
  ) -> PlatformSurfacePresentation {
    let presentation = presentation(for: profile.surface.role, preferences: preferences)
    guard profile.accessibility.translucency == .systemAdaptive else {
      return presentation == .material ? .content : presentation
    }
    return presentation
  }

  static func presentation(
    for role: DesignOSSurfaceRole,
    preferences: PlatformAccessibilityPreferences
  ) -> PlatformSurfacePresentation {
    switch role.identifier {
    case .content:
      .content
    case .groupedContent:
      .groupedContent
    case .translucentContent:
      preferences.reduceTransparency ? .content : .material
    }
  }
}

extension DesignOSSurfaceRole {
  /// Whether this custom surface should use native material for the given accessibility setting.
  public func usesNativeMaterial(reduceTransparency: Bool) -> Bool {
    let preferences = PlatformAccessibilityPreferences(
      reduceMotion: false,
      reduceTransparency: reduceTransparency,
      differentiateWithoutColor: false,
      contrast: .standard
    )
    return PlatformSurfacePolicy.presentation(for: self, preferences: preferences) == .material
  }
}
