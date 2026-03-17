import Foundation
import API

@MainActor
class AuthViewModel: ObservableObject {
    @Published var user: User?
    @Published var isLoading = false
    @Published var isCheckingAuth = true
    @Published var error: String?
    @Published var isAuthenticated = false
    @Published var biometricEnabled = false

    private let client: APIClient
    private let authService: AuthService
    private let biometricAuth = BiometricAuth.shared

    let environment: AppEnvironment

    var isBiometricAvailable: Bool { biometricAuth.isAvailable }
    var biometricName: String { biometricAuth.biometricName }

    init(environment: AppEnvironment = .current) {
        self.environment = environment
        self.client = APIClient(baseURL: environment.baseURL)
        self.authService = AuthService(client: client)
        self.biometricEnabled = UserDefaults.standard.bool(forKey: "biometric_enabled")
    }

    func checkAuth() async {
        AppLogger.debug("Auth check started", category: AppLogger.auth)
        isCheckingAuth = true
        defer { isCheckingAuth = false }

        guard await client.isAuthenticated else {
            AppLogger.debug("Auth state: authenticated=false (no token)", category: AppLogger.auth)
            return
        }

        do {
            user = try await authService.getCurrentUser()
            isAuthenticated = true
            AppLogger.debug("Auth state: authenticated=true", category: AppLogger.auth)
        } catch {
            isAuthenticated = false
            AppLogger.debug("Auth state: authenticated=false (check failed)", category: AppLogger.auth)
        }
    }

    func login(email: String, password: String) async {
        isLoading = true
        error = nil

        do {
            user = try await authService.login(email: email, password: password)
            isAuthenticated = true
        } catch let apiError as APIError {
            error = apiError.localizedDescription
        } catch {
            self.error = error.localizedDescription
        }

        isLoading = false
    }

    func register(email: String, username: String, password: String) async {
        isLoading = true
        error = nil

        do {
            _ = try await authService.register(
                email: email,
                username: username,
                password: password
            )
            // Auto-login after registration
            await login(email: email, password: password)
        } catch let apiError as APIError {
            error = apiError.localizedDescription
        } catch {
            self.error = error.localizedDescription
        }

        isLoading = false
    }

    func logout() async {
        await authService.logout()
        user = nil
        isAuthenticated = false
    }

    func updateProfile(firstName: String? = nil, lastName: String? = nil) async {
        isLoading = true
        error = nil

        do {
            user = try await authService.updateProfile(firstName: firstName, lastName: lastName)
        } catch let apiError as APIError {
            error = apiError.localizedDescription
        } catch {
            self.error = error.localizedDescription
        }

        isLoading = false
    }

    // MARK: - Biometrics

    func setBiometricEnabled(_ enabled: Bool) {
        biometricEnabled = enabled
        UserDefaults.standard.set(enabled, forKey: "biometric_enabled")
    }

    func authenticateWithBiometrics() async -> Bool {
        guard biometricEnabled, biometricAuth.isAvailable else { return false }
        do {
            return try await biometricAuth.authenticate(reason: "Sign in to MyApp")
        } catch {
            return false
        }
    }
}
