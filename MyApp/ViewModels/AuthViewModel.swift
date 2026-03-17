import Foundation
import API

@MainActor
class AuthViewModel: ObservableObject {
    @Published var user: User?
    @Published var isLoading = false
    @Published var isCheckingAuth = true
    @Published var error: String?
    @Published var isAuthenticated = false

    private let client: APIClient
    private let authService: AuthService

    let environment: AppEnvironment

    init(environment: AppEnvironment = .current) {
        self.environment = environment
        self.client = APIClient(baseURL: environment.baseURL)
        self.authService = AuthService(client: client)
    }

    func checkAuth() async {
        isCheckingAuth = true
        defer { isCheckingAuth = false }

        guard await client.isAuthenticated else { return }

        do {
            user = try await authService.getCurrentUser()
            isAuthenticated = true
        } catch {
            isAuthenticated = false
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
}
