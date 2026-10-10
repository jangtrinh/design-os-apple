import SwiftUI

/// Persistent selection summary and native completion actions, with large-text reflow.
///
/// Supply localized count/limit copy in summary. The app owns selection, filtering, completion
/// readiness and action guards; this component never clears hidden selections or disables controls.
public struct DesignOSSelectionSummary<Summary: View, Actions: View>: View {
  @Environment(\.designOSAppStyle) private var style
  @Environment(\.dynamicTypeSize) private var dynamicTypeSize
  private let summary: Summary
  private let actions: Actions

  public init(@ViewBuilder summary: () -> Summary, @ViewBuilder actions: () -> Actions) {
    self.summary = summary()
    self.actions = actions()
  }

  public var body: some View {
    let layout =
      dynamicTypeSize.isAccessibilitySize
      ? AnyLayout(VStackLayout(alignment: .leading, spacing: style.metrics.itemSpacing))
      : AnyLayout(HStackLayout(alignment: .firstTextBaseline, spacing: style.metrics.itemSpacing))
    layout {
      VStack(alignment: .leading, spacing: style.metrics.itemSpacing) { summary }
        .frame(maxWidth: .infinity, alignment: .leading)
        .fixedSize(horizontal: false, vertical: true)
      VStack(alignment: .leading, spacing: style.metrics.itemSpacing) { actions }
    }
  }
}
