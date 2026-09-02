import SwiftUI

enum GalleryDestination: String, CaseIterable, Identifiable {
  case catalog = "Catalog"
  case examples = "Examples"
  case overview = "Overview"
  case foundations = "Foundations"
  case semanticComponents = "Components"
  case nativePatterns = "Native patterns"

  var id: Self { self }

  var symbolName: String {
    switch self {
    case .catalog: "book.closed"
    case .examples: "square.grid.2x2.fill"
    case .overview: "square.grid.2x2"
    case .foundations: "paintpalette"
    case .semanticComponents: "rectangle.3.group.bubble.left"
    case .nativePatterns: "rectangle.3.group"
    }
  }
}
