import CoreGraphics
import DesignOSApple
import Testing

@Test("Nested content radius subtracts its actual inset")
func nestedCornerRadiusUsesActualInset() {
  #expect(DesignOSCornerGeometry.innerRadius(outerRadius: 24, inset: 8) == 16)
  #expect(DesignOSCornerGeometry.innerRadius(outerRadius: 28, inset: 12) == 16)
  #expect(DesignOSCornerGeometry.innerRadius(outerRadius: 20, inset: 3.5) == 16.5)
}

@Test("Nested content radius clamps to zero when the inset reaches the outer radius")
func nestedCornerRadiusClampsAtZero() {
  #expect(DesignOSCornerGeometry.innerRadius(outerRadius: 24, inset: 24) == 0)
  #expect(DesignOSCornerGeometry.innerRadius(outerRadius: 24, inset: 40) == 0)
  #expect(DesignOSCornerGeometry.innerRadius(outerRadius: 0, inset: 0) == 0)
  #expect(DesignOSCornerGeometry.innerRadius(outerRadius: 24, inset: 0) == 24)
}

@Test("Nested corner geometry rejects negative and non-finite values safely")
func nestedCornerRadiusFailsClosedForInvalidInput() {
  for invalid in [CGFloat.nan, .infinity, -.infinity, -.leastNonzeroMagnitude] {
    #expect(DesignOSCornerGeometry.innerRadius(outerRadius: invalid, inset: 8) == 0)
    #expect(DesignOSCornerGeometry.innerRadius(outerRadius: 24, inset: invalid) == 0)
  }
}

@Test("Nested corner radii compose over successive real insets")
func nestedCornerRadiusComposes() {
  let middle = DesignOSCornerGeometry.innerRadius(outerRadius: 32, inset: 8)
  let inner = DesignOSCornerGeometry.innerRadius(outerRadius: middle, inset: 12)
  #expect(inner == DesignOSCornerGeometry.innerRadius(outerRadius: 32, inset: 20))
  #expect(inner == 12)
}

@Test("Increasing an inset never increases or invalidates its inner corner radius")
func nestedCornerRadiusIsBoundedAndMonotonic() {
  var previous: CGFloat = 24
  for inset in 0...48 {
    let radius = DesignOSCornerGeometry.innerRadius(outerRadius: 24, inset: CGFloat(inset))
    #expect(radius >= 0)
    #expect(radius <= previous)
    #expect(radius.isFinite)
    previous = radius
  }
}
