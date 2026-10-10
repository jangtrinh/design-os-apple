import Foundation

/// Optional developer configuration. Public backend URLs are not API credentials.
/// Release builds accept HTTPS only; local HTTP requires an explicit Debug opt-in.
enum AnalysisConfiguration {
    static var allowsLocalHTTP: Bool {
        #if DEBUG
        ProcessInfo.processInfo.environment["CALORIECAM_ALLOW_LOCAL_HTTP"] == "1"
        #else
        false
        #endif
    }

    static var endpoint: URL? {
        let value = ProcessInfo.processInfo.environment["CALORIECAM_ANALYSIS_URL"]
            ?? Bundle.main.object(forInfoDictionaryKey: "CALORIECAM_ANALYSIS_URL") as? String
        guard let value, let url = URL(string: value), let host = url.host?.lowercased(), !host.isEmpty,
              url.user == nil, url.password == nil, url.query == nil, url.fragment == nil else { return nil }
        let isLoopback = ["localhost", "127.0.0.1", "::1", "[::1]"].contains(host)
        let secure = url.scheme?.lowercased() == "https"
        let optedInLocal = allowsLocalHTTP && isLoopback && url.scheme?.lowercased() == "http"
        return secure || optedInLocal ? url : nil
    }
}
