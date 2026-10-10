import SwiftUI

/// Native two-column adaptive navigation with caller-owned visibility and destinations.
///
/// The sidebar supplies a native selection List. The detail may supply its own NavigationStack
/// and bound path. SwiftUI owns compact adaptation; this shell invents no route model or tabs.
public struct DesignOSAdaptiveNavigationShell<Sidebar: View, Detail: View>: View {
  @Binding private var columnVisibility: NavigationSplitViewVisibility
  private let sidebar: Sidebar
  private let detail: Detail

  public init(
    columnVisibility: Binding<NavigationSplitViewVisibility>,
    @ViewBuilder sidebar: () -> Sidebar,
    @ViewBuilder detail: () -> Detail
  ) {
    self._columnVisibility = columnVisibility
    self.sidebar = sidebar()
    self.detail = detail()
  }

  public var body: some View {
    NavigationSplitView(columnVisibility: $columnVisibility) {
      sidebar
    } detail: {
      detail
    }
  }
}
