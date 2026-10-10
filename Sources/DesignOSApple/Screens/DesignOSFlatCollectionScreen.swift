import SwiftUI

/// A flat collection screen with section heading, native rows and a caller-selected status.
///
/// Set showsStatus for loading, empty, no-results or failure, and supply the corresponding
/// native ContentUnavailableView or status composition. Status replaces the rows, not the
/// app's navigation. The app owns state transitions, filtering, recovery and destinations.
public struct DesignOSFlatCollectionScreen<Header: View, Rows: View, Status: View>: View {
  private let showsStatus: Bool
  private let header: Header
  private let rows: Rows
  private let status: Status

  public init(
    showsStatus: Bool,
    @ViewBuilder header: () -> Header,
    @ViewBuilder rows: () -> Rows,
    @ViewBuilder status: () -> Status
  ) {
    self.showsStatus = showsStatus
    self.header = header()
    self.rows = rows()
    self.status = status()
  }

  public var body: some View {
    DesignOSFlatListShell {
      if showsStatus {
        status
          .listRowSeparator(.hidden)
          .listRowBackground(Color.clear)
      } else {
        Section {
          rows
        } header: {
          header
        }
      }
    }
  }
}

extension DesignOSFlatCollectionScreen where Status == EmptyView {
  /// Creates a populated collection. Use the status initializer for explicit non-content states.
  public init(@ViewBuilder header: () -> Header, @ViewBuilder rows: () -> Rows) {
    self.init(showsStatus: false, header: header, rows: rows, status: { EmptyView() })
  }
}
