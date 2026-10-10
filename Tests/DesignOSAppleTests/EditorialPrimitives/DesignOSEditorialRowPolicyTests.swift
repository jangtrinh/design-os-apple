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

@Test("The same adaptive row supports both native reading directions")
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
    #expect(String(reflecting: type(of: row)).contains("DesignOSEditorialAdaptiveRowLayout"))
  }
}
