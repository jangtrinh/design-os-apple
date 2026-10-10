import Foundation

public enum MealJournalError: Error, LocalizedError, Sendable {
  case unreadable(String)
  case corrupted
  case unsupportedVersion(Int)
  case unwritable(String)

  public var errorDescription: String? {
    switch self {
    case .unreadable(let detail):
      "The journal could not be opened. Check file access and try again. \(detail)"
    case .corrupted:
      "The journal is damaged or contains invalid entries. Keep the original file and restore a valid backup before saving."
    case .unsupportedVersion(let version):
      "This journal uses format \(version). Open it with a compatible app version before saving."
    case .unwritable(let detail):
      "The journal could not be saved. Your previous file is unchanged. Check available storage and file access, then try again. \(detail)"
    }
  }
}

/// A single-writer, whole-journal repository. Serialize calls on the app's owning actor.
/// A failed load must block editing/saving in the host until the user resolves the error.
/// Photo bytes are deliberately excluded from storage.
public struct MealJournal: Sendable {
  public let url: URL

  public init(url: URL) {
    self.url = url
  }

  public func load() throws -> [MealEntry] {
    let data: Data
    do {
      data = try Data(contentsOf: url)
    } catch let error as CocoaError where error.code == .fileReadNoSuchFile {
      return []
    } catch {
      throw MealJournalError.unreadable(error.localizedDescription)
    }
    let envelope: JournalEnvelope
    do {
      envelope = try JSONDecoder().decode(JournalEnvelope.self, from: data)
    } catch {
      throw MealJournalError.corrupted
    }
    guard envelope.version == 1 else {
      throw MealJournalError.unsupportedVersion(envelope.version)
    }
    do {
      try Self.validate(envelope.entries)
    } catch {
      throw MealJournalError.corrupted
    }
    return envelope.entries
  }

  public func save(_ entries: [MealEntry]) throws {
    // Validate and encode before touching the directory or previous journal.
    try Self.validate(entries)
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    let data = try encoder.encode(JournalEnvelope(version: 1, entries: entries))
    do {
      try FileManager.default.createDirectory(
        at: url.deletingLastPathComponent(), withIntermediateDirectories: true
      )
      try data.write(to: url, options: .atomic)
    } catch {
      throw MealJournalError.unwritable(error.localizedDescription)
    }
  }

  private static func validate(_ entries: [MealEntry]) throws {
    guard Set(entries.map(\.id)).count == entries.count else {
      throw MealValidationError.duplicateEntryIDs
    }
    for entry in entries { try entry.validate() }
  }
}

private struct JournalEnvelope: Codable {
  var version: Int
  var entries: [MealEntry]
}
