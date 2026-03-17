import Foundation
import Security

/// Secure token storage using the system Keychain (works on iOS and macOS)
public class KeychainTokenStorage: TokenStorage {
    private let service: String
    private let accessTokenAccount = "access_token"
    private let refreshTokenAccount = "refresh_token"

    public init(service: String = "com.myapp.auth") {
        self.service = service
    }

    public var accessToken: String? {
        get { read(account: accessTokenAccount) }
        set {
            if let value = newValue {
                save(value, account: accessTokenAccount)
            } else {
                delete(account: accessTokenAccount)
            }
        }
    }

    public var refreshToken: String? {
        get { read(account: refreshTokenAccount) }
        set {
            if let value = newValue {
                save(value, account: refreshTokenAccount)
            } else {
                delete(account: refreshTokenAccount)
            }
        }
    }

    public func clearTokens() {
        delete(account: accessTokenAccount)
        delete(account: refreshTokenAccount)
    }

    // MARK: - Keychain Operations

    private func save(_ value: String, account: String) {
        guard let data = value.data(using: .utf8) else { return }

        // Delete existing item first
        delete(account: account)

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock,
        ]

        SecItemAdd(query as CFDictionary, nil)
    }

    private func read(account: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne,
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess, let data = result as? Data else {
            return nil
        }

        return String(data: data, encoding: .utf8)
    }

    private func delete(account: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
        ]

        SecItemDelete(query as CFDictionary)
    }
}
