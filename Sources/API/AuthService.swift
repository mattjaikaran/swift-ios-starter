import Foundation

/// Authentication service for managing user auth state
public actor AuthService {
    private let client: APIClient

    public init(client: APIClient) {
        self.client = client
    }

    /// Login with email and password
    public func login(email: String, password: String) async throws -> User {
        let request = LoginRequest(email: email, password: password)
        let tokens: TokenResponse = try await client.post("/auth/login", body: request)
        await client.setTokens(access: tokens.accessToken, refresh: tokens.refreshToken)
        return try await getCurrentUser()
    }

    /// Register a new user
    public func register(
        email: String,
        username: String,
        password: String,
        firstName: String? = nil,
        lastName: String? = nil
    ) async throws -> User {
        let request = RegisterRequest(
            email: email,
            username: username,
            password: password,
            firstName: firstName,
            lastName: lastName
        )
        return try await client.post("/auth/register", body: request)
    }

    /// Get current authenticated user
    public func getCurrentUser() async throws -> User {
        try await client.get("/auth/me")
    }

    /// Update current user profile
    public func updateProfile(
        firstName: String? = nil,
        lastName: String? = nil,
        avatarUrl: String? = nil,
        bio: String? = nil
    ) async throws -> User {
        let request = UserUpdateRequest(
            firstName: firstName,
            lastName: lastName,
            avatarUrl: avatarUrl,
            bio: bio
        )
        return try await client.patch("/auth/me", body: request)
    }

    /// Refresh access token
    public func refreshToken() async throws {
        guard let refreshToken = await getRefreshToken() else {
            throw APIError.unauthorized
        }

        let request = RefreshTokenRequest(refreshToken: refreshToken)
        let tokens: TokenResponse = try await client.post("/auth/refresh", body: request)
        await client.setTokens(access: tokens.accessToken, refresh: tokens.refreshToken)
    }

    /// Logout and clear tokens
    public func logout() async {
        await client.clearTokens()
    }

    /// Verify email with token
    public func verifyEmail(token: String) async throws -> MessageResponse {
        try await client.post("/auth/verify-email", body: VerifyEmailRequest(token: token))
    }

    /// Reset password with token
    public func resetPassword(token: String, newPassword: String) async throws -> MessageResponse {
        try await client.post("/auth/reset-password", body: ResetPasswordRequest(token: token, newPassword: newPassword))
    }

    /// Request a password reset email
    public func requestPasswordReset(email: String) async throws -> MessageResponse {
        try await client.post("/auth/forgot-password", body: ForgotPasswordRequest(email: email))
    }

    /// Check if user is authenticated
    public var isAuthenticated: Bool {
        get async { await client.isAuthenticated }
    }

    private func getRefreshToken() async -> String? {
        // This would need access to token storage
        // For now, return nil and handle in calling code
        nil
    }
}
