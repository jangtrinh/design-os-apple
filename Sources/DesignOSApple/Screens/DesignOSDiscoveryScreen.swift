import SwiftUI

/// Discovery hierarchy with introduction, horizontal category/media rails and open sections.
///
/// Rails may contain horizontal ScrollViews; sections must not contain another vertical List
/// or ScrollView. The app supplies search navigation, category selection and loading states.
public struct DesignOSDiscoveryScreen<Introduction: View, Rails: View, Sections: View>: View {
  @Environment(\.designOSAppStyle) private var style
  private let introduction: Introduction
  private let rails: Rails
  private let sections: Sections

  public init(
    @ViewBuilder introduction: () -> Introduction,
    @ViewBuilder rails: () -> Rails,
    @ViewBuilder sections: () -> Sections
  ) {
    self.introduction = introduction()
    self.rails = rails()
    self.sections = sections()
  }

  public var body: some View {
    DesignOSFlatScrollShell {
      VStack(alignment: .leading, spacing: style.metrics.sectionSpacing) {
        introduction
        rails
        sections
      }
    }
  }
}
