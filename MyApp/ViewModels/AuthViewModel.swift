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
    private let cacheService = CacheService.shared

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
        isCheckingAuth = true
        defer { isCheckingAuth = false }

        // Show cached user immediately (no loading state)
        if let cachedUser = cacheService.getCachedUser() {
            self.user = cachedUser
            self.isAuthenticated = true
        }

        guard await client.isAuthenticated else {
            // If no valid auth but we showed cached data, clear it
            if user != nil && !isAuthenticated {
                user = nil
            }
            return
        }

        do {
            let freshUser = try await authService.getCurrentUser()
            cacheService.cacheUser(freshUser)
            user = freshUser
            isAuthenticated = true
        } catch {
            // If we already have a cached user, keep showing it
            if user == nil {
                isAuthenticated = false
            }
        }
    }

    func login(email: String, password: String) async {
        isLoading = true
        error = nil

        do {
            let loggedInUser = try await authService.login(email: email, password: password)
            cacheService.cacheUser(loggedInUser)
            user = loggedInUser
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
        cacheService.clearAll()
        user = nil
        isAuthenticated = false
    }

    func updateProfile(firstName: String? = nil, lastName: String? = nil) async {
        isLoading = true
        error = nil

        do {
            let updatedUser = try await authService.updateProfile(firstName: firstName, lastName: lastName)
            cacheService.cacheUser(updatedUser)
            user = updatedUser
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
