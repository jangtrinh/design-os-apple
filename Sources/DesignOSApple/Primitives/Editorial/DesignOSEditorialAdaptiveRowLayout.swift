import SwiftUI

/// Measurement policy used by the adaptive layout and directly exercised in unit tests.
internal enum DesignOSEditorialRowPolicy {
  static func usesVerticalLayout(
    availableWidth: CGFloat?, idealWidths: [CGFloat], spacing: CGFloat,
    accessibilitySize: Bool
  ) -> Bool {
    guard !accessibilitySize else { return true }
    guard idealWidths.allSatisfy({ $0.isFinite && $0 >= 0 }) else { return true }
    guard let availableWidth else { return false }
    guard availableWidth.isFinite, availableWidth >= 0 else { return true }
    let gaps =
      CGFloat(max(0, idealWidths.count - 1))
      * DesignOSEditorialGeometry.length(spacing)
    let total = idealWidths.reduce(0, +) + gaps
    return !total.isFinite || total > availableWidth
  }

  /// The label and accessory keep their intrinsic widths; the value receives remaining space.
  /// Used only after the fit policy admits a horizontal layout.
  static func horizontalWidths(
    availableWidth: CGFloat, idealWidths: [CGFloat], spacing: CGFloat
  ) -> [CGFloat] {
    guard !idealWidths.isEmpty else { return [] }
    let flexibleIndex = min(1, idealWidths.count - 1)
    let safeWidths = idealWidths.map { DesignOSEditorialGeometry.length($0) }
    let gaps =
      CGFloat(max(0, idealWidths.count - 1))
      * DesignOSEditorialGeometry.length(spacing)
    let fixedWidth = safeWidths.enumerated().reduce(CGFloat.zero) { total, item in
      item.offset == flexibleIndex ? total : total + item.element
    }
    let flexibleWidth = DesignOSEditorialGeometry.length(
      max(0, DesignOSEditorialGeometry.length(availableWidth) - gaps - fixedWidth)
    )
    return safeWidths.enumerated().map { index, width in
      index == flexibleIndex ? flexibleWidth : width
    }
  }
}

/// Reflows the same native subviews, preserving their identity when width or text size changes.
internal struct DesignOSEditorialAdaptiveRowLayout: Layout {
  let spacing: CGFloat
  let accessibilitySize: Bool
  let layoutDirection: LayoutDirection

  func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
    let measured = measure(proposal: proposal, subviews: subviews)
    return measured.size
  }

  func placeSubviews(
    in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()
  ) {
    let measured = measure(
      proposal: ProposedViewSize(width: bounds.width, height: nil), subviews: subviews)
    var offset: CGFloat = 0
    for (index, subview) in subviews.enumerated() {
      let size = measured.children[index]
      let x: CGFloat
      let y: CGFloat
      if measured.vertical {
        x = bounds.minX
        y = bounds.minY + offset
        offset += size.height + safeSpacing
      } else {
        x =
          layoutDirection == .rightToLeft
          ? bounds.maxX - offset - size.width : bounds.minX + offset
        y = bounds.minY + (measured.size.height - size.height) / 2
        offset += size.width + safeSpacing
      }
      subview.place(
        at: CGPoint(x: x, y: y), anchor: .topLeading,
        proposal: ProposedViewSize(width: size.width, height: size.height)
      )
    }
  }

  private var safeSpacing: CGFloat { DesignOSEditorialGeometry.length(spacing) }

  private func measure(proposal: ProposedViewSize, subviews: Subviews) -> Measurement {
    guard !subviews.isEmpty else { return Measurement(size: .zero, children: [], vertical: true) }
    let ideals = subviews.map { $0.sizeThatFits(.unspecified) }
    let width = proposal.width.flatMap { $0.isFinite && $0 >= 0 ? $0 : nil }
    let vertical = DesignOSEditorialRowPolicy.usesVerticalLayout(
      availableWidth: width, idealWidths: ideals.map(\.width), spacing: safeSpacing,
      accessibilitySize: accessibilitySize
    )
    let gaps = CGFloat(max(0, subviews.count - 1)) * safeSpacing
    let naturalWidth =
      vertical
      ? ideals.map { DesignOSEditorialGeometry.length($0.width) }.max() ?? 0
      : ideals.reduce(0) { $0 + DesignOSEditorialGeometry.length($1.width) } + gaps
    let resolvedWidth = width ?? DesignOSEditorialGeometry.length(naturalWidth)
    var children: [CGSize] = []
    let horizontalWidths = DesignOSEditorialRowPolicy.horizontalWidths(
      availableWidth: resolvedWidth, idealWidths: ideals.map(\.width), spacing: safeSpacing
    )
    for (index, subview) in subviews.enumerated() {
      let childWidth: CGFloat
      if vertical {
        childWidth = resolvedWidth
      } else {
        childWidth = horizontalWidths[index]
      }
      let size = subview.sizeThatFits(ProposedViewSize(width: childWidth, height: nil))
      children.append(
        CGSize(width: childWidth, height: DesignOSEditorialGeometry.length(size.height)))
    }
    let height =
      vertical
      ? children.reduce(0) { $0 + $1.height } + gaps
      : children.map(\.height).max() ?? 0
    return Measurement(
      size: CGSize(width: resolvedWidth, height: height), children: children, vertical: vertical
    )
  }

  private struct Measurement {
    let size: CGSize
    let children: [CGSize]
    let vertical: Bool
  }
}
