import Foundation
import Testing

@testable import CalorieCamCore

private func food(calories: Double = 120) -> FoodItem {
  FoodItem(name: "Example food", portion: "1 serving", calories: calories)
}

private func entry() -> MealEntry {
  MealEntry(date: Date(timeIntervalSince1970: 1_700_000_000), items: [food()], origin: .manual)
}

private func withJournal(_ body: (MealJournal) throws -> Void) throws {
  let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
  defer { try? FileManager.default.removeItem(at: directory) }
  try body(MealJournal(url: directory.appendingPathComponent("journal.json")))
}

@Test("Totals are derived from editable food estimates")
func totals() throws {
  var estimate = MealEstimate(items: [food(calories: 100), food(calories: 25.5)], origin: .manual)
  #expect(estimate.totalCalories == 125.5)
  estimate.items[0].calories = 200
  #expect(estimate.totalCalories == 225.5)
  try estimate.validate()
  #expect(MealEntry(items: estimate.items, origin: .manual).totalCalories == 225.5)
}

@Test("Blank food names and invalid calorie values are rejected")
func invalidFood() {
  #expect(throws: MealValidationError.blankFoodName) {
    try FoodItem(name: " \n ", portion: "", calories: 10).validate()
  }
  for value in [-1, Double.nan, Double.infinity, -Double.infinity, 10_000.01] {
    #expect(throws: MealValidationError.invalidCalories) {
      try food(calories: value).validate()
    }
  }
}

@Test("Zero and finite technical bounds remain valid")
func calorieBounds() throws {
  try food(calories: 0).validate()
  try food(calories: 10_000).validate()
  try MealEstimate(items: (0..<5).map { _ in food(calories: 10_000) }, origin: .manual).validate()
  #expect(throws: MealValidationError.invalidCalories) {
    try MealEstimate(items: (0..<6).map { _ in food(calories: 10_000) }, origin: .manual).validate()
  }
}

@Test("Empty meals, duplicate food identifiers, and invalid dates are rejected")
func invalidMeal() {
  #expect(throws: MealValidationError.emptyMeal) {
    try MealEstimate(items: [], origin: .manual).validate()
  }
  let item = food()
  #expect(throws: MealValidationError.duplicateItemIDs) {
    try MealEstimate(items: [item, item], origin: .manual).validate()
  }
  #expect(throws: MealValidationError.invalidDate) {
    try MealEntry(date: Date(timeIntervalSince1970: .infinity), items: [item], origin: .manual).validate()
  }
}

@Test("Missing journal starts empty and valid entries round trip including provenance")
func journalRoundTrip() throws {
  try withJournal { journal in
    #expect(try journal.load().isEmpty)
    var entries = [entry()]
    entries[0].origin = .demo
    entries[0].note = "Explicit fixture provenance"
    try journal.save(entries)
    #expect(try journal.load() == entries)
    entries.append(entry())
    try journal.save(entries)
    #expect(try journal.load() == entries)
    try journal.save([])
    #expect(try journal.load().isEmpty)
  }
}

@Test("Invalid replacement preserves the original bytes and entries")
func failedValidationPreservesJournal() throws {
  try withJournal { journal in
    let original = [entry()]
    try journal.save(original)
    let before = try Data(contentsOf: journal.url)
    var invalid = original
    invalid[0].items[0].calories = .nan
    #expect(throws: MealValidationError.invalidCalories) { try journal.save(invalid) }
    #expect(try Data(contentsOf: journal.url) == before)
    #expect(try journal.load() == original)
    #expect(throws: MealValidationError.duplicateEntryIDs) { try journal.save(original + original) }
    #expect(try Data(contentsOf: journal.url) == before)
  }
}

@Test("Malformed journals raise an actionable error without rewriting the file")
func corruptJournal() throws {
  try withJournal { journal in
    try journal.save([entry()])
    let corrupt = Data("not json".utf8)
    try corrupt.write(to: journal.url)
    #expect(throws: MealJournalError.self) { try journal.load() }
    #expect(try Data(contentsOf: journal.url) == corrupt)
  }
}

@Test("Syntactically valid but invalid stored entries do not silently reset")
func invalidStoredJournal() throws {
  try withJournal { journal in
    try journal.save([entry()])
    let data = try Data(contentsOf: journal.url)
    var object = try #require(JSONSerialization.jsonObject(with: data) as? [String: Any])
    var entries = try #require(object["entries"] as? [[String: Any]])
    entries[0]["items"] = []
    object["entries"] = entries
    let invalidData = try JSONSerialization.data(withJSONObject: object)
    try invalidData.write(to: journal.url)
    #expect(throws: MealJournalError.self) { try journal.load() }
    #expect(try Data(contentsOf: journal.url) == invalidData)
  }
}

@Test("Unsupported format versions fail without rewriting")
func futureJournalVersion() throws {
  try withJournal { journal in
    try journal.save([])
    let future = Data(#"{"version":2,"entries":[]}"#.utf8)
    try future.write(to: journal.url)
    do {
      _ = try journal.load()
      Issue.record("A future journal version must fail")
    } catch MealJournalError.unsupportedVersion(let version) {
      #expect(version == 2)
    }
    #expect(try Data(contentsOf: journal.url) == future)
  }
}

@Test("An inaccessible destination reports save failure without changing existing content")
func saveIOFailure() throws {
  try withJournal { journal in
    try journal.save([entry()])
    let before = try Data(contentsOf: journal.url)
    // Deterministically fail: a regular file cannot also be a parent directory.
    let blocked = MealJournal(url: journal.url.appendingPathComponent("child.json"))
    #expect(throws: MealJournalError.self) { try blocked.save([entry()]) }
    #expect(try Data(contentsOf: journal.url) == before)
  }
}

@Test("A directory at the journal URL is an error, not an empty journal")
func unreadableJournal() throws {
  try withJournal { journal in
    try FileManager.default.createDirectory(at: journal.url, withIntermediateDirectories: true)
    #expect(throws: MealJournalError.self) { try journal.load() }
  }
}

@Test("Demo is unmistakably a fixture and independent of photo contents")
func demoIsFixture() async throws {
  let analyzer = DemoMealAnalyzer()
  let first = try await analyzer.analyze(imageData: Data([1]))
  let second = try await analyzer.analyze(imageData: Data([2, 3]))
  try first.validate()
  #expect(first.origin == .demo)
  #expect(first.note.contains("not inferred from your photo"))
  #expect(first.items.map(\.name) == second.items.map(\.name))
  #expect(first.totalCalories == 430)
  #expect(second.totalCalories == first.totalCalories)
}

@Test("No demo estimate is produced for empty photo data")
func demoRequiresPhoto() async {
  await #expect(throws: MealAnalysisError.self) {
    try await DemoMealAnalyzer().analyze(imageData: Data())
  }
}

@Test("Cancelled analysis does not return a fixture")
func demoCancellation() async {
  let task = Task {
    withUnsafeCurrentTask { $0?.cancel() }
    return try await DemoMealAnalyzer().analyze(imageData: Data([1]))
  }
  await #expect(throws: CancellationError.self) { try await task.value }
}
