import Foundation
import LocalAuthentication

/// Biometric authentication helper for Face ID / Touch ID on iOS and macOS
public final class BiometricAuth: Sendable {
    public enum BiometricType: Sendable {
        case none
        case touchID
        case faceID
        case opticID
    }

    public enum AuthError: Error, LocalizedError, Sendable {
        case notAvailable
        case failed(String)
        case cancelled

        public var errorDescription: String? {
            switch self {
            case .notAvailable:
                return "Biometric authentication is not available on this device"
            case .failed(let reason):
                return reason
            case .cancelled:
                return "Authentication was cancelled"
            }
        }
    }

    public static let shared = BiometricAuth()

    private init() {}

    /// Check what biometric type is available
    public var availableType: BiometricType {
        let context = LAContext()
        var error: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            return .none
        }

        switch context.biometryType {
        case .touchID: return .touchID
        case .faceID: return .faceID
        case .opticID: return .opticID
        default: return .none
        }
    }

    /// Whether biometric auth is available
    public var isAvailable: Bool {
        availableType != .none
    }

    /// Human-readable name for the available biometric type
    public var biometricName: String {
        switch availableType {
        case .none: "Biometrics"
        case .touchID: "Touch ID"
        case .faceID: "Face ID"
        case .opticID: "Optic ID"
        }
    }

    /// Authenticate the user with biometrics
    public func authenticate(reason: String = "Unlock the app") async throws -> Bool {
        let context = LAContext()
        var error: NSError?

        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            throw AuthError.notAvailable
        }

        do {
            let success = try await context.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: reason
            )
            return success
        } catch let laError as LAError {
            switch laError.code {
            case .userCancel, .appCancel, .systemCancel:
                throw AuthError.cancelled
            default:
                throw AuthError.failed(laError.localizedDescription)
            }
        }
    }
}
