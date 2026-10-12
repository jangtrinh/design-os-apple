import CoreGraphics
import SwiftUI
import Testing

@testable import DesignOSApple

@Test("Labeled rows reserve each real gap before choosing horizontal layout")
func editorialRowsMeasureActualGaps() {
  #expect(
    !DesignOSEditorialRowPolicy.usesVerticalLayout(
      availableWidth: 204, idealWidths: [80, 80, 20], spacing: 12, accessibilitySize: false
    ))
  #expect(
    DesignOSEditorialRowPolicy.usesVerticalLayout(
      availableWidth: 203, idealWidths: [80, 80, 20], spacing: 12, accessibilitySize: false
    ))
}

@Test("The value receives spare width while label and accessory keep intrinsic widths")
func editorialRowValueOwnsFlexibleWidth() {
  #expect(
    DesignOSEditorialRowPolicy.horizontalWidths(
      availableWidth: 300, idealWidths: [80, 100, 20], spacing: 12
    ) == [80, 176, 20])
  #expect(
    DesignOSEditorialRowPolicy.horizontalWidths(
      availableWidth: 300, idealWidths: [80, 100], spacing: 12
    ) == [80, 208])
}

@Test("Degenerate horizontal row allocations remain bounded and finite")
func editorialRowAllocationHandlesEmptyAndSingleSlots() {
  #expect(
    DesignOSEditorialRowPolicy.horizontalWidths(
      availableWidth: 100, idealWidths: [], spacing: 12
    ).isEmpty)
  #expect(
    DesignOSEditorialRowPolicy.horizontalWidths(
      availableWidth: 100, idealWidths: [50], spacing: 12
    ) == [100])
}

@Test("Long labels and narrow windows trigger structural vertical reflow")
func editorialRowsReflowWhenContentDoesNotFit() {
  #expect(
    DesignOSEditorialRowPolicy.usesVerticalLayout(
      availableWidth: 280, idealWidths: [220, 120], spacing: 12, accessibilitySize: false
    ))
  #expect(
    !DesignOSEditorialRowPolicy.usesVerticalLayout(
      availableWidth: 600, idealWidths: [220, 120], spacing: 12, accessibilitySize: false
    ))
}

@Test("Accessibility text sizes always use vertical labeled rows")
func editorialRowsRespectAccessibilitySizes() {
  #expect(
    DesignOSEditorialRowPolicy.usesVerticalLayout(
      availableWidth: 1200, idealWidths: [50, 50], spacing: 12, accessibilitySize: true
    ))
}

@Test("Editorial row measurement handles unspecified and invalid proposals")
func editorialRowsHandleProposalEdges() {
  #expect(
    !DesignOSEditorialRowPolicy.usesVerticalLayout(
      availableWidth: nil, idealWidths: [80, 100], spacing: 12, accessibilitySize: false
    ))
  for width in [CGFloat(-1), .nan, .infinity] {
    #expect(
      DesignOSEditorialRowPolicy.usesVerticalLayout(
        availableWidth: width, idealWidths: [80, 100], spacing: 12, accessibilitySize: false
      ))
  }
  #expect(
    DesignOSEditorialRowPolicy.usesVerticalLayout(
      availableWidth: 400, idealWidths: [.infinity, 100], spacing: 12, accessibilitySize: false
    ))
}

@Test("Empty and single-content row measurements have no invented gap")
func editorialRowsOnlyCountExistingGaps() {
  #expect(
    !DesignOSEditorialRowPolicy.usesVerticalLayout(
      availableWidth: 0, idealWidths: [], spacing: 12, accessibilitySize: false
    ))
  #expect(
    !DesignOSEditorialRowPolicy.usesVerticalLayout(
      availableWidth: 80, idealWidths: [80], spacing: 12, accessibilitySize: false
    ))
}

@Test("Editorial row spacing remains finite even for invalid input")
func editorialRowsIgnoreInvalidSpacing() {
  for spacing in [CGFloat(-1), .nan, .infinity] {
    #expect(
      !DesignOSEditorialRowPolicy.usesVerticalLayout(
        availableWidth: 100, idealWidths: [50, 50], spacing: spacing, accessibilitySize: false
      ))
  }
}

@Test("Asymmetric row slots use logical coordinates in both reading directions")
@MainActor
func editorialRowPlacementsLeaveRTLMirroringToSwiftUI() {
  let ideals = [
    CGSize(width: 73, height: 18), CGSize(width: 129, height: 44),
    CGSize(width: 31, height: 26),
  ]
  for direction in [LayoutDirection.leftToRight, .rightToLeft] {
    let layout = DesignOSEditorialAdaptiveRowLayout(
      spacing: 12, accessibilitySize: false, layoutDirection: direction)
    var proposedWidths: [CGFloat?] = []
    let measured = layout.measure(
      proposal: ProposedViewSize(width: 360, height: 1), ideals: ideals
    ) { index, proposal in
      proposedWidths.append(proposal.width)
      #expect(proposal.height == nil)
      return ideals[index]
    }
    #expect(!measured.vertical)
    #expect(proposedWidths == [73, 232, 31])
    #expect(measured.size == CGSize(width: 360, height: 44))
    #expect(measured.children.map(\.width) == [73, 232, 31])
    #expect(measured.children.map(\.height) == [18, 44, 26])

    for origin in [CGPoint.zero, CGPoint(x: 37, y: 19), CGPoint(x: -51, y: -27)] {
      let bounds = CGRect(origin: origin, size: measured.size)
      let placements = layout.placementOrigins(in: bounds, measurement: measured)
      // These are the actual points passed to LayoutSubview.place, before SwiftUI
      // mirrors RTL frames. An explicit RTL branch here would mirror them twice.
      #expect(
        placements == [
          CGPoint(x: origin.x, y: origin.y + 13),
          CGPoint(x: origin.x + 85, y: origin.y),
          CGPoint(x: origin.x + 329, y: origin.y + 9),
        ])
      for index in 0..<placements.count - 1 {
        #expect(
          placements[index + 1].x
            - (placements[index].x + measured.children[index].width) == 12)
      }
      #expect(placements[2].x + measured.children[2].width == bounds.maxX)
    }
  }
}

@Test("Narrow and accessibility rows keep vertical source order in LTR and RTL")
@MainActor
func editorialRowVerticalPlacementsPreserveOrder() {
  let ideals = [
    CGSize(width: 73, height: 20), CGSize(width: 129, height: 52),
    CGSize(width: 31, height: 30),
  ]
  for direction in [LayoutDirection.leftToRight, .rightToLeft] {
    for accessibilitySize in [false, true] {
      let width: CGFloat = accessibilitySize ? 600 : 210
      let layout = DesignOSEditorialAdaptiveRowLayout(
        spacing: 12, accessibilitySize: accessibilitySize, layoutDirection: direction)
      var measuredIndices: [Int] = []
      let measured = layout.measure(
        proposal: ProposedViewSize(width: width, height: nil), ideals: ideals
      ) { index, proposal in
        measuredIndices.append(index)
        #expect(proposal.width == width)
        #expect(proposal.height == nil)
        return ideals[index]
      }
      #expect(measured.vertical)
      #expect(measuredIndices == [0, 1, 2])
      #expect(measured.size == CGSize(width: width, height: 126))
      #expect(measured.children.map(\.width) == [width, width, width])
      let bounds = CGRect(x: 37, y: 19, width: width, height: 126)
      #expect(
        layout.placementOrigins(in: bounds, measurement: measured) == [
          CGPoint(x: 37, y: 19), CGPoint(x: 37, y: 51), CGPoint(x: 37, y: 115),
        ])
    }
  }
}

@Test("Unspecified and unusable widths retain the finite natural measurement fallback")
@MainActor
func editorialRowMeasurementPreservesProposalFallbacks() {
  let ideals = [CGSize(width: 73, height: 18), CGSize(width: 129, height: 44)]
  let layout = DesignOSEditorialAdaptiveRowLayout(
    spacing: 12, accessibilitySize: false, layoutDirection: .rightToLeft)
  let natural = layout.measure(proposal: .unspecified, ideals: ideals) { index, _ in
    ideals[index]
  }
  #expect(!natural.vertical)
  #expect(natural.size == CGSize(width: 214, height: 44))
  #expect(natural.children.map(\.width) == [73, 129])

  for width in [CGFloat(-1), .nan, .infinity, -.infinity] {
    let measured = layout.measure(
      proposal: ProposedViewSize(width: width, height: nil), ideals: ideals
    ) { index, proposal in
      #expect(proposal.width == ideals[index].width)
      return ideals[index]
    }
    #expect(!measured.vertical)
    #expect(measured.size == natural.size)
    #expect(measured.children == natural.children)
  }
  let zero = layout.measure(
    proposal: ProposedViewSize(width: 0, height: nil), ideals: ideals
  ) { index, proposal in
    #expect(proposal.width == 0)
    return ideals[index]
  }
  #expect(zero.vertical)
  #expect(zero.size == CGSize(width: 0, height: 74))
}

@Test("Invalid ideal widths and measured child sizes never enter placement geometry")
@MainActor
func editorialRowMeasurementSanitizesChildSizes() {
  let layout = DesignOSEditorialAdaptiveRowLayout(
    spacing: 12, accessibilitySize: false, layoutDirection: .rightToLeft)
  for invalid in [CGFloat(-1), .nan, .infinity, -.infinity] {
    let measured = layout.measure(
      proposal: .unspecified,
      ideals: [CGSize(width: invalid, height: 20), CGSize(width: 50, height: 30)]
    ) { _, proposal in
      #expect(proposal.width == 50)
      return CGSize(width: invalid, height: invalid)
    }
    #expect(measured.vertical)
    #expect(measured.size == CGSize(width: 50, height: 12))
    #expect(measured.children == [CGSize(width: 50, height: 0), CGSize(width: 50, height: 0)])
    #expect(
      layout.placementOrigins(
        in: CGRect(x: 37, y: 19, width: 50, height: 12), measurement: measured
      ) == [CGPoint(x: 37, y: 19), CGPoint(x: 37, y: 31)])
  }
}

@Test("Invalid spacing cannot add gaps to measured or placed rows")
@MainActor
func editorialRowMeasurementSanitizesSpacing() {
  let ideals = [CGSize(width: 73, height: 20), CGSize(width: 129, height: 20)]
  for spacing in [CGFloat(-1), .nan, .infinity, -.infinity] {
    for vertical in [false, true] {
      let layout = DesignOSEditorialAdaptiveRowLayout(
        spacing: spacing, accessibilitySize: vertical, layoutDirection: .rightToLeft)
      let measured = layout.measure(
        proposal: ProposedViewSize(width: 300, height: nil), ideals: ideals
      ) { index, _ in ideals[index] }
      #expect(measured.vertical == vertical)
      #expect(measured.size == CGSize(width: 300, height: vertical ? 40 : 20))
      #expect(
        layout.placementOrigins(
          in: CGRect(origin: .zero, size: measured.size), measurement: measured
        ) == [CGPoint.zero, vertical ? CGPoint(x: 0, y: 20) : CGPoint(x: 73, y: 0)])
    }
  }
}

@Test("Empty and single-slot rows keep measurement and placement counts aligned")
@MainActor
func editorialRowMeasurementHandlesEmptyAndSingleSlots() {
  for direction in [LayoutDirection.leftToRight, .rightToLeft] {
    let layout = DesignOSEditorialAdaptiveRowLayout(
      spacing: 12, accessibilitySize: false, layoutDirection: direction)
    let empty = layout.measure(proposal: .unspecified, ideals: []) { _, _ in
      Issue.record("An empty row must not measure a child")
      return .zero
    }
    #expect(empty.size == .zero)
    #expect(empty.children.isEmpty)
    #expect(layout.placementOrigins(in: .zero, measurement: empty).isEmpty)

    let single = layout.measure(
      proposal: ProposedViewSize(width: 100, height: nil),
      ideals: [CGSize(width: 50, height: 20)]
    ) { index, proposal in
      #expect(index == 0)
      #expect(proposal.width == 100)
      return CGSize(width: 50, height: 20)
    }
    #expect(!single.vertical)
    #expect(single.size == CGSize(width: 100, height: 20))
    #expect(single.children == [CGSize(width: 100, height: 20)])
    #expect(
      layout.placementOrigins(
        in: CGRect(x: 37, y: 19, width: 100, height: 20), measurement: single
      ) == [CGPoint(x: 37, y: 19)])
  }
}

@Test("The adaptive row compiles with native controls in both environment directions")
@MainActor
func editorialRowLayoutCompilesForBothDirections() {
  for direction in [LayoutDirection.leftToRight, .rightToLeft] {
    let row = DesignOSEditorialAdaptiveRowLayout(
      spacing: 12, accessibilitySize: false, layoutDirection: direction
    ) {
      Text("Name")
      TextField("Display name", text: .constant("A complete name"))
      Button("Edit") {}
    }
    .environment(\.layoutDirection, direction)
    #expect(String(reflecting: type(of: row)).contains("DesignOSEditorialAdaptiveRowLayout"))
  }
}
