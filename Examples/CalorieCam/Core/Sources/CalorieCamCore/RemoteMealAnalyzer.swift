import Foundation
#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

public enum RemoteMealAnalysisError: Error, LocalizedError, Equatable, Sendable {
  case invalidEndpoint
  case invalidJPEG
  case imageTooLarge
  case invalidResponse
  case noFood
  case uncertain
  case unavailable(Int)
  case connectionFailed

  public var errorDescription: String? {
    switch self {
    case .invalidEndpoint:
      "Configure an HTTPS analysis endpoint without credentials, a query, or a fragment. HTTP is allowed only for explicitly enabled localhost development."
    case .invalidJPEG:
      "Choose a photo that can be converted to JPEG before requesting an estimate."
    case .imageTooLarge:
      "This photo exceeds the 5 MiB upload limit. Choose a smaller photo."
    case .invalidResponse:
      "The analysis service returned an invalid estimate. Nothing was saved. Try another photo or enter foods manually."
    case .noFood:
      "No food could be identified in this photo. Choose a clearer meal photo or enter foods manually."
    case .uncertain:
      "The service could not make a useful estimate from this photo. Try a clearer photo or enter foods manually."
    case .unavailable(let status):
      "The analysis service could not complete the request (HTTP \(status)). Nothing was saved. Try again later or enter foods manually."
    case .connectionFailed:
      "The analysis service could not be reached. Check your connection or enter foods manually."
    }
  }
}

/// Opt-in photo upload adapter. The host must disclose and obtain consent for the configured
/// backend and its AI processor before calling. No service credentials belong in the client.
/// The caller normalizes its chosen image to JPEG; results always require human review.
public struct RemoteMealAnalyzer: MealAnalyzing {
  public static let maximumImageBytes = 5 * 1_024 * 1_024
  public let endpoint: URL
  private let session: URLSession

  public init(
    endpoint: URL, session: URLSession = .shared, allowLocalhostHTTP: Bool = false
  ) throws {
    let host = endpoint.host?.lowercased() ?? ""
    let scheme = endpoint.scheme?.lowercased()
    let isLocalhost = ["localhost", "127.0.0.1", "::1", "[::1]"].contains(host)
    guard !host.isEmpty,
      scheme == "https" || (scheme == "http" && allowLocalhostHTTP && isLocalhost),
      endpoint.user == nil, endpoint.password == nil,
      endpoint.query == nil, endpoint.fragment == nil
    else { throw RemoteMealAnalysisError.invalidEndpoint }
    self.endpoint = endpoint
    self.session = session
  }

  public func analyze(imageData: Data) async throws -> MealEstimate {
    try Task.checkCancellation()
    guard imageData.count <= Self.maximumImageBytes else {
      throw RemoteMealAnalysisError.imageTooLarge
    }
    guard imageData.starts(with: [0xff, 0xd8, 0xff]) else {
      throw RemoteMealAnalysisError.invalidJPEG
    }
    var request = URLRequest(url: endpoint)
    request.httpMethod = "POST"
    request.timeoutInterval = 45
    request.cachePolicy = .reloadIgnoringLocalCacheData
    request.httpShouldHandleCookies = false
    request.setValue("no-store", forHTTPHeaderField: "Cache-Control")
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue("application/json", forHTTPHeaderField: "Accept")
    request.httpBody = try JSONEncoder().encode(
      AnalysisRequest(imageBase64: imageData.base64EncodedString(), mimeType: "image/jpeg")
    )
    let data: Data
    let response: URLResponse
    do {
      // Never forward a private image automatically to a redirect destination.
      (data, response) = try await session.data(for: request, delegate: RejectAnalysisRedirects())
    } catch {
      if Task.isCancelled || (error as? URLError)?.code == .cancelled {
        throw CancellationError()
      }
      throw RemoteMealAnalysisError.connectionFailed
    }
    try Task.checkCancellation()
    guard let response = response as? HTTPURLResponse, data.count <= 256 * 1_024 else {
      throw RemoteMealAnalysisError.invalidResponse
    }
    guard response.statusCode == 200 else {
      let code = (try? JSONDecoder().decode(AnalysisFailure.self, from: data))?.error.code
      if response.statusCode == 422, code == "no_food" { throw RemoteMealAnalysisError.noFood }
      if response.statusCode == 422, code == "uncertain" { throw RemoteMealAnalysisError.uncertain }
      throw RemoteMealAnalysisError.unavailable(response.statusCode)
    }
    do {
      let result = try JSONDecoder().decode(AnalysisResponse.self, from: data)
      guard result.source == "openai", result.isEstimate,
        !result.uncertaintyNote.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
        result.foods.count <= 20, result.uncertaintyNote.count <= 1_000,
        result.foods.allSatisfy({ $0.name.count <= 120 && $0.portion.count <= 160 })
      else { throw RemoteMealAnalysisError.invalidResponse }
      let estimate = MealEstimate(
        items: result.foods.map { FoodItem(name: $0.name, portion: $0.portion, calories: $0.calories) },
        note: result.uncertaintyNote,
        origin: .remote
      )
      try estimate.validate()
      return estimate
    } catch {
      throw RemoteMealAnalysisError.invalidResponse
    }
  }
}

private final class RejectAnalysisRedirects: NSObject, URLSessionTaskDelegate, Sendable {
  func urlSession(
    _ session: URLSession, task: URLSessionTask,
    willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest,
    completionHandler: @escaping @Sendable (URLRequest?) -> Void
  ) {
    completionHandler(nil)
  }
}

private struct AnalysisRequest: Encodable {
  var imageBase64: String
  var mimeType: String
}

private struct AnalysisResponse: Decodable {
  struct Food: Decodable {
    var name: String
    var portion: String
    var calories: Double
  }
  var foods: [Food]
  var uncertaintyNote: String
  var source: String
  var isEstimate: Bool
}

private struct AnalysisFailure: Decodable {
  struct Detail: Decodable { var code: String }
  var error: Detail
}
