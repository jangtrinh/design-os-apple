import Testing

@testable import DesignOSApple

@Test("Accessibility preferences are immutable value inputs")
func accessibilityPreferencesMeetValueContracts() {
  requireEquatableAndSendable(PlatformAccessibilityPreferences.self)
  requireEquatableAndSendable(PlatformAccessibilityPreferences.Contrast.self)
}

@Test("Surface policy keeps opaque roles opaque")
func opaqueSurfaceRolesIgnoreAccessibilityInputs() {
  let preferences = PlatformAccessibilityPreferences(
    reduceMotion: true,
    reduceTransparency: true,
    differentiateWithoutColor: true,
    contrast: .increased
  )

  #expect(
    PlatformSurfacePolicy.presentation(for: .content, preferences: preferences) == .content
  )
  #expect(
    PlatformSurfacePolicy.presentation(for: .groupedContent, preferences: preferences)
      == .groupedContent
  )
}

@Test("Translucent surface falls back only for reduced transparency")
func translucentSurfaceRespectsReduceTransparency() {
  let standard = PlatformAccessibilityPreferences(
    reduceMotion: true,
    reduceTransparency: false,
    differentiateWithoutColor: true,
    contrast: .increased
  )
  let reduced = PlatformAccessibilityPreferences(
    reduceMotion: false,
    reduceTransparency: true,
    differentiateWithoutColor: false,
    contrast: .standard
  )

  #expect(
    PlatformSurfacePolicy.presentation(for: .translucentContent, preferences: standard) == .material
  )
  #expect(
    PlatformSurfacePolicy.presentation(for: .translucentContent, preferences: reduced) == .content
  )
}

@Test("Public surface material projection delegates to the generic policy")
func surfaceRoleProjectsNativeMaterialWithoutExposingPreferences() {
  #expect(DesignOSSurfaceRole.translucentContent.usesNativeMaterial(reduceTransparency: false))
  #expect(!DesignOSSurfaceRole.translucentContent.usesNativeMaterial(reduceTransparency: true))
  #expect(!DesignOSSurfaceRole.content.usesNativeMaterial(reduceTransparency: false))
}

private func requireEquatableAndSendable<Value: Equatable & Sendable>(_: Value.Type) {}
