import Foundation

struct OmniActHUDSuggestion: Identifiable, Hashable {
  let id: String
  let title: String
  let detail: String
}

enum OmniActHUDStoryFixtures {
  static let suggestions = [
    OmniActHUDSuggestion(
      id: "rewrite", title: "Rewrite for clarity", detail: "Preserves the original meaning."),
    OmniActHUDSuggestion(
      id: "summarize", title: "Summarize selection", detail: "Returns a concise draft."),
    OmniActHUDSuggestion(
      id: "translate", title: "Translate", detail: "Uses a local synthetic preview."),
  ]
}
