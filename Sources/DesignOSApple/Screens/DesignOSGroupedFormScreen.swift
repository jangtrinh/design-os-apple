import SwiftUI

/// Management/settings composition with separate ordinary and consequential native Sections.
///
/// Native Form owns grouping, scrolling and control behavior. Supply EmptyView when no
/// consequential section exists. The app supplies destructive Button roles and presents
/// native confirmationDialog or alert, including the actual consequences and cancellation.
public struct DesignOSGroupedFormScreen<Sections: View, Consequential: View>: View {
  private let sections: Sections
  private let consequential: Consequential

  public init(
    @ViewBuilder sections: () -> Sections,
    @ViewBuilder consequential: () -> Consequential
  ) {
    self.sections = sections()
    self.consequential = consequential()
  }

  public var body: some View {
    DesignOSGroupedFormShell {
      sections
      consequential
    }
  }
}

extension DesignOSGroupedFormScreen where Consequential == EmptyView {
  public init(@ViewBuilder sections: () -> Sections) {
    self.init(sections: sections, consequential: { EmptyView() })
  }
}
