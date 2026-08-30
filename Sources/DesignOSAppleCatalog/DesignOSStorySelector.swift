import DesignOSApple

/// Stable, privacy-bounded selector failures owned by integration hosts.
public enum DesignOSStorySelectorError: String, Error, Equatable, Sendable {
  case storyArgument = "E_STORY_ARGUMENT"
  case duplicateSelector = "E_STORY_DUPLICATE_SELECTOR"
  case unknown = "E_STORY_UNKNOWN"
  case unadmitted = "E_STORY_UNADMITTED"
  case unsupportedHost = "E_STORY_UNSUPPORTED_HOST"
  case profileUnknown = "E_PROFILE_UNKNOWN"
}

/// Bounded command-line selection for an admitted dogfood story.
public enum DesignOSStorySelector {
  /// Selects an admitted descriptor from native host arguments.
  public static func select(arguments: [String]) throws -> DesignOSStorySelection? {
    try select(arguments: arguments, admittedStories: DesignOSReleaseCatalog.stories)
  }

  internal static func select(
    arguments: [String],
    admittedStories: [DesignOSStoryDescriptor]
  ) throws -> DesignOSStorySelection? {
    var story: String?
    var profile: String?
    var index = 0

    while index < arguments.count {
      let argument = arguments[index]
      if argument.hasPrefix("--design-os-") {
        guard argument == "--design-os-story" || argument == "--design-os-profile" else {
          throw DesignOSStorySelectorError.storyArgument
        }
        guard index + 1 < arguments.count else {
          throw DesignOSStorySelectorError.storyArgument
        }
        let value = arguments[index + 1]
        guard !value.hasPrefix("--") else {
          throw DesignOSStorySelectorError.storyArgument
        }
        if argument == "--design-os-story" {
          guard story == nil else { throw DesignOSStorySelectorError.duplicateSelector }
          story = value
        } else {
          guard profile == nil else { throw DesignOSStorySelectorError.duplicateSelector }
          profile = value
        }
        index += 2
      } else {
        index += 1
      }
    }

    guard let story else {
      if profile != nil { throw DesignOSStorySelectorError.storyArgument }
      return nil
    }
    guard validStoryID(story) else { throw DesignOSStorySelectorError.storyArgument }
    guard profile.map(DesignOSProfileRegistry.isValidIdentifier) ?? true else {
      throw DesignOSStorySelectorError.profileUnknown
    }
    guard let storyID = DesignOSStoryID(rawValue: story) else {
      throw DesignOSStorySelectorError.unknown
    }
    guard let descriptor = admittedStories.first(where: { $0.id == storyID })
    else {
      throw DesignOSStorySelectorError.unadmitted
    }
    let resolvedProfile: DesignOSProfile
    do {
      resolvedProfile = try DesignOSPilotCatalog.profile(for: profile ?? "default")
    } catch {
      throw DesignOSStorySelectorError.profileUnknown
    }
    return DesignOSStorySelection(descriptor: descriptor, profile: resolvedProfile)
  }

  private static func validStoryID(_ value: String) -> Bool {
    guard value.utf8.count <= 96 else { return false }
    let parts = value.split(separator: ".", omittingEmptySubsequences: false)
    guard (2...3).contains(parts.count) else { return false }
    return parts.allSatisfy(validSegment)
  }

  private static func validSegment(_ value: Substring) -> Bool {
    guard (1...32).contains(value.utf8.count), let first = value.utf8.first,
      first >= 97, first <= 122
    else { return false }
    return value.utf8.dropFirst().allSatisfy { byte in
      (byte >= 97 && byte <= 122) || (byte >= 48 && byte <= 57) || byte == 45
    }
  }
}
