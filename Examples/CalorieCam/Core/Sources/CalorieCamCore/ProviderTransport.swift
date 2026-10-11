import Foundation
#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

// Internal injection boundary. Production never accepts an arbitrary session or base URL.
protocol ProviderTransport: Sendable {
  func send(_ request: URLRequest) async throws -> (Data, HTTPURLResponse)
}

struct ProviderURLSessionTransport: ProviderTransport {
  var protocolClasses: [AnyClass]? = nil

  func send(_ request: URLRequest) async throws -> (Data, HTTPURLResponse) {
    let operation = BoundedProviderRequest()
    let configuration = Self.ephemeralConfiguration()
    configuration.protocolClasses = protocolClasses
    return try await withTaskCancellationHandler {
      try Task.checkCancellation()
      return try await withCheckedThrowingContinuation { continuation in
        operation.start(request, configuration: configuration, continuation: continuation)
      }
    } onCancel: {
      operation.cancel()
    }
  }

  static func ephemeralConfiguration() -> URLSessionConfiguration {
    let configuration = URLSessionConfiguration.ephemeral
    configuration.urlCache = nil
    configuration.urlCredentialStorage = nil
    configuration.httpCookieStorage = nil
    configuration.httpShouldSetCookies = false
    configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
    configuration.timeoutIntervalForRequest = 45
    configuration.timeoutIntervalForResource = 45
    return configuration
  }
}

/// One fresh session per request. Its buffer is bounded while receiving, not after download.
/// NSLock owns all mutable state across cancellation and URLSession delegate callbacks.
final class BoundedProviderRequest: NSObject, URLSessionDataDelegate, @unchecked Sendable {
  private let lock = NSLock()
  private var continuation: CheckedContinuation<(Data, HTTPURLResponse), any Error>?
  private var session: URLSession?
  private var response: HTTPURLResponse?
  private var data = Data()
  private var isCancelled = false
  private var isFinished = false

  func start(
    _ request: URLRequest, configuration: URLSessionConfiguration,
    continuation: CheckedContinuation<(Data, HTTPURLResponse), any Error>
  ) {
    lock.lock()
    guard !isCancelled else {
      lock.unlock()
      continuation.resume(throwing: CancellationError())
      return
    }
    self.continuation = continuation
    let session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
    self.session = session
    let task = session.dataTask(with: request)
    lock.unlock()
    task.resume()
  }

  func cancel() {
    lock.lock()
    isCancelled = true
    lock.unlock()
    finish(.failure(CancellationError()))
  }

  private func finish(_ result: Result<(Data, HTTPURLResponse), any Error>) {
    lock.lock()
    guard !isFinished, let continuation else {
      lock.unlock()
      return
    }
    isFinished = true
    self.continuation = nil
    let session = self.session
    self.session = nil
    data.removeAll(keepingCapacity: false)
    response = nil
    lock.unlock()
    session?.invalidateAndCancel()
    continuation.resume(with: result)
  }

  func urlSession(
    _ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse,
    completionHandler: @escaping @Sendable (URLSession.ResponseDisposition) -> Void
  ) {
    guard let response = response as? HTTPURLResponse,
      response.url == dataTask.originalRequest?.url
    else {
      completionHandler(.cancel)
      finish(.failure(ProviderAnalysisError.invalidResponse))
      return
    }
    guard response.expectedContentLength <= Int64(ProviderMealAnalyzer.maximumResponseBytes) else {
      completionHandler(.cancel)
      finish(.failure(ProviderAnalysisError.responseTooLarge))
      return
    }
    lock.lock()
    self.response = response
    let finished = isFinished
    lock.unlock()
    completionHandler(finished ? .cancel : .allow)
  }

  func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive chunk: Data) {
    lock.lock()
    guard !isFinished else {
      lock.unlock()
      return
    }
    guard chunk.count <= ProviderMealAnalyzer.maximumResponseBytes - data.count else {
      lock.unlock()
      finish(.failure(ProviderAnalysisError.responseTooLarge))
      return
    }
    data.append(chunk)
    lock.unlock()
  }

  func urlSession(
    _ session: URLSession, task: URLSessionTask, didCompleteWithError error: (any Error)?
  ) {
    if let error {
      let code = (error as? URLError)?.code
      if code == .cancelled {
        finish(.failure(CancellationError()))
      } else if code == .timedOut {
        finish(.failure(ProviderAnalysisError.timedOut))
      } else {
        finish(.failure(ProviderAnalysisError.connectionFailed))
      }
      return
    }
    lock.lock()
    let response = self.response
    let data = self.data
    lock.unlock()
    if let response {
      finish(.success((data, response)))
    } else {
      finish(.failure(ProviderAnalysisError.invalidResponse))
    }
  }

  func urlSession(
    _ session: URLSession, task: URLSessionTask,
    willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest,
    completionHandler: @escaping @Sendable (URLRequest?) -> Void
  ) {
    completionHandler(nil)
    finish(.failure(ProviderAnalysisError.redirectRejected))
  }

  func urlSession(
    _ session: URLSession, dataTask: URLSessionDataTask,
    willCacheResponse proposedResponse: CachedURLResponse,
    completionHandler: @escaping @Sendable (CachedURLResponse?) -> Void
  ) {
    completionHandler(nil)
  }
}
