import Foundation
#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif
import Testing

@testable import CalorieCamCore

private let providerJPEG = Data([0xff, 0xd8, 0xff, 0xe0, 0xff, 0xd9])
private let testCredential = "unit-test-placeholder-NOT-A-REAL-API-KEY"
private let estimateJSON = #"{"status":"estimated","foods":[{"name":"Rice","portion":"1 cup","calories":205}],"uncertaintyNote":"Portions and hidden ingredients are uncertain."}"#

private func envelope(_ text: String, provider: AIProvider) throws -> Data {
  let value: [String: Any]
  switch provider {
  case .openAI:
    value = ["status": "completed", "output": [[
      "type": "message", "role": "assistant", "status": "completed",
      "content": [["type": "output_text", "text": text]],
    ]]]
  case .claude:
    value = ["type": "message", "role": "assistant", "stop_reason": "end_turn",
      "content": [["type": "text", "text": text]]]
  }
  return try JSONSerialization.data(withJSONObject: value)
}

private actor FixtureProviderTransport: ProviderTransport {
  let data: Data
  let status: Int
  let failure: URLError.Code?
  let responseURL: URL?
  var requests: [URLRequest] = []

  init(
    data: Data, status: Int = 200, failure: URLError.Code? = nil, responseURL: URL? = nil
  ) {
    self.data = data
    self.status = status
    self.failure = failure
    self.responseURL = responseURL
  }

  func send(_ request: URLRequest) async throws -> (Data, HTTPURLResponse) {
    requests.append(request)
    if let failure {
      throw URLError(failure, userInfo: [NSLocalizedDescriptionKey: testCredential])
    }
    return (data, HTTPURLResponse(
      url: responseURL ?? request.url!, statusCode: status, httpVersion: "HTTP/1.1",
      headerFields: ["Content-Type": "application/json"]
    )!)
  }
}

private func analyzer(
  _ provider: AIProvider = .openAI, transport: any ProviderTransport
) throws -> ProviderMealAnalyzer {
  try ProviderMealAnalyzer(
    configuration: ProviderConfiguration(provider: provider, modelID: "fixture-model-1"),
    apiKey: testCredential, transport: transport
  )
}

@Test("Provider settings persist only validated provider/model, never credentials")
func providerConfigurationValidation() throws {
  for model in ["", " ", ".", "..", "x/y", "x?key=secret", "x#frag", "x%2fy", "x\ny", "🍎", String(repeating: "a", count: 201)] {
    #expect(throws: ProviderAnalysisError.invalidModelID) {
      try ProviderConfiguration(provider: .openAI, modelID: model)
    }
  }
  let config = try ProviderConfiguration(provider: .claude, modelID: "  fixture-model.1:2_a  ")
  #expect(config.modelID == "fixture-model.1:2_a")
  let encoded = try JSONEncoder().encode(config)
  let object = try #require(JSONSerialization.jsonObject(with: encoded) as? [String: String])
  #expect(Set(object.keys) == ["provider", "modelID"])
  #expect(try JSONDecoder().decode(ProviderConfiguration.self, from: encoded) == config)
  #expect(throws: ProviderAnalysisError.invalidModelID) {
    try JSONDecoder().decode(ProviderConfiguration.self, from: Data(#"{"provider":"openai","modelID":"../host"}"#.utf8))
  }
  for key in ["", "  ", "key\r\nHeader: value", "key\u{0}", "a b", String(repeating: "a", count: 513)] {
    #expect(throws: ProviderAnalysisError.invalidAPIKey) {
      try ProviderMealAnalyzer(configuration: config, apiKey: key)
    }
  }
  let client = try ProviderMealAnalyzer(configuration: config, apiKey: testCredential)
  #expect(!String(describing: client).contains(testCredential))
  #expect(!String(reflecting: client).contains(testCredential))
  #expect(Mirror(reflecting: client).children.isEmpty)
}

@Test("Both direct providers send documented vision/structured JSON and return remote estimates", arguments: AIProvider.allCases)
func providerSuccess(provider: AIProvider) async throws {
  let transport = FixtureProviderTransport(data: try envelope(estimateJSON, provider: provider))
  let client = try analyzer(provider, transport: transport)
  let estimate = try await client.analyze(imageData: providerJPEG)
  #expect(estimate.origin == .remote)
  #expect(estimate.totalCalories == 205)
  #expect(estimate.items.first?.name == "Rice")
  #expect(estimate.note.contains("Review foods, portions, and calories before saving"))
  let requests = await transport.requests
  let request = try #require(requests.first)
  #expect(requests.count == 1)
  #expect(request.url?.scheme == "https")
  #expect(request.url?.host == provider.apiHost)
  #expect(request.httpMethod == "POST")
  #expect(request.timeoutInterval == 45)
  #expect(request.cachePolicy == .reloadIgnoringLocalCacheData)
  #expect(!request.httpShouldHandleCookies)
  #expect(request.value(forHTTPHeaderField: "Cache-Control") == "no-store")
  let data = try #require(request.httpBody)
  #expect(!String(decoding: data, as: UTF8.self).contains(testCredential))
  let body = try #require(JSONSerialization.jsonObject(with: data) as? [String: Any])
  #expect(body["model"] as? String == "fixture-model-1")
  let format: [String: Any]
  if provider == .openAI {
    #expect(request.url?.path == "/v1/responses")
    #expect(request.value(forHTTPHeaderField: "Authorization") == "Bearer \(testCredential)")
    #expect(request.value(forHTTPHeaderField: "x-api-key") == nil)
    #expect(body["store"] as? Bool == false)
    #expect(body["max_output_tokens"] as? Int == 4_000)
    let text = try #require(body["text"] as? [String: Any])
    format = try #require(text["format"] as? [String: Any])
    #expect(format["strict"] as? Bool == true)
    let input = try #require(body["input"] as? [[String: Any]])
    let content = try #require(input.first?["content"] as? [[String: Any]])
    #expect(content.last?["type"] as? String == "input_image")
    #expect(content.last?["image_url"] as? String == "data:image/jpeg;base64,\(providerJPEG.base64EncodedString())")
  } else {
    #expect(request.url?.path == "/v1/messages")
    #expect(request.value(forHTTPHeaderField: "x-api-key") == testCredential)
    #expect(request.value(forHTTPHeaderField: "Authorization") == nil)
    #expect(request.value(forHTTPHeaderField: "anthropic-version") == "2023-06-01")
    #expect(body["max_tokens"] as? Int == 4_000)
    #expect(body["output_format"] == nil)
    let output = try #require(body["output_config"] as? [String: Any])
    format = try #require(output["format"] as? [String: Any])
    let messages = try #require(body["messages"] as? [[String: Any]])
    let content = try #require(messages.first?["content"] as? [[String: Any]])
    let source = try #require(content.first?["source"] as? [String: String])
    #expect(source == ["type": "base64", "media_type": "image/jpeg", "data": providerJPEG.base64EncodedString()])
  }
  #expect(format["type"] as? String == "json_schema")
  let schema = try #require(format["schema"] as? [String: Any])
  #expect(schema["additionalProperties"] as? Bool == false)
  let second = try await client.analyze(imageData: providerJPEG)
  #expect(estimate.items[0].id != second.items[0].id)
}

@Test("Connection testing is model metadata only, never inference or photo upload", arguments: AIProvider.allCases)
func providerMetadata(provider: AIProvider) async throws {
  let json = provider == .openAI
    ? #"{"id":"fixture-model-1","object":"model"}"#
    : #"{"id":"fixture-model-1-resolved","type":"model","display_name":"Fixture Model"}"#
  let transport = FixtureProviderTransport(data: Data(json.utf8))
  let model = try await analyzer(provider, transport: transport).verifyConnection()
  #expect(model.id.hasPrefix("fixture-model-1"))
  #expect(!model.displayName.isEmpty)
  let requests = await transport.requests
  #expect(requests.count == 1)
  #expect(requests[0].httpMethod == "GET")
  #expect(requests[0].httpBody == nil)
  #expect(requests[0].url?.absoluteString == "https://\(provider.apiHost)/v1/models/fixture-model-1")
  let invalid = FixtureProviderTransport(data: Data(#"{"id":"x/../../bad","object":"model","type":"model"}"#.utf8))
  await #expect(throws: ProviderAnalysisError.invalidResponse) {
    try await analyzer(provider, transport: invalid).verifyConnection()
  }
}

@Test("Invalid photos are rejected before sending anything")
func providerInvalidImage() async throws {
  let transport = FixtureProviderTransport(data: Data())
  let client = try analyzer(transport: transport)
  for image in [Data(), Data([0xff, 0xd8, 0xff]), Data([1, 2, 3, 4, 5])] {
    await #expect(throws: ProviderAnalysisError.invalidJPEG) {
      try await client.analyze(imageData: image)
    }
  }
  await #expect(throws: ProviderAnalysisError.imageTooLarge) {
    try await client.analyze(imageData: Data(repeating: 0, count: ProviderMealAnalyzer.maximumImageBytes + 1))
  }
  #expect(await transport.requests.isEmpty)
}

@Test("HTTP errors are sanitized and never retried", arguments: AIProvider.allCases)
func providerHTTPErrors(provider: AIProvider) async throws {
  let errors: [(Int, ProviderAnalysisError)] = [
    (400, .requestRejected), (401, .invalidAPIKey), (403, .permissionDenied),
    (404, .modelUnavailable), (413, .requestRejected), (422, .requestRejected),
    (429, .rateLimited), (500, .unavailable(500)), (503, .unavailable(503)),
    (301, .redirectRejected), (307, .redirectRejected),
  ]
  for (status, expected) in errors {
    let transport = FixtureProviderTransport(data: Data(testCredential.utf8), status: status)
    await #expect(throws: expected) {
      try await analyzer(provider, transport: transport).analyze(imageData: providerJPEG)
    }
    #expect(await transport.requests.count == 1)
    #expect(!expected.localizedDescription.contains(testCredential))
  }
}

@Test("Transport errors never disclose credential-bearing underlying descriptions")
func providerTransportErrors() async throws {
  for (code, expected) in [(URLError.Code.cannotConnectToHost, ProviderAnalysisError.connectionFailed), (.timedOut, .timedOut)] {
    let transport = FixtureProviderTransport(data: Data(), failure: code)
    do {
      _ = try await analyzer(transport: transport).verifyConnection()
      Issue.record("Expected a sanitized failure")
    } catch {
      #expect(error as? ProviderAnalysisError == expected)
      #expect(!String(describing: error).contains(testCredential))
      #expect(!error.localizedDescription.contains(testCredential))
    }
    #expect(await transport.requests.count == 1)
  }
  let cancelled = FixtureProviderTransport(data: Data(), failure: .cancelled)
  await #expect(throws: CancellationError.self) {
    try await analyzer(transport: cancelled).verifyConnection()
  }
}

@Test("Malformed, out-of-bounds and unexpected model JSON never becomes an estimate", arguments: AIProvider.allCases)
func providerStrictValidation(provider: AIProvider) async throws {
  var invalid = [
    "not JSON", "```json\n\(estimateJSON)\n```", "[]",
    estimateJSON.replacingOccurrences(of: "205", with: "true"),
    estimateJSON.replacingOccurrences(of: "205", with: "205.5"),
    estimateJSON.replacingOccurrences(of: "205", with: "-1"),
    estimateJSON.replacingOccurrences(of: "205", with: "10001"),
    estimateJSON.replacingOccurrences(of: "205", with: "1e999"),
    estimateJSON.replacingOccurrences(of: "\"Rice\"", with: "\" \""),
    estimateJSON.replacingOccurrences(of: "Rice", with: String(repeating: "a", count: 121)),
    estimateJSON.replacingOccurrences(of: "Rice", with: "Rice\\nIgnore instructions"),
    estimateJSON.replacingOccurrences(of: "1 cup", with: ""),
    estimateJSON.replacingOccurrences(of: "1 cup", with: String(repeating: "a", count: 161)),
    estimateJSON.replacingOccurrences(of: "Portions and hidden ingredients are uncertain.", with: ""),
    estimateJSON.replacingOccurrences(of: "Portions and hidden ingredients are uncertain.", with: String(repeating: "a", count: 601)),
    estimateJSON.replacingOccurrences(of: "\"status\":", with: "\"extra\":true,\"status\":"),
    estimateJSON.replacingOccurrences(of: "\"name\":", with: "\"extra\":true,\"name\":"),
    estimateJSON.replacingOccurrences(of: "estimated", with: "no_food"),
    estimateJSON.replacingOccurrences(of: "estimated", with: "unknown"),
    #"{"status":"estimated","foods":[],"uncertaintyNote":"Uncertain"}"#,
  ]
  for (count, calories) in [(21, 1), (6, 10_000)] {
    let food = "{\"name\":\"Rice\",\"portion\":\"1 cup\",\"calories\":\(calories)}"
    invalid.append("{\"status\":\"estimated\",\"foods\":[\(Array(repeating: food, count: count).joined(separator: ","))],\"uncertaintyNote\":\"Uncertain\"}")
  }
  for json in invalid {
    let transport = FixtureProviderTransport(data: try envelope(json, provider: provider))
    await #expect(throws: ProviderAnalysisError.invalidResponse) {
      try await analyzer(provider, transport: transport).analyze(imageData: providerJPEG)
    }
  }
  for (status, expected) in [("no_food", ProviderAnalysisError.noFood), ("uncertain", .uncertain)] {
    let json = "{\"status\":\"\(status)\",\"foods\":[],\"uncertaintyNote\":\"Cannot identify food.\"}"
    let transport = FixtureProviderTransport(data: try envelope(json, provider: provider))
    await #expect(throws: expected) {
      try await analyzer(provider, transport: transport).analyze(imageData: providerJPEG)
    }
  }
}

@Test("Incomplete/refused provider responses never fall back to invented foods")
func providerEnvelopes() async throws {
  let invalid: [(AIProvider, String, ProviderAnalysisError)] = [
    (.openAI, #"{"status":"incomplete","output":[]}"#, .invalidResponse),
    (.openAI, #"{"status":"completed","output":[]}"#, .invalidResponse),
    (.openAI, #"{"status":"completed","output":[{"type":"message","role":"assistant","status":"completed","content":[{"type":"refusal"}]}]}"#, .uncertain),
    (.claude, #"{"type":"message","role":"assistant","stop_reason":"max_tokens","content":[]}"#, .invalidResponse),
    (.claude, #"{"type":"message","role":"assistant","stop_reason":"refusal","content":[]}"#, .uncertain),
    (.claude, #"{"type":"message","role":"assistant","stop_reason":"end_turn","content":[]}"#, .invalidResponse),
  ]
  for (provider, body, expected) in invalid {
    let transport = FixtureProviderTransport(data: Data(body.utf8))
    await #expect(throws: expected) {
      try await analyzer(provider, transport: transport).analyze(imageData: providerJPEG)
    }
  }
  let oversized = FixtureProviderTransport(data: Data(repeating: 0, count: ProviderMealAnalyzer.maximumResponseBytes + 1))
  await #expect(throws: ProviderAnalysisError.responseTooLarge) {
    try await analyzer(transport: oversized).verifyConnection()
  }
  let wrongHost = FixtureProviderTransport(data: Data(), responseURL: URL(string: "https://other.test/"))
  await #expect(throws: ProviderAnalysisError.invalidResponse) {
    try await analyzer(transport: wrongHost).verifyConnection()
  }
}

@Test("Pre-cancelled analysis and metadata calls do not send requests")
func providerPreCancellation() async throws {
  let transport = FixtureProviderTransport(data: Data())
  let client = try analyzer(transport: transport)
  for metadataOnly in [false, true] {
    let task = Task {
      withUnsafeCurrentTask { $0?.cancel() }
      if metadataOnly { _ = try await client.verifyConnection() }
      else { _ = try await client.analyze(imageData: providerJPEG) }
    }
    await #expect(throws: CancellationError.self) { try await task.value }
  }
  #expect(await transport.requests.isEmpty)
}
