import SwiftUI

/// Utility canvas with visible state and native controls over a real app-owned integration.
///
/// Use an actual map/viewfinder/media editor for canvas. Supply permission-denied, unavailable
/// and result states explicitly; owning this screen does not establish camera/provider access.
public struct DesignOSUtilityCanvasScreen<Canvas: View, Status: View, Controls: View>: View {
  private let canvas: Canvas
  private let status: Status
  private let controls: Controls

  public init(
    @ViewBuilder canvas: () -> Canvas,
    @ViewBuilder status: () -> Status,
    @ViewBuilder controls: () -> Controls
  ) {
    self.canvas = canvas()
    self.status = status()
    self.controls = controls()
  }

  public var body: some View {
    DesignOSUtilityCanvasShell {
      canvas
    } overlay: {
      status
    } controls: {
      controls
    }
  }
}
