import SwiftUI

/// The two image scales recorded by the source row families.
package enum SymbolContentScale: CaseIterable, Sendable {
  case regular
  case tall

  fileprivate var fillSide: CGFloat {
    switch self {
    case .regular: 52
    case .tall: 68
    }
  }

  fileprivate var circularSide: CGFloat {
    switch self {
    case .regular: 42
    case .tall: 60
    }
  }

  fileprivate var roundedSide: CGFloat {
    switch self {
    case .regular: 30
    case .tall: 44
    }
  }

  fileprivate var roundedRadius: CGFloat {
    switch self {
    case .regular: 7
    case .tall: 11
    }
  }
}

/// Caller-owned image presentation policies recorded by the source row families.
package enum SymbolContentKind: CaseIterable, Sendable {
  case fill
  case circular
  case rounded
  case symbol
}

/// Applies image geometry while keeping image bytes, labels, and actions caller-owned.
package struct SymbolContent<Content: View>: View {
  private let scale: SymbolContentScale
  private let kind: SymbolContentKind
  private let content: Content

  package init(
    scale: SymbolContentScale,
    kind: SymbolContentKind,
    @ViewBuilder content: () -> Content
  ) {
    self.scale = scale
    self.kind = kind
    self.content = content()
  }

  @ViewBuilder
  package var body: some View {
    switch kind {
    case .fill:
      content
        .aspectRatio(contentMode: .fill)
        .frame(width: scale.fillSide, height: scale.fillSide)
        .clipped()
    case .circular:
      content
        .aspectRatio(contentMode: .fill)
        .frame(width: scale.circularSide, height: scale.circularSide)
        .clipShape(Circle())
    case .rounded:
      content
        .aspectRatio(contentMode: .fill)
        .frame(width: scale.roundedSide, height: scale.roundedSide)
        .clipShape(RoundedRectangle(cornerRadius: scale.roundedRadius, style: .continuous))
    case .symbol:
      content
    }
  }
}
