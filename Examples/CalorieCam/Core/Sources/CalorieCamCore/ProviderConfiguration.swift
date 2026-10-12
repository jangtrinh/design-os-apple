import Foundation

/// Direct, opt-in API destinations. A provider cannot supply an arbitrary host.
public enum AIProvider: String, Codable, CaseIterable, Sendable {
  case openAI = "openai"
  case claude = "claude"

  public var displayName: String {
    switch self {
    case .openAI: "OpenAI"
    case .claude: "Claude (Anthropic)"
    }
  }

  public var apiHost: String {
    switch self {
    case .openAI: "api.openai.com"
    case .claude: "api.anthropic.com"
    }
  }
}

/// Safe to persist: contains no credential. There is deliberately no guessed default model.
public struct ProviderConfiguration: Codable, Equatable, Sendable {
  public let provider: AIProvider
  public let modelID: String

  public init(provider: AIProvider, modelID: String) throws {
    let model = modelID.trimmingCharacters(in: .whitespacesAndNewlines)
    guard Self.isValidModelID(model) else { throw ProviderAnalysisError.invalidModelID }
    self.provider = provider
    self.modelID = model
  }

  public init(from decoder: any Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    try self.init(
      provider: values.decode(AIProvider.self, forKey: .provider),
      modelID: values.decode(String.self, forKey: .modelID)
    )
  }

  static func isValidModelID(_ value: String) -> Bool {
    !value.isEmpty && value.utf8.count <= 200
      && value.utf8.allSatisfy {
        (48...57).contains($0) || (65...90).contains($0) || (97...122).contains($0)
          || [UInt8(45), 46, 58, 95].contains($0)
      }
      && value != "." && value != ".."
  }
}

/// A metadata lookup confirms access, not image or structured-output compatibility.
public struct ProviderModelInfo: Equatable, Sendable {
  public let id: String
  public let displayName: String

  public init(id: String, displayName: String) {
    self.id = id
    self.displayName = displayName
  }
}

/// Fixed messages never include response bodies, request headers, credentials, or URLs.
public enum ProviderAnalysisError: Error, LocalizedError, Equatable, Sendable {
  case invalidModelID
  case invalidAPIKey
  case invalidJPEG
  case imageTooLarge
  case invalidResponse
  case responseTooLarge
  case noFood
  case uncertain
  case permissionDenied
  case modelUnavailable
  case rateLimited
  case requestRejected
  case unavailable(Int)
  case redirectRejected
  case timedOut
  case connectionFailed

  public var errorDescription: String? {
    switch self {
    case .invalidModelID:
      "Enter a model ID from your provider using letters, numbers, periods, hyphens, underscores, or colons (up to 200 characters)."
    case .invalidAPIKey:
      "The API key is missing, invalid, or was rejected. Update it in AI Settings."
    case .invalidJPEG:
      "Choose a photo that can be converted to JPEG before requesting an estimate."
    case .imageTooLarge:
      "This photo exceeds the 5 MiB upload limit. Choose a smaller photo."
    case .invalidResponse:
      "The provider returned an invalid or incomplete estimate. Nothing was saved. Try another photo or enter foods manually."
    case .responseTooLarge:
      "The provider returned more data than the app can safely accept. Nothing was saved."
    case .noFood:
      "No food could be identified in this photo. Choose a clearer meal photo or enter foods manually."
    case .uncertain:
      "The provider could not make a useful estimate. Try a clearer meal photo or enter foods manually."
    case .permissionDenied:
      "This key does not have permission for the request. Check your provider account and key permissions."
    case .modelUnavailable:
      "This model is unavailable to your key. Check its exact model ID and your provider access."
    case .rateLimited:
      "The provider's rate limit or usage allowance was reached. Check API billing and limits, then try again later."
    case .requestRejected:
      "The provider rejected this request. Check that your model supports images and structured JSON output."
    case .unavailable(let status):
      "The provider is unavailable (HTTP \(status)). Nothing was saved. Try again later."
    case .redirectRejected:
      "The provider tried to redirect the request. The app blocked the redirect to protect your photo and API key."
    case .timedOut:
      "The provider request timed out. Nothing was saved. Try again later."
    case .connectionFailed:
      "The provider could not be reached. Check your connection and try again."
    }
  }
}
