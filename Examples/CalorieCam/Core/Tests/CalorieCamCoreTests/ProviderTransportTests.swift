import Foundation
#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif
import Testing

@testable import CalorieCamCore

private final class ProviderProtocolState: @unchecked Sendable {
  struct Fixture {
    var body = Data(#"{"id":"fixture-model","object":"model"}"#.utf8)
    var contentLength: Int? = nil
    var status = 200
    var hold = false
    var started: AsyncStream<Void>.Continuation? = nil
    var stopped: AsyncStream<Void>.Continuation? = nil
  }
  private let lock = NSLock()
  private var fixture = Fixture()
  private var requestCount = 0

  func set(_ value: Fixture) {
    lock.lock()
    defer { lock.unlock() }
    fixture = value
    requestCount = 0
  }

  func begin() -> Fixture {
    lock.lock()
    defer { lock.unlock() }
    requestCount += 1
    return fixture
  }

  func didStop() {
    lock.lock()
    let stopped = fixture.stopped
    lock.unlock()
    stopped?.yield(())
    stopped?.finish()
  }

  var count: Int {
    lock.lock()
    defer { lock.unlock() }
    return requestCount
  }
}

private final class ProviderFixtureProtocol: URLProtocol, @unchecked Sendable {
  static let state = ProviderProtocolState()
  override class func canInit(with request: URLRequest) -> Bool { true }
  override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }
  override func startLoading() {
    let fixture = Self.state.begin()
    fixture.started?.yield(())
    fixture.started?.finish()
    if fixture.hold { return }
    var headers = ["Content-Type": "application/json"]
    if let length = fixture.contentLength { headers["Content-Length"] = String(length) }
    let response = HTTPURLResponse(
      url: request.url!, statusCode: fixture.status, httpVersion: "HTTP/1.1", headerFields: headers
    )!
    client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
    // Multiple chunks also exercise the accumulated limit when Content-Length is absent.
    let split = fixture.body.count / 2
    client?.urlProtocol(self, didLoad: Data(fixture.body.prefix(split)))
    client?.urlProtocol(self, didLoad: Data(fixture.body.dropFirst(split)))
    client?.urlProtocolDidFinishLoading(self)
  }
  override func stopLoading() { Self.state.didStop() }
}

private final class RedirectDecision: @unchecked Sendable {
  private let lock = NSLock()
  private var value = false
  func set(_ blocked: Bool) {
    lock.lock()
    value = blocked
    lock.unlock()
  }
  var isBlocked: Bool {
    lock.lock()
    defer { lock.unlock() }
    return value
  }
}

@Suite("Bounded direct-provider URLSession transport", .serialized)
struct ProviderTransportTests {
  private func client() throws -> ProviderMealAnalyzer {
    try ProviderMealAnalyzer(
      configuration: ProviderConfiguration(provider: .openAI, modelID: "fixture-model"),
      apiKey: "test-placeholder-not-a-key",
      transport: ProviderURLSessionTransport(protocolClasses: [ProviderFixtureProtocol.self])
    )
  }

  @Test("Ephemeral sessions disable cookies, caches and credential storage")
  func ephemeral() {
    let config = ProviderURLSessionTransport.ephemeralConfiguration()
    #expect(config.urlCache == nil)
    #expect(config.urlCredentialStorage == nil)
    #expect(config.httpCookieStorage == nil)
    #expect(!config.httpShouldSetCookies)
    #expect(config.requestCachePolicy == .reloadIgnoringLocalCacheData)
    #expect(config.timeoutIntervalForRequest == 45)
    #expect(config.timeoutIntervalForResource == 45)
  }

  @Test("Metadata succeeds through a URLProtocol fixture with no network access")
  func metadata() async throws {
    ProviderFixtureProtocol.state.set(.init())
    let info = try await client().verifyConnection()
    #expect(info.id == "fixture-model")
    #expect(ProviderFixtureProtocol.state.count == 1)
  }

  @Test("Both advertised and streamed oversized responses are cancelled")
  func boundedResponses() async throws {
    for advertisedLength in [nil, ProviderMealAnalyzer.maximumResponseBytes + 1] {
      ProviderFixtureProtocol.state.set(.init(
        body: Data(repeating: 32, count: ProviderMealAnalyzer.maximumResponseBytes + 1),
        contentLength: advertisedLength
      ))
      await #expect(throws: ProviderAnalysisError.responseTooLarge) {
        try await client().verifyConnection()
      }
      #expect(ProviderFixtureProtocol.state.count == 1)
    }
  }

  @Test("Cancelling an active call promptly cancels its task without retrying", .timeLimit(.minutes(1)))
  func midRequestCancellation() async throws {
    let started = AsyncStream<Void>.makeStream()
    let stopped = AsyncStream<Void>.makeStream()
    ProviderFixtureProtocol.state.set(.init(
      hold: true, started: started.continuation, stopped: stopped.continuation
    ))
    let analyzer = try client()
    let task = Task { try await analyzer.verifyConnection() }
    var startIterator = started.stream.makeAsyncIterator()
    _ = await startIterator.next()
    task.cancel()
    await #expect(throws: CancellationError.self) { try await task.value }
    var stopIterator = stopped.stream.makeAsyncIterator()
    _ = await stopIterator.next()
    #expect(ProviderFixtureProtocol.state.count == 1)
  }

  @Test("Redirect delegate refuses both same-host and foreign-host destinations")
  func noRedirects() throws {
    let session = URLSession(configuration: ProviderURLSessionTransport.ephemeralConfiguration())
    defer { session.invalidateAndCancel() }
    let original = URL(string: "https://api.openai.com/v1/models/fixture-model")!
    let response = HTTPURLResponse(url: original, statusCode: 307, httpVersion: "HTTP/1.1", headerFields: nil)!
    for target in ["https://api.openai.com/other", "https://other.test/steal"] {
      let decision = RedirectDecision()
      let operation = BoundedProviderRequest()
      operation.urlSession(
        session, task: session.dataTask(with: original), willPerformHTTPRedirection: response,
        newRequest: URLRequest(url: URL(string: target)!)
      ) { request in decision.set(request == nil) }
      #expect(decision.isBlocked)
    }
  }

  @Test("A redirect HTTP response cannot be accepted as metadata")
  func redirectStatus() async throws {
    ProviderFixtureProtocol.state.set(.init(status: 302))
    await #expect(throws: ProviderAnalysisError.redirectRejected) {
      try await client().verifyConnection()
    }
    #expect(ProviderFixtureProtocol.state.count == 1)
  }
}
