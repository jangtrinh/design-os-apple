import Foundation
import Observation
import SwiftUI
import CalorieCamCore

enum AppAppearance: String, CaseIterable, Identifiable {
    case system, light, dark
    var id: String { rawValue }
    var label: String { rawValue.capitalized }
    var colorScheme: ColorScheme? {
        switch self { case .system: nil; case .light: .light; case .dark: .dark }
    }
}

enum AnalysisMode: String, CaseIterable, Identifiable {
    case offline, provider, backend
    var id: String { rawValue }
    var label: String {
        switch self {
        case .offline: "Manual and demo only"
        case .provider: "My provider API key"
        case .backend: "Developer backend"
        }
    }
}

enum AnalysisRoute: Sendable {
    case provider(ProviderConfiguration)
    case backend(URL)

    var recipient: String {
        switch self {
        case .provider(let config): "\(config.provider.displayName) at \(config.provider.apiHost), model \(config.modelID)"
        case .backend(let url): "\(url.host ?? "configured backend") and OpenAI"
        }
    }
}

enum AISettingsError: LocalizedError {
    case missingKey, missingBackend, offline, testNetworkDisabled
    var errorDescription: String? {
        switch self {
        case .testNetworkDisabled: "Network requests are disabled in UI tests."
        case .missingKey: "Save an API key for this provider in AI settings first."
        case .missingBackend: "No developer backend URL is configured. Choose a provider or use manual entry."
        case .offline: "AI estimation is off. Manual entry and demo values are available."
        }
    }
}

@MainActor @Observable
final class AISettingsStore {
    private(set) var appearance: AppAppearance
    private(set) var mode: AnalysisMode
    private(set) var provider: AIProvider
    private(set) var revision = 0
    let keychain: ProviderKeychain
    private let preferences: UserDefaults
    let isUITest: Bool

    init() {
        let bundle = Bundle.main.bundleIdentifier ?? "com.designos.examples.CalorieCam"
        #if DEBUG
        let testID = ProcessInfo.processInfo.environment["CALORIECAM_TEST_JOURNAL"].flatMap(UUID.init(uuidString:))
        #else
        let testID: UUID? = nil
        #endif
        isUITest = testID != nil
        let namespace = testID.map { "\(bundle).uitest.\($0.uuidString)" } ?? bundle
        guard let defaults = UserDefaults(suiteName: "\(namespace).analysis") else { preconditionFailure("Cannot open app preferences.") }
        preferences = defaults
        appearance = preferences.string(forKey: "appearance").flatMap(AppAppearance.init(rawValue:)) ?? .system
        keychain = ProviderKeychain(service: "\(namespace).provider-keys")
        mode = preferences.string(forKey: "mode").flatMap(AnalysisMode.init(rawValue:))
            ?? (AnalysisConfiguration.endpoint == nil ? .offline : .backend)
        provider = preferences.string(forKey: "provider").flatMap(AIProvider.init(rawValue:)) ?? .openAI
    }

    func model(for provider: AIProvider) -> String { preferences.string(forKey: "model.\(provider.rawValue)") ?? "" }

    func save(appearance: AppAppearance, mode: AnalysisMode, provider: AIProvider, model: String, replacementKey: String?) async throws {
        let normalized = model.trimmingCharacters(in: .whitespacesAndNewlines)
        if mode == .provider { _ = try ProviderConfiguration(provider: provider, modelID: normalized) }
        if mode == .backend && AnalysisConfiguration.endpoint == nil { throw AISettingsError.missingBackend }
        if mode == .provider, let replacementKey {
            let config = try ProviderConfiguration(provider: provider, modelID: normalized)
            _ = try ProviderMealAnalyzer(configuration: config, apiKey: replacementKey)
            // Persist the credential first. Never report success if secure storage fails.
            try await keychain.save(replacementKey.trimmingCharacters(in: .whitespacesAndNewlines), for: provider)
        } else if mode == .provider {
            guard try await keychain.read(provider) != nil else { throw AISettingsError.missingKey }
        }
        preferences.set(appearance.rawValue, forKey: "appearance")
        self.appearance = appearance
        preferences.set(normalized, forKey: "model.\(provider.rawValue)")
        preferences.set(provider.rawValue, forKey: "provider")
        preferences.set(mode.rawValue, forKey: "mode")
        self.mode = mode
        self.provider = provider
        revision += 1
    }

    func removeKey(for provider: AIProvider) async throws {
        try await keychain.remove(provider)
        revision += 1
    }

    func route() throws -> AnalysisRoute {
        switch mode {
        case .offline: throw AISettingsError.offline
        case .backend:
            guard let endpoint = AnalysisConfiguration.endpoint else { throw AISettingsError.missingBackend }
            return .backend(endpoint)
        case .provider:
            return .provider(try ProviderConfiguration(provider: provider, modelID: model(for: provider)))
        }
    }

    func verify(configuration: ProviderConfiguration, key: String) async throws -> String {
        #if DEBUG
        if isUITest {
            guard ProcessInfo.processInfo.environment["CALORIECAM_TEST_CONNECTION"] == "mock" else { throw AISettingsError.testNetworkDisabled }
            try Task.checkCancellation()
            guard key == "local-ui-fixture-\(configuration.provider.rawValue)" else { throw ProviderAnalysisError.permissionDenied }
            return "Local test fixture: model metadata available. No network request."
        }
        #endif
        let analyzer = try ProviderMealAnalyzer(configuration: configuration, apiKey: key)
        _ = try await analyzer.verifyConnection()
        return "Key and model access confirmed. Photo estimation and structured-output support have not been tested."
    }

    func key(for provider: AIProvider) async throws -> String {
        guard let key = try await keychain.read(provider) else { throw AISettingsError.missingKey }
        return key
    }
}
