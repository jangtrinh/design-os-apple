import DesignOSApple

enum OmniActHUDSurfacePath: Equatable {
  case nativeMaterial
  case opaqueBackground
}

enum OmniActHUDSurfaceResolver {
  static func path(
    profile: DesignOSProfile,
    reduceTransparency: Bool
  ) -> OmniActHUDSurfacePath {
    profile.surfaceRole.usesNativeMaterial(reduceTransparency: reduceTransparency)
      ? .nativeMaterial : .opaqueBackground
  }
}
