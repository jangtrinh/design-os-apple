import SwiftUI

/// Directional message content with optional reply context and persistent delivery metadata.
///
/// The native text/media and context-menu actions remain caller-owned. This component only
/// aligns and groups content: no invented sender, delivery state, network work or row gesture.
/// Neutral adaptive surfaces are the compatible default. Explicit outgoing emphasis uses
/// the palette's paired outgoingMessage colors; metadata stays outside that appearance.
/// For media filling this surface, derive its inner corner radius from the style surfaceRadius
/// and actual contentInset using DesignOSCornerGeometry, rather than reusing the outer radius.
public struct DesignOSMessageBubble<Reply: View, Content: View, Metadata: View>: View {
  public enum OutgoingAppearance: Hashable, Sendable {
    /// Preserves the standard surface without overriding the caller's foreground style.
    case neutral
    /// Uses the palette's outgoing-message foreground/background pair for outgoing content only.
    case emphasized
  }

  @Environment(\.designOSAppStyle) private var style
  private let isOutgoing: Bool
  private let outgoingAppearance: OutgoingAppearance
  private let reply: Reply
  private let content: Content
  private let metadata: Metadata

  public init(
    isOutgoing: Bool,
    outgoingAppearance: OutgoingAppearance = .neutral,
    @ViewBuilder reply: () -> Reply,
    @ViewBuilder content: () -> Content,
    @ViewBuilder metadata: () -> Metadata
  ) {
    self.isOutgoing = isOutgoing
    self.outgoingAppearance = outgoingAppearance
    self.reply = reply()
    self.content = content()
    self.metadata = metadata()
  }

  public var body: some View {
    VStack(alignment: isOutgoing ? .trailing : .leading, spacing: style.metrics.itemSpacing) {
      bubble
      metadata
        .fixedSize(horizontal: false, vertical: true)
    }
    .frame(maxWidth: .infinity, alignment: isOutgoing ? .trailing : .leading)
  }

  @ViewBuilder
  private var bubble: some View {
    if isOutgoing && outgoingAppearance == .emphasized {
      bubbleContent
        .foregroundStyle(style.palette.outgoingMessage.foreground.color)
        .padding(style.metrics.contentInset)
        .background(
          style.palette.outgoingMessage.background.color,
          in: RoundedRectangle(cornerRadius: style.metrics.surfaceRadius, style: .continuous)
        )
    } else {
      DesignOSAppSurface(tone: isOutgoing ? .standard : .subtle) { bubbleContent }
    }
  }

  private var bubbleContent: some View {
    VStack(alignment: .leading, spacing: style.metrics.itemSpacing) {
      reply
      content
    }
    .fixedSize(horizontal: false, vertical: true)
  }
}

extension DesignOSMessageBubble where Reply == EmptyView {
  public init(
    isOutgoing: Bool,
    outgoingAppearance: OutgoingAppearance = .neutral,
    @ViewBuilder content: () -> Content,
    @ViewBuilder metadata: () -> Metadata
  ) {
    self.init(
      isOutgoing: isOutgoing, outgoingAppearance: outgoingAppearance,
      reply: { EmptyView() }, content: content, metadata: metadata
    )
  }
}
