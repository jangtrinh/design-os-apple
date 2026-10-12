import CoreGraphics

/// Finite geometry shared by semantic media components, without a second token scale.
internal enum DesignOSEditorialGeometry {
  static func aspectRatio(_ value: CGFloat) -> CGFloat {
    value.isFinite && value > 0 ? value : 1
  }

  static func length(_ value: CGFloat) -> CGFloat {
    value.isFinite && value >= 0 ? value : 0
  }

  static func diameter(_ requested: CGFloat?, fallback: CGFloat) -> CGFloat {
    if let requested, requested.isFinite, requested > 0 {
      return requested
    }
    return fallback.isFinite && fallback > 0 ? fallback : 1
  }

  static func cornerRadius(_ requested: CGFloat, in size: CGSize) -> CGFloat {
    min(length(requested), min(length(size.width), length(size.height)) / 2)
  }
}
