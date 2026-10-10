import SwiftUI

/// A quiet, full-pill content action with standard native `Button` interaction.
///
/// Shares primary-action sizing, focus, hover, pressed, and disabled behavior. A native
/// destructive role retains its semantics and receives a readable adaptive red label.
public struct DesignOSSecondaryButtonStyle: ButtonStyle {
  public init() {}

  public func makeBody(configuration: Configuration) -> some View {
    DesignOSActionButtonContent(configuration: configuration, prominence: .secondary)
  }
}
