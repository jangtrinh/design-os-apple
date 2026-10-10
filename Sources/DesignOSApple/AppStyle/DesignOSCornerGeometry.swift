import CoreGraphics

/// Shared corner relationships for genuinely nested, concentric content.
///
/// This is the application's design rule, not an Apple-mandated radius scale. Native
/// controls retain their own shapes. Use continuous corners for caller-owned images and
/// surfaces, and derive an inner radius only from the real inset at that corner.
public enum DesignOSCornerGeometry {
  /// Subtracts the actual edge inset from an outer radius, clamping the result to zero.
  ///
  /// The inset includes any padding or border separating the two corresponding edges.
  /// Sibling elements and unrelated corners must keep their own semantic radius. Invalid
  /// (negative or non-finite) input fails closed to a square corner rather than propagating
  /// invalid drawing geometry.
  public static func innerRadius(outerRadius: CGFloat, inset: CGFloat) -> CGFloat {
    guard outerRadius.isFinite, inset.isFinite, outerRadius >= 0, inset >= 0 else {
      return 0
    }
    return max(0, outerRadius - inset)
  }
}
