import Foundation

/// Implementations must return estimates for explicit human review, not automatically save.
/// Never embed developer service credentials. Direct personal BYOK requires explicit consent
/// and a user-entered credential supplied in memory by the app Keychain layer.
public protocol MealAnalyzing: Sendable {
  func analyze(imageData: Data) async throws -> MealEstimate
}

public enum MealAnalysisError: Error, LocalizedError, Sendable {
  case emptyImage

  public var errorDescription: String? {
    "Choose a photo before loading a demo estimate."
  }
}

/// Offline fixture for testing the photo-to-review workflow. It never inspects image contents,
/// performs recognition, or sends the photo anywhere. Every result retains demo provenance.
public struct DemoMealAnalyzer: MealAnalyzing {
  public init() {}

  public func analyze(imageData: Data) async throws -> MealEstimate {
    try Task.checkCancellation()
    guard !imageData.isEmpty else { throw MealAnalysisError.emptyImage }
    return MealEstimate(
      items: [
        FoodItem(name: "Example rice", portion: "1 cup, cooked", calories: 205),
        FoodItem(name: "Example chicken", portion: "100 g, cooked", calories: 165),
        FoodItem(name: "Example vegetables", portion: "1 cup", calories: 60),
      ],
      note: "Demo fixture only. These foods and calorie estimates were not inferred from your photo. Edit every item or enter your own meal.",
      origin: .demo
    )
  }
}
