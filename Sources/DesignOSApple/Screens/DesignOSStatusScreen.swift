import SwiftUI

/// A durable result/status hierarchy with explanation, optional details and recovery actions.
///
/// Supply EmptyView for absent details or actions. Announcements, retry state and confirmed
/// success are app-owned; this screen never infers success from disappearance of a spinner.
public struct DesignOSStatusScreen<
  Symbol: View, Message: View, Details: View, Actions: View
>: View {
  @Environment(\.designOSAppStyle) private var style
  private let symbol: Symbol
  private let message: Message
  private let details: Details
  private let actions: Actions

  public init(
    @ViewBuilder symbol: () -> Symbol,
    @ViewBuilder message: () -> Message,
    @ViewBuilder details: () -> Details,
    @ViewBuilder actions: () -> Actions
  ) {
    self.symbol = symbol()
    self.message = message()
    self.details = details()
    self.actions = actions()
  }

  public var body: some View {
    DesignOSFocusedTaskShell {
      VStack(alignment: .leading, spacing: style.metrics.sectionSpacing) {
        symbol
        message
        details
      }
    } action: {
      actions
    }
  }
}
