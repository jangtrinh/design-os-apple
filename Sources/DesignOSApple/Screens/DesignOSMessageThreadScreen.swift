import SwiftUI

/// Stable-ID message history, visible delivery state and a real app-owned composer.
///
/// Supply messages as a LazyVStack/ForEach, with native context menus and accessibility.
/// The app owns ordering, reply state, attachments, delivery and explicit scroll decisions.
public struct DesignOSMessageThreadScreen<Messages: View, Status: View, Composer: View>: View {
  @Environment(\.designOSAppStyle) private var style
  private let messages: (ScrollViewProxy) -> Messages
  private let status: Status
  private let composer: Composer

  public init(
    @ViewBuilder messages: @escaping (ScrollViewProxy) -> Messages,
    @ViewBuilder status: () -> Status,
    @ViewBuilder composer: () -> Composer
  ) {
    self.messages = messages
    self.status = status()
    self.composer = composer()
  }

  public var body: some View {
    DesignOSConversationShell { proxy in
      VStack(alignment: .leading, spacing: style.metrics.itemSpacing) {
        messages(proxy)
        status
      }
    } composer: {
      composer
    }
  }
}
