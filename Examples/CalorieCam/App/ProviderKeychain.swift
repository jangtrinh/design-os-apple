import Foundation
import Security
import CalorieCamCore

/// Explicit platform policy, never a runtime fallback:
/// iOS uses device-only data protection; macOS uses the user's default file-based
/// Keychain with its native per-app ACL. Neither synchronizes through iCloud.
actor ProviderKeychain {
    let service: String
    init(service: String) { self.service = service }

    private func query(_ provider: AIProvider, inserting: Bool = false) throws -> [String: Any] {
        var result: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: provider.rawValue,
            kSecAttrSynchronizable as String: false
        ]
        #if os(macOS)
        var keychain: SecKeychain?
        let status = SecKeychainCopyDefault(&keychain)
        guard status == errSecSuccess, let keychain else { throw KeychainFailure(status: status) }
        result[kSecUseDataProtectionKeychain as String] = false
        if inserting { result[kSecUseKeychain as String] = keychain }
        else { result[kSecMatchSearchList as String] = [keychain] }
        #endif
        return result
    }

    func read(_ provider: AIProvider) throws -> String? {
        var request = try query(provider)
        request[kSecReturnData as String] = true
        request[kSecMatchLimit as String] = kSecMatchLimitOne
        var item: CFTypeRef?
        let status = SecItemCopyMatching(request as CFDictionary, &item)
        if status == errSecItemNotFound { return nil }
        guard status == errSecSuccess else { throw KeychainFailure(status: status) }
        guard let data = item as? Data, let value = String(data: data, encoding: .utf8), !value.isEmpty else {
            throw KeychainFailure(status: errSecDecode)
        }
        return value
    }

    func save(_ key: String, for provider: AIProvider) throws {
        var attributes: [String: Any] = [kSecValueData as String: Data(key.utf8)]
        #if os(iOS)
        attributes[kSecAttrAccessible as String] = kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        #endif
        let status = SecItemUpdate(try query(provider) as CFDictionary, attributes as CFDictionary)
        if status == errSecItemNotFound {
            let insertion = try query(provider, inserting: true).merging(attributes) { _, new in new }
            let added = SecItemAdd(insertion as CFDictionary, nil)
            guard added == errSecSuccess else { throw KeychainFailure(status: added) }
        } else if status != errSecSuccess { throw KeychainFailure(status: status) }
    }

    func remove(_ provider: AIProvider) throws {
        let status = SecItemDelete(try query(provider) as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else { throw KeychainFailure(status: status) }
    }
}

struct KeychainFailure: LocalizedError {
    let status: OSStatus
    var errorDescription: String? {
        switch status {
        case errSecMissingEntitlement:
            "Secure storage requires a correctly signed app with Keychain access. Ask the app developer to check signing. No key was stored insecurely."
        case errSecInteractionNotAllowed, errSecAuthFailed:
            "Secure storage is locked or access was denied. Unlock the device and try again. No insecure fallback is used."
        default:
            "Secure storage is unavailable (code \(status)). No insecure fallback is used."
        }
    }
}
