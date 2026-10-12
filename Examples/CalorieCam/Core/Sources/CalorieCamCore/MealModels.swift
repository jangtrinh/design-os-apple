import Foundation

/// The provenance must remain visible wherever an estimate is reviewed or saved.
public enum EstimateOrigin: String, Codable, CaseIterable, Sendable {
  case demo
  case remote
  case manual
}

public enum MealValidationError: Error, LocalizedError, Equatable, Sendable {
  case emptyMeal
  case blankFoodName
  case invalidCalories
  case duplicateItemIDs
  case duplicateEntryIDs
  case invalidDate

  public var errorDescription: String? {
    switch self {
    case .emptyMeal: "Add at least one food before saving this estimate."
    case .blankFoodName: "Give every food a name before saving."
    case .invalidCalories:
      "Enter finite estimated calories from 0 to 10,000 per food and no more than 50,000 per meal."
    case .duplicateItemIDs: "This estimate contains duplicate food identifiers. Remove the duplicate food."
    case .duplicateEntryIDs: "The journal contains duplicate entry identifiers. Restore a valid journal."
    case .invalidDate: "Choose a valid date for this entry."
    }
  }
}

/// Calories are user-reviewable estimates, never measurements or nutrition advice.
/// Mutable fields allow incomplete form editing; validate before accepting or persisting.
public struct FoodItem: Codable, Identifiable, Equatable, Sendable {
  public var id: UUID
  public var name: String
  public var portion: String
  public var calories: Double

  public init(id: UUID = UUID(), name: String, portion: String, calories: Double) {
    self.id = id
    self.name = name
    self.portion = portion
    self.calories = calories
  }

  public func validate() throws {
    guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
      throw MealValidationError.blankFoodName
    }
    guard calories.isFinite, (0...10_000).contains(calories) else {
      throw MealValidationError.invalidCalories
    }
  }
}

public struct MealEstimate: Codable, Equatable, Sendable {
  public var items: [FoodItem]
  public var note: String
  public var origin: EstimateOrigin
  public var totalCalories: Double { items.reduce(0) { $0 + $1.calories } }

  public init(items: [FoodItem], note: String = "", origin: EstimateOrigin) {
    self.items = items
    self.note = note
    self.origin = origin
  }

  public func validate() throws {
    guard !items.isEmpty else { throw MealValidationError.emptyMeal }
    for item in items { try item.validate() }
    guard Set(items.map(\.id)).count == items.count else {
      throw MealValidationError.duplicateItemIDs
    }
    guard totalCalories.isFinite, totalCalories <= 50_000 else {
      throw MealValidationError.invalidCalories
    }
  }
}

public struct MealEntry: Codable, Identifiable, Equatable, Sendable {
  public var id: UUID
  public var date: Date
  public var items: [FoodItem]
  public var note: String
  public var origin: EstimateOrigin
  public var totalCalories: Double { items.reduce(0) { $0 + $1.calories } }

  public init(
    id: UUID = UUID(), date: Date = Date(), items: [FoodItem], note: String = "",
    origin: EstimateOrigin
  ) {
    self.id = id
    self.date = date
    self.items = items
    self.note = note
    self.origin = origin
  }

  public func validate() throws {
    guard date.timeIntervalSinceReferenceDate.isFinite else {
      throw MealValidationError.invalidDate
    }
    try MealEstimate(items: items, note: note, origin: origin).validate()
  }
}
