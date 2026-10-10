import SwiftUI

/// Native searchable, selectable results with explicit caller-selected status content.
///
/// Supply tagged rows whose tag types match SelectionValue. The app filters results, keeps or
/// invalidates hidden selections intentionally, and supplies Done/editing actions. The screen
/// never resets selection when the query changes or substitutes gestures for List selection.
public struct DesignOSSearchSelectionScreen<
  SelectionValue: Hashable, Rows: View, Status: View
>: View {
  @Binding private var query: String
  private let selection: Selection
  private let showsStatus: Bool
  private let rows: Rows
  private let status: Status

  private enum Selection {
    case single(Binding<SelectionValue?>)
    case multiple(Binding<Set<SelectionValue>>)
  }

  public init(
    query: Binding<String>,
    selection: Binding<SelectionValue?>,
    showsStatus: Bool = false,
    @ViewBuilder rows: () -> Rows,
    @ViewBuilder status: () -> Status
  ) {
    self._query = query
    self.selection = .single(selection)
    self.showsStatus = showsStatus
    self.rows = rows()
    self.status = status()
  }

  public init(
    query: Binding<String>,
    selection: Binding<Set<SelectionValue>>,
    showsStatus: Bool = false,
    @ViewBuilder rows: () -> Rows,
    @ViewBuilder status: () -> Status
  ) {
    self._query = query
    self.selection = .multiple(selection)
    self.showsStatus = showsStatus
    self.rows = rows()
    self.status = status()
  }

  public var body: some View {
    Group {
      switch selection {
      case .single(let binding):
        DesignOSFlatListShell(selection: binding) { resultContent }
      case .multiple(let binding):
        DesignOSFlatListShell(selection: binding) { resultContent }
      }
    }
    .searchable(text: $query)
  }

  @ViewBuilder private var resultContent: some View {
    if showsStatus {
      status
        .listRowSeparator(.hidden)
        .listRowBackground(Color.clear)
    } else {
      rows
    }
  }
}
