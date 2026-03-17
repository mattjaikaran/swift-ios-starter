import Foundation

/// API error types
public enum APIError: Error, LocalizedError {
    case invalidURL
    case networkError(Error)
    case decodingError(Error)
    case httpError(statusCode: Int, message: String?)
    case unauthorized
    case notFound
    case serverError

    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .decodingError(let error):
            return "Decoding error: \(error.localizedDescription)"
        case .httpError(let statusCode, let message):
            return "HTTP \(statusCode): \(message ?? "Unknown error")"
        case .unauthorized:
            return "Unauthorized - please login again"
        case .notFound:
            return "Resource not found"
        case .serverError:
            return "Server error - please try again later"
        }
    }
}

/// Token storage protocol
public protocol TokenStorage {
    var accessToken: String? { get set }
    var refreshToken: String? { get set }
    var tokenExpiresAt: Date? { get set }
    func clearTokens()
}

/// Default token storage using UserDefaults
public class DefaultTokenStorage: TokenStorage {
    private let accessTokenKey = "access_token"
    private let refreshTokenKey = "refresh_token"
    private let tokenExpiresAtKey = "token_expires_at"

    public var accessToken: String? {
        get { UserDefaults.standard.string(forKey: accessTokenKey) }
        set { UserDefaults.standard.set(newValue, forKey: accessTokenKey) }
    }

    public var refreshToken: String? {
        get { UserDefaults.standard.string(forKey: refreshTokenKey) }
        set { UserDefaults.standard.set(newValue, forKey: refreshTokenKey) }
    }

    public var tokenExpiresAt: Date? {
        get { UserDefaults.standard.object(forKey: tokenExpiresAtKey) as? Date }
        set { UserDefaults.standard.set(newValue, forKey: tokenExpiresAtKey) }
    }

    public func clearTokens() {
        UserDefaults.standard.removeObject(forKey: accessTokenKey)
        UserDefaults.standard.removeObject(forKey: refreshTokenKey)
        UserDefaults.standard.removeObject(forKey: tokenExpiresAtKey)
    }

    public init() {}
}

/// Main API client
public actor APIClient {
    public let baseURL: URL
    private let session: URLSession
    private var tokenStorage: TokenStorage
    private var isRefreshing = false

    private let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }()

    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()

    public init(
        baseURL: URL,
        session: URLSession = .shared,
        tokenStorage: TokenStorage = KeychainTokenStorage()
    ) {
        self.baseURL = baseURL
        self.session = session
        self.tokenStorage = tokenStorage
    }

    // MARK: - Token Management

    public func setTokens(access: String, refresh: String, expiresAt: Date? = nil) {
        tokenStorage.accessToken = access
        tokenStorage.refreshToken = refresh
        tokenStorage.tokenExpiresAt = expiresAt
    }

    public func clearTokens() {
        tokenStorage.clearTokens()
    }

    public func getRefreshToken() -> String? {
        tokenStorage.refreshToken
    }

    public var isAuthenticated: Bool {
        tokenStorage.accessToken != nil
    }

    /// Whether the current access token is expired or about to expire (within 60s)
    public var isTokenExpired: Bool {
        guard let expiresAt = tokenStorage.tokenExpiresAt else { return false }
        return expiresAt.timeIntervalSinceNow < 60
    }

    // MARK: - HTTP Methods

    public func get<T: Decodable>(_ path: String, query: [String: String]? = nil) async throws -> T {
        try await request(path: path, method: "GET", query: query)
    }

    public func post<T: Decodable, B: Encodable>(_ path: String, body: B) async throws -> T {
        try await request(path: path, method: "POST", body: body)
    }

    public func put<T: Decodable, B: Encodable>(_ path: String, body: B) async throws -> T {
        try await request(path: path, method: "PUT", body: body)
    }

    public func patch<T: Decodable, B: Encodable>(_ path: String, body: B) async throws -> T {
        try await request(path: path, method: "PATCH", body: body)
    }

    public func delete(_ path: String) async throws {
        let _: EmptyResponse = try await request(path: path, method: "DELETE")
    }

    // MARK: - Request Builder

    private func request<T: Decodable, B: Encodable>(
        path: String,
        method: String,
        query: [String: String]? = nil,
        body: B? = nil
    ) async throws -> T {
        var urlComponents = URLComponents(url: baseURL.appendingPathComponent(path), resolvingAgainstBaseURL: true)

        if let query = query {
            urlComponents?.queryItems = query.map { URLQueryItem(name: $0.key, value: $0.value) }
        }

        guard let url = urlComponents?.url else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        if let token = tokenStorage.accessToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        if let body = body {
            request.httpBody = try encoder.encode(body)
        }

        return try await performRequest(request)
    }

    private func request<T: Decodable>(
        path: String,
        method: String,
        query: [String: String]? = nil
    ) async throws -> T {
        try await request(path: path, method: method, query: query, body: Optional<EmptyBody>.none)
    }

    private func performRequest<T: Decodable>(
        _ request: URLRequest,
        isRetry: Bool = false
    ) async throws -> T {
        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.networkError(URLError(.badServerResponse))
        }

        switch httpResponse.statusCode {
        case 200...299:
            do {
                return try decoder.decode(T.self, from: data)
            } catch {
                throw APIError.decodingError(error)
            }
        case 401:
            // Don't retry if this is already a retry or a refresh request
            if !isRetry, try await attemptTokenRefresh() {
                // Rebuild request with new access token
                var retryRequest = request
                if let token = tokenStorage.accessToken {
                    retryRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
                }
                return try await performRequest(retryRequest, isRetry: true)
            }
            throw APIError.unauthorized
        case 404:
            throw APIError.notFound
        case 500...599:
            throw APIError.serverError
        default:
            let message = try? decoder.decode(ErrorResponse.self, from: data).message
            throw APIError.httpError(statusCode: httpResponse.statusCode, message: message)
        }
    }

    // MARK: - Token Refresh

    /// Attempts to refresh the access token using the stored refresh token.
    /// Returns `true` if refresh succeeded, `false` if no refresh token or refresh failed.
    private func attemptTokenRefresh() async throws -> Bool {
        guard !isRefreshing else { return false }
        guard let refreshToken = tokenStorage.refreshToken else { return false }

        isRefreshing = true
        defer { isRefreshing = false }

        let refreshBody = RefreshTokenRequest(refreshToken: refreshToken)
        let bodyData = try encoder.encode(refreshBody)

        guard let url = URL(string: "/auth/refresh", relativeTo: baseURL) else {
            return false
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.httpBody = bodyData

        do {
            let (data, response) = try await session.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                return false
            }
            let tokens = try decoder.decode(TokenResponse.self, from: data)
            tokenStorage.accessToken = tokens.accessToken
            tokenStorage.refreshToken = tokens.refreshToken
            return true
        } catch {
            return false
        }
    }
}

// MARK: - Helper Types

private struct EmptyBody: Encodable {}
private struct EmptyResponse: Decodable {}
private struct ErrorResponse: Decodable {
    let message: String?
}
