import SwiftUI

/// Context plus a real native presentation anchor, without drawing substitute system UI.
///
/// Attach alert, confirmationDialog, sheet, popover or native Menu/Picker to the anchor.
/// Presentation bindings and toolbar placement belong to the app; no presentation is automatic.
public struct DesignOSNativePresentationScreen<Anchor: View, Context: View>: View {
  @Environment(\.designOSAppStyle) private var style
  private let anchor: Anchor
  private let context: Context

  public init(
    @ViewBuilder anchor: () -> Anchor,
    @ViewBuilder context: () -> Context
  ) {
    self.anchor = anchor()
    self.context = context()
  }

  public var body: some View {
    DesignOSNativeHostShell {
      VStack(alignment: .leading, spacing: style.metrics.itemSpacing) {
        context
        anchor
      }
    }
  }
}
