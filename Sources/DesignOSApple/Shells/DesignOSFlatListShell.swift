import SwiftUI

/// A flat native List with optional native single/multiple selection, without routing or cards.
///
/// Supply tagged native rows and Sections, never another vertical scroll container. The app
/// owns stable selection IDs, filtering and editing policy. Native platform selection behavior
/// is preserved rather than simulated with row-wide gestures or custom checkmarks.
public struct DesignOSFlatListShell<Content: View, SelectionValue: Hashable>: View {
  @Environment(\.designOSAppStyle) private var style
  private let content: Content
  private let selection: Selection

  private enum Selection {
    case none
    case single(Binding<SelectionValue?>)
    case multiple(Binding<Set<SelectionValue>>)
  }

  public init(selection: Binding<SelectionValue?>, @ViewBuilder content: () -> Content) {
    self.selection = .single(selection)
    self.content = content()
  }

  public init(selection: Binding<Set<SelectionValue>>, @ViewBuilder content: () -> Content) {
    self.selection = .multiple(selection)
    self.content = content()
  }

  public var body: some View {
    Group {
      switch selection {
      case .none:
        List { content }
      case .single(let binding):
        List(selection: binding) { content }
      case .multiple(let binding):
        List(selection: binding) { content }
      }
    }
    .listStyle(.plain)
    .scrollContentBackground(.hidden)
    .background(style.palette.canvas.color)
  }
}

extension DesignOSFlatListShell where SelectionValue == Never {
  public init(@ViewBuilder content: () -> Content) {
    self.selection = .none
    self.content = content()
  }
}
