import DesignOSAppleCatalog
import XCTest

@testable import DESIGN_OS_Apple

final class DogfoodStoryPresentationTests: XCTestCase {
  func testEveryAdmittedDescriptorHasTheExactCanvasPolicy() {
    let actual = Dictionary(
      uniqueKeysWithValues: DesignOSReleaseCatalog.stories.map {
        ($0.id, DogfoodStoryPresentation.presentation(for: $0.id))
      })
    XCTAssertEqual(actual.count, DesignOSStoryID.allCases.count)
    XCTAssertEqual(actual[.omniactSettingsShell], .fullBleed)
    XCTAssertEqual(actual[.profileCustomization], .contained)
  }
}
