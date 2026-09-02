import Foundation

/// Fail-closed validation failures for story discovery metadata.
public enum DesignOSStoryDiscoveryMetadataError: Error, Equatable, Sendable {
  /// The primary keyword is empty or has an unsupported word count.
  case invalidPrimaryKeyword
  /// The aliases are empty, duplicated, collide with the primary keyword, or exceed the limit.
  case invalidAliases
  /// The intent queries are empty, duplicated, or outside the supported count.
  case invalidIntentQueries
}

/// Human-facing discovery terms for one stable story ID.
public struct DesignOSStoryDiscovery: Codable, Equatable, Hashable, Sendable {
  /// The unique, concise phrase that identifies the story to an AI or a person.
  public let primaryKeyword: String
  /// Bounded exact-match alternatives for the primary keyword.
  public let aliases: [String]
  /// Natural-language intents that describe when the story is useful.
  public let intentQueries: [String]

  /// Creates validated discovery metadata with canonicalized exact-match terms.
  public init(
    primaryKeyword: String,
    aliases: [String],
    intentQueries: [String]
  ) throws {
    let normalizedPrimaryKeyword = Self.normalize(primaryKeyword)
    guard Self.isPrimaryKeyword(normalizedPrimaryKeyword) else {
      throw DesignOSStoryDiscoveryMetadataError.invalidPrimaryKeyword
    }

    let normalizedAliases = aliases.map(Self.normalize)
    guard normalizedAliases.count <= 8,
      normalizedAliases.allSatisfy({ !$0.isEmpty }),
      Set(normalizedAliases).count == normalizedAliases.count,
      !normalizedAliases.contains(normalizedPrimaryKeyword)
    else {
      throw DesignOSStoryDiscoveryMetadataError.invalidAliases
    }

    let normalizedIntentQueries = intentQueries.map(Self.normalize)
    guard (1...3).contains(normalizedIntentQueries.count),
      normalizedIntentQueries.allSatisfy({ !$0.isEmpty }),
      Set(normalizedIntentQueries).count == normalizedIntentQueries.count
    else {
      throw DesignOSStoryDiscoveryMetadataError.invalidIntentQueries
    }

    self.primaryKeyword = normalizedPrimaryKeyword
    self.aliases = normalizedAliases
    self.intentQueries = normalizedIntentQueries
  }

  private enum CodingKeys: String, CodingKey {
    case primaryKeyword
    case aliases
    case intentQueries
  }

  /// Decodes discovery metadata through the same validation as direct construction.
  public init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    try self.init(
      primaryKeyword: container.decode(String.self, forKey: .primaryKeyword),
      aliases: container.decode([String].self, forKey: .aliases),
      intentQueries: container.decode([String].self, forKey: .intentQueries))
  }

  static func normalize(_ value: String) -> String {
    value
      .folding(
        options: [.caseInsensitive, .diacriticInsensitive, .widthInsensitive],
        locale: Locale(identifier: "en_US_POSIX")
      )
      .split(whereSeparator: \.isWhitespace)
      .joined(separator: " ")
  }

  private static func isPrimaryKeyword(_ value: String) -> Bool {
    !value.isEmpty && (1...4).contains(value.split(separator: " ").count)
  }
}
