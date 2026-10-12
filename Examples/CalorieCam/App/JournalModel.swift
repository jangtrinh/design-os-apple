import Foundation
import Observation
import CalorieCamCore

@MainActor @Observable
final class JournalModel {
    private(set) var entries: [MealEntry] = []
    private(set) var loadFailure: String?
    var operationError: String?
    private let journal: MealJournal

    init() {
        let manager = FileManager.default
        let directory = manager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
            .appendingPathComponent("CalorieCam", isDirectory: true)
        // UI tests use a separate journal, never the person's real data.
        let testID = ProcessInfo.processInfo.environment["CALORIECAM_TEST_JOURNAL"]
        let url = testID.map { manager.temporaryDirectory.appendingPathComponent("CalorieCam-\($0).json") }
            ?? directory.appendingPathComponent("journal.json")
        journal = MealJournal(url: url)
        reload()
    }

    func reload() {
        do {
            entries = try journal.load()
            loadFailure = nil
        } catch {
            loadFailure = "Your journal could not be opened. The existing file has been preserved. \(error.localizedDescription)"
        }
    }

    func meals(on day: Date) -> [MealEntry] {
        entries.filter { Calendar.current.isDate($0.date, inSameDayAs: day) }
            .sorted { $0.date > $1.date }
    }

    func save(_ entry: MealEntry) -> Bool {
        guard loadFailure == nil else { return false }
        do {
            try entry.validate()
            var next = entries.filter { $0.id != entry.id }
            next.append(entry)
            try journal.save(next)
            entries = next
            return true
        } catch {
            operationError = "Your meal wasn’t saved. \(error.localizedDescription)"
            return false
        }
    }

    func delete(_ entry: MealEntry) {
        guard loadFailure == nil else { return }
        do {
            let next = entries.filter { $0.id != entry.id }
            try journal.save(next)
            entries = next
        } catch {
            operationError = "Your meal wasn’t deleted. \(error.localizedDescription)"
        }
    }
}

extension EstimateOrigin {
    var label: String {
        switch self {
        case .demo: "Demo · sample numbers"
        case .manual: "Manually entered"
        case .remote: "Estimated · review needed"
        }
    }
}
