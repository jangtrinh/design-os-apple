import Foundation
#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif
import Testing

@testable import CalorieCamCore

private let jpeg = Data([0xff, 0xd8, 0xff, 0xe0, 0x00])
private let validResponse = #"{"foods":[{"name":"Rice","portion":"1 cup","calories":205}],"uncertaintyNote":"Portion size is uncertain; review this estimate.","source":"openai","isEstimate":true}"#

// Each test gets its own URL and fixture. The lock protects URLProtocol's background callbacks.
private final class FixtureStore: @unchecked Sendable {
  struct Fixture: Sendable {
    var status: Int = 200
    var body: String = validResponse
    var failure: URLError.Code? = nil
    var request: URLRequest? = nil
    var requestCount: Int = 0
  }
  private let lock = NSLock()
  private var values: [URL: Fixture] = [:]

  func set(_ fixture: Fixture, for url: URL) {
    lock.lock()
    defer { lock.unlock() }
    values[url] = fixture
  }

  func get(_ url: URL, request: URLRequest? = nil) -> Fixture? {
    lock.lock()
    defer { lock.unlock() }
    if let request {
      values[url]?.request = request
      values[url]?.requestCount += 1
    }
    return values[url]
  }

  func remove(_ url: URL) {
    lock.lock()
    defer { lock.unlock() }
    values[url] = nil
  }
}

private final class AnalysisURLProtocol: URLProtocol, @unchecked Sendable {
  static let fixtures = FixtureStore()
  override class func canInit(with request: URLRequest) -> Bool { true }
  override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }
  override func startLoading() {
    guard let url = request.url, let fixture = Self.fixtures.get(url, request: request) else {
      client?.urlProtocol(self, didFailWithError: URLError(.badURL))
      return
    }
    if let failure = fixture.failure {
      client?.urlProtocol(self, didFailWithError: URLError(failure))
      return
    }
    guard let response = HTTPURLResponse(
      url: url, statusCode: fixture.status, httpVersion: "HTTP/1.1",
      headerFields: ["Content-Type": "application/json"]
    ) else { return }
    client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
    client?.urlProtocol(self, didLoad: Data(fixture.body.utf8))
    client?.urlProtocolDidFinishLoading(self)
  }
  override func stopLoading() {}
}

private func withRemoteFixture(
  _ fixture: FixtureStore.Fixture = .init(),
  body: (RemoteMealAnalyzer, URL) async throws -> Void
) async throws {
  let endpoint = URL(string: "https://caloriecam.test/\(UUID().uuidString)/analyze")!
  AnalysisURLProtocol.fixtures.set(fixture, for: endpoint)
  let config = URLSessionConfiguration.ephemeral
  config.protocolClasses = [AnalysisURLProtocol.self]
  let session = URLSession(configuration: config)
  defer {
    session.invalidateAndCancel()
    AnalysisURLProtocol.fixtures.remove(endpoint)
  }
  try await body(RemoteMealAnalyzer(endpoint: endpoint, session: session), endpoint)
}

@Test("Remote endpoints require HTTPS or explicitly opted-in exact loopback")
func remoteEndpointValidation() throws {
  for endpoint in [
    "http://example.com/analyze", "https://user:secret@example.com/analyze",
    "https://example.com/analyze?key=secret", "https://example.com/analyze#fragment",
    "file:///tmp/analyze", "http://localhost.evil.test/analyze",
  ] {
    #expect(throws: RemoteMealAnalysisError.invalidEndpoint) {
      try RemoteMealAnalyzer(endpoint: URL(string: endpoint)!, allowLocalhostHTTP: true)
    }
  }
  #expect(throws: RemoteMealAnalysisError.invalidEndpoint) {
    try RemoteMealAnalyzer(endpoint: URL(string: "http://localhost:8787/analyze")!)
  }
  _ = try RemoteMealAnalyzer(
    endpoint: URL(string: "http://localhost:8787/analyze")!, allowLocalhostHTTP: true
  )
  _ = try RemoteMealAnalyzer(endpoint: URL(string: "https://example.com/analyze")!)
}

@Test("Remote analysis posts canonical JPEG base64 and returns reviewable remote provenance")
func remoteRequestAndResponse() async throws {
  try await withRemoteFixture { analyzer, endpoint in
    let estimate = try await analyzer.analyze(imageData: jpeg)
    #expect(estimate.origin == .remote)
    #expect(estimate.totalCalories == 205)
    #expect(estimate.items.first?.name == "Rice")
    #expect(!estimate.note.isEmpty)
    let request = try #require(AnalysisURLProtocol.fixtures.get(endpoint)?.request)
    #expect(request.httpMethod == "POST")
    #expect(request.value(forHTTPHeaderField: "Content-Type") == "application/json")
    #expect(request.value(forHTTPHeaderField: "Authorization") == nil)
    let data: Data
    if let body = request.httpBody {
      data = body
    } else {
      let stream = try #require(request.httpBodyStream)
      stream.open()
      defer { stream.close() }
      var bytes = Data()
      var buffer = [UInt8](repeating: 0, count: 1_024)
      while stream.hasBytesAvailable {
        let count = stream.read(&buffer, maxLength: buffer.count)
        if count <= 0 { break }
        bytes.append(contentsOf: buffer.prefix(count))
      }
      data = bytes
    }
    let object = try #require(JSONSerialization.jsonObject(with: data) as? [String: String])
    #expect(object == ["imageBase64": jpeg.base64EncodedString(), "mimeType": "image/jpeg"])
    let second = try await analyzer.analyze(imageData: jpeg)
    #expect(estimate.items[0].id != second.items[0].id)
  }
}

@Test("Invalid and oversized image inputs never start an upload")
func remoteInputValidation() async throws {
  try await withRemoteFixture { analyzer, endpoint in
    await #expect(throws: RemoteMealAnalysisError.invalidJPEG) {
      try await analyzer.analyze(imageData: Data())
    }
    await #expect(throws: RemoteMealAnalysisError.imageTooLarge) {
      try await analyzer.analyze(imageData: Data(repeating: 0, count: RemoteMealAnalyzer.maximumImageBytes + 1))
    }
    #expect(AnalysisURLProtocol.fixtures.get(endpoint)?.request == nil)
  }
}

@Test("Malformed, empty, untrusted, and out-of-bounds responses are rejected")
func remoteInvalidResponses() async throws {
  let bodies = [
    "not JSON",
    validResponse.replacingOccurrences(of: "205", with: "-1"),
    validResponse.replacingOccurrences(of: "205", with: "1e999"),
    validResponse.replacingOccurrences(of: "205", with: "10001"),
    validResponse.replacingOccurrences(of: "\"Rice\"", with: "\" \""),
    validResponse.replacingOccurrences(of: "\"openai\"", with: "\"unknown\""),
    validResponse.replacingOccurrences(of: "true", with: "false"),
    #"{"foods":[],"uncertaintyNote":"Unknown","source":"openai","isEstimate":true}"#,
  ]
  for body in bodies {
    try await withRemoteFixture(.init(body: body)) { analyzer, _ in
      await #expect(throws: RemoteMealAnalysisError.invalidResponse) {
        try await analyzer.analyze(imageData: jpeg)
      }
    }
  }
}

@Test("Backend uncertainty and HTTP errors remain actionable")
func remoteHTTPFailures() async throws {
  for (code, expected) in [
    ("no_food", RemoteMealAnalysisError.noFood),
    ("uncertain", RemoteMealAnalysisError.uncertain),
  ] {
    try await withRemoteFixture(.init(status: 422, body: "{\"error\":{\"code\":\"\(code)\",\"message\":\"Server detail\"}}")) { analyzer, _ in
      await #expect(throws: expected) { try await analyzer.analyze(imageData: jpeg) }
    }
  }
  try await withRemoteFixture(.init(status: 503)) { analyzer, _ in
    await #expect(throws: RemoteMealAnalysisError.unavailable(503)) {
      try await analyzer.analyze(imageData: jpeg)
    }
  }
}

@Test("Network failures and URLSession cancellation are handled without automatic retry")
func remoteTransportFailures() async throws {
  try await withRemoteFixture(.init(failure: .timedOut)) { analyzer, endpoint in
    await #expect(throws: RemoteMealAnalysisError.connectionFailed) {
      try await analyzer.analyze(imageData: jpeg)
    }
    #expect(AnalysisURLProtocol.fixtures.get(endpoint)?.requestCount == 1)
  }
  try await withRemoteFixture(.init(failure: .cancelled)) { analyzer, _ in
    await #expect(throws: CancellationError.self) { try await analyzer.analyze(imageData: jpeg) }
  }
}

@Test("A cancelled task never begins a photo upload")
func remoteCancelledBeforeUpload() async throws {
  try await withRemoteFixture { analyzer, endpoint in
    let task = Task {
      withUnsafeCurrentTask { $0?.cancel() }
      return try await analyzer.analyze(imageData: jpeg)
    }
    await #expect(throws: CancellationError.self) { try await task.value }
    #expect(AnalysisURLProtocol.fixtures.get(endpoint)?.request == nil)
  }
}
