import CoreGraphics
import Testing

@testable import DesignOSApple

@Test("Editorial media ratios retain valid caller geometry")
func editorialMediaRatiosKeepValidValues() {
  // Keep both operands CGFloat. Mixed numeric inference can select AnyHashable equality
  // inside #expect despite identical values: https://github.com/swiftlang/swift/issues/91221.
  let ratios: [CGFloat] = [0.5, 1, 4.0 / 3.0, 16.0 / 9.0, 2]
  for ratio in ratios {
    let actual: CGFloat = DesignOSEditorialGeometry.aspectRatio(ratio)
    #expect(actual == ratio)
    #expect(Double(actual).bitPattern == Double(ratio).bitPattern)
  }
}

@Test("Invalid editorial aspect ratios use a finite square")
func editorialMediaRatiosFailClosed() {
  for ratio in [CGFloat.zero, -1, .nan, .infinity, -.infinity] {
    #expect(DesignOSEditorialGeometry.aspectRatio(ratio) == 1)
  }
}

@Test("Editorial lengths never propagate negative or non-finite geometry")
func editorialLengthsAreFiniteAndNonnegative() {
  for length in [CGFloat(-1), .nan, .infinity, -.infinity] {
    #expect(DesignOSEditorialGeometry.length(length) == 0)
  }
  for length in [CGFloat.zero, 0.5, 24, 80] {
    #expect(DesignOSEditorialGeometry.length(length) == length)
  }
}

@Test("Avatars take a positive caller diameter or the actual style fallback")
func editorialAvatarDiameterRespectsStyle() {
  #expect(DesignOSEditorialGeometry.diameter(40, fallback: 80) == 40)
  #expect(DesignOSEditorialGeometry.diameter(nil, fallback: 80) == 80)
  for value in [CGFloat.zero, -1, .nan, .infinity, -.infinity] {
    #expect(DesignOSEditorialGeometry.diameter(value, fallback: 80) == 80)
  }
  #expect(DesignOSEditorialGeometry.diameter(nil, fallback: .nan) == 1)
}

@Test("Continuous media corners are bounded by the actual rendered frame")
func editorialCornersFollowRenderedBounds() {
  #expect(DesignOSEditorialGeometry.cornerRadius(24, in: CGSize(width: 240, height: 180)) == 24)
  #expect(DesignOSEditorialGeometry.cornerRadius(24, in: CGSize(width: 30, height: 180)) == 15)
  #expect(DesignOSEditorialGeometry.cornerRadius(24, in: CGSize(width: 240, height: 20)) == 10)
  #expect(DesignOSEditorialGeometry.cornerRadius(24, in: .zero) == 0)
  #expect(DesignOSEditorialGeometry.cornerRadius(.nan, in: CGSize(width: 80, height: 80)) == 0)
  #expect(DesignOSEditorialGeometry.cornerRadius(-5, in: CGSize(width: 80, height: 80)) == 0)
}

@Test("Nested media uses the existing outer-minus-actual-inset policy")
func editorialMediaReusesNestedRadiusPolicy() {
  let inner = DesignOSCornerGeometry.innerRadius(outerRadius: 24, inset: 8)
  #expect(DesignOSEditorialGeometry.cornerRadius(inner, in: CGSize(width: 100, height: 100)) == 16)
}
