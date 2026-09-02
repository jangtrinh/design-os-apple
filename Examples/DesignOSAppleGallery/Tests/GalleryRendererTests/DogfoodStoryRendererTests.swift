import DesignOSAppleCatalog
import SwiftUI
import XCTest

@testable import DESIGN_OS_Apple

final class DogfoodStoryRendererTests: XCTestCase {
  @MainActor
  func testRendererInstantiatesEveryAdmittedDescriptor() {
    XCTAssertEqual(
      DesignOSReleaseCatalog.stories.count,
      DesignOSStoryID.currentExecutableCases.count
    )
    for descriptor in DesignOSReleaseCatalog.stories {
      let content = DogfoodStoryRenderer.render(descriptor: descriptor)
      acceptsView(content)
    }
  }

  private func acceptsView(_: some View) {}
}
