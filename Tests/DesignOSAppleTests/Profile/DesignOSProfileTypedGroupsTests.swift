import SwiftUI
import Testing

@testable import DesignOSApple

@Test("Default profile preserves every admitted typed customization axis")
func defaultProfileTypedGroupsPreserveRuntimeValues() {
  let profile = DesignOSProfile.default

  #expect(profile.typography.fontDesign == .standard)
  #expect(profile.spacing.titleSubtitle == 2)
  #expect(profile.spacing.sidebarContent == 8)
  #expect(profile.spacing.listRowContent == 12)
  #expect(profile.radius.customContent == 12)
  #expect(profile.semanticColors.secondaryContent == .labelSecondary)
  #expect(profile.surface.role == .content)
  #expect(profile.accessibility.translucency == .systemAdaptive)
}

@Test("Contrasting profile changes every admitted typed customization axis")
func contrastingProfileChangesEveryTypedGroup() throws {
  let profile = try contrastingProfile()

  #expect(profile.typography != DesignOSProfile.default.typography)
  #expect(profile.spacing != DesignOSProfile.default.spacing)
  #expect(profile.radius != DesignOSProfile.default.radius)
  #expect(profile.semanticColors != DesignOSProfile.default.semanticColors)
  #expect(profile.surface != DesignOSProfile.default.surface)
  #expect(profile.accessibility != DesignOSProfile.default.accessibility)
}

@Test("Scalar typed groups reject non-finite and negative values independently")
func scalarProfileGroupsValidateEveryAxis() {
  for invalid in [CGFloat.nan, -.leastNonzeroMagnitude, .infinity] {
    #expect(throws: DesignOSProfileError.invalid) {
      try DesignOSSpacingProfile(
        titleSubtitle: invalid,
        sidebarContent: 8,
        listRowContent: 12
      )
    }
    #expect(throws: DesignOSProfileError.invalid) {
      try DesignOSRadiusProfile(customContent: invalid)
    }
  }
}

@Test("Every typed group is consumed by its production owner")
func typedGroupsReachProductionConsumers() throws {
  let profile = try contrastingProfile(accessibility: .systemAdaptive)
  let preferences = PlatformAccessibilityPreferences(
    reduceMotion: false,
    reduceTransparency: false,
    differentiateWithoutColor: false,
    contrast: .standard
  )

  #expect(PlatformTypography.fontDesign(for: profile) == .expressive)
  #expect(DesignOSListRowMetrics.titleSubtitleSpacing(for: profile) == 4)
  #expect(DesignOSListRowMetrics.contentSpacing(for: profile) == 16)
  #expect(DesignOSSidebarRowMetrics.contentSpacing(for: profile) == 10)
  #expect(PlatformSurfacePolicy.cornerRadius(for: profile) == 18)
  #expect(DesignOSListRowStyle.secondaryContentRole(for: profile) == .labelTertiary)
  #expect(
    PlatformSurfacePolicy.presentation(for: profile, preferences: preferences)
      == .material
  )
}

@Test("Custom surface modifier consumes profile policy without replacing a native container")
@MainActor
func customSurfaceModifierCompiles() throws {
  let view = Text("Summary")
    .padding()
    .designOSCustomSurface()
    .designOSProfile(try contrastingProfile())

  #expect(String(reflecting: type(of: view)).contains("ModifiedContent"))
}

@Test("Accessibility policy may constrain translucency but never override the system")
func accessibilityPolicyIsFailClosed() throws {
  let automatic = try contrastingProfile(accessibility: .systemAdaptive)
  let opaque = try contrastingProfile(accessibility: .opaqueOnly)
  let standard = PlatformAccessibilityPreferences(
    reduceMotion: false,
    reduceTransparency: false,
    differentiateWithoutColor: false,
    contrast: .standard
  )
  let reduced = PlatformAccessibilityPreferences(
    reduceMotion: false,
    reduceTransparency: true,
    differentiateWithoutColor: false,
    contrast: .standard
  )

  #expect(PlatformSurfacePolicy.presentation(for: automatic, preferences: standard) == .material)
  #expect(PlatformSurfacePolicy.presentation(for: automatic, preferences: reduced) == .content)
  #expect(PlatformSurfacePolicy.presentation(for: opaque, preferences: standard) == .content)
  #expect(PlatformSurfacePolicy.presentation(for: opaque, preferences: reduced) == .content)
}

private func contrastingProfile(
  accessibility: DesignOSAccessibilityPolicy = .opaqueOnly
) throws -> DesignOSProfile {
  try DesignOSProfile(
    typography: DesignOSTypographyProfile(fontDesign: .expressive),
    spacing: DesignOSSpacingProfile(
      titleSubtitle: 4,
      sidebarContent: 10,
      listRowContent: 16
    ),
    radius: DesignOSRadiusProfile(customContent: 18),
    semanticColors: DesignOSSemanticColorProfile(secondaryContent: .labelTertiary),
    surface: DesignOSSurfaceProfile(role: .translucentContent),
    accessibility: accessibility
  )
}
