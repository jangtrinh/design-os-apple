/// The closed ownership boundary for a pilot story.
public enum DesignOSStoryOwner: String, Codable, Equatable, Hashable, Sendable {
  /// A story backed by a compiled DESIGN:OS runtime implementation.
  case runtimeImplementation = "RUNTIME_IMPLEMENTATION"
  /// A synthetic fixture that belongs only to its host application.
  case appSpecific = "APP_SPECIFIC"
}
