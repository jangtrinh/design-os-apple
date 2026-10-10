import SwiftUI

/// A readable status/control group over an app-owned map, camera or utility canvas.
///
/// An opaque adaptive surface protects contrast independently of the underlying image. Native
/// controls remain independently accessible; the component does not capture the surrounding
/// canvas, request permissions or dismiss results. Keep substantial result lists in a native sheet.
public struct DesignOSUtilityOverlay<Status: View, Actions: View>: View {
  @Environment(\.designOSAppStyle) private var style
  @Environment(\.dynamicTypeSize) private var dynamicTypeSize
  private let status: Status
  private let actions: Actions

  public init(@ViewBuilder status: () -> Status, @ViewBuilder actions: () -> Actions) {
    self.status = status()
    self.actions = actions()
  }

  public var body: some View {
    let layout =
      dynamicTypeSize.isAccessibilitySize
      ? AnyLayout(VStackLayout(alignment: .leading, spacing: style.metrics.itemSpacing))
      : AnyLayout(HStackLayout(alignment: .center, spacing: style.metrics.itemSpacing))
    DesignOSAppSurface {
      layout {
        VStack(alignment: .leading, spacing: style.metrics.itemSpacing) { status }
          .frame(maxWidth: .infinity, alignment: .leading)
          .fixedSize(horizontal: false, vertical: true)
        VStack(alignment: .leading, spacing: style.metrics.itemSpacing) { actions }
      }
    }
  }
}
