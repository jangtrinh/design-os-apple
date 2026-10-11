import SwiftUI

/// Persistent selection summary and native completion actions, with large-text reflow.
///
/// Supply localized count/limit copy in summary. The app owns selection, filtering, completion
/// readiness and action guards; this component never clears hidden selections or disables controls.
/// Use intrinsic sizing for a content-width count action. It bounds ideal width to the host's
/// available width instead of fixing a pixel width or preventing long labels from wrapping.
public struct DesignOSSelectionSummary<Summary: View, Actions: View>: View {
  public enum Sizing: Hashable, Sendable {
    /// The summary consumes available width, leaving room for the caller's actions.
    case expanded
    /// Content keeps its ideal width when it fits and wraps within a narrower host.
    case intrinsic
  }

  @Environment(\.designOSAppStyle) private var style
  @Environment(\.dynamicTypeSize) private var dynamicTypeSize
  private let sizing: Sizing
  private let summary: Summary
  private let actions: Actions

  public init(
    sizing: Sizing = .expanded,
    @ViewBuilder summary: () -> Summary,
    @ViewBuilder actions: () -> Actions
  ) {
    self.sizing = sizing
    self.summary = summary()
    self.actions = actions()
  }

  public var body: some View {
    let layout =
      dynamicTypeSize.isAccessibilitySize
      ? AnyLayout(VStackLayout(alignment: .leading, spacing: style.metrics.itemSpacing))
      : AnyLayout(HStackLayout(alignment: .firstTextBaseline, spacing: style.metrics.itemSpacing))
    DesignOSSelectionSummaryWidthLayout(isIntrinsic: sizing == .intrinsic) {
      layout {
        if sizing == .expanded || Summary.self != EmptyView.self {
          VStack(alignment: .leading, spacing: style.metrics.itemSpacing) { summary }
            .frame(maxWidth: sizing == .expanded ? .infinity : nil, alignment: .leading)
            .fixedSize(horizontal: false, vertical: true)
        }
        if sizing == .expanded || Actions.self != EmptyView.self {
          VStack(alignment: .leading, spacing: style.metrics.itemSpacing) { actions }
        }
      }
    }
  }
}

// One layout child preserves the summary/action hierarchy and the native controls within it.
// Measuring the ideal width contains flexible button styles without horizontal fixedSize.
private struct DesignOSSelectionSummaryWidthLayout: Layout {
  let isIntrinsic: Bool

  func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
    guard let content = subviews.first else { return .zero }
    guard isIntrinsic else { return content.sizeThatFits(proposal) }
    let width = DesignOSSelectionSummarySizingPolicy.intrinsicWidth(
      idealWidth: content.sizeThatFits(.unspecified).width,
      proposedWidth: proposal.width
    )
    return content.sizeThatFits(ProposedViewSize(width: width, height: proposal.height))
  }

  func placeSubviews(
    in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()
  ) {
    subviews.first?.place(
      at: CGPoint(x: bounds.midX, y: bounds.midY), anchor: .center,
      proposal: ProposedViewSize(width: bounds.width, height: bounds.height)
    )
  }
}

internal enum DesignOSSelectionSummarySizingPolicy {
  static func intrinsicWidth(idealWidth: CGFloat, proposedWidth: CGFloat?) -> CGFloat {
    let ideal = DesignOSEditorialGeometry.length(idealWidth)
    guard let proposedWidth, proposedWidth.isFinite else { return ideal }
    return min(ideal, max(0, proposedWidth))
  }
}
