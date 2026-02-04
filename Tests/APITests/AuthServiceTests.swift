import XCTest
@testable import API

final class AuthServiceTests: XCTestCase {

    var client: APIClient!
    var authService: AuthService!

    override func setUp() async throws {
        let url = URL(string: "https://api.example.com")!
        client = APIClient(baseURL: url)
        authService = AuthService(client: client)
    }

    override func tearDown() async throws {
        await client.clearTokens()
        client = nil
        authService = nil
    }

    // MARK: - Initialization Tests

    func testAuthServiceInitialization() async {
        XCTAssertNotNil(authService)
    }

    func testInitiallyNotAuthenticated() async {
        let isAuthenticated = await authService.isAuthenticated
        XCTAssertFalse(isAuthenticated)
    }

    // MARK: - Logout Tests

    func testLogoutClearsAuthentication() async {
        // Set up authenticated state
        await client.setTokens(access: "test-access", refresh: "test-refresh")

        var isAuthenticated = await authService.isAuthenticated
        XCTAssertTrue(isAuthenticated)

        // Logout
        await authService.logout()

        isAuthenticated = await authService.isAuthenticated
        XCTAssertFalse(isAuthenticated)
    }
}

// MARK: - Token Storage Tests

final class DefaultTokenStorageTests: XCTestCase {

    var storage: DefaultTokenStorage!

    override func setUp() {
        storage = DefaultTokenStorage()
        storage.clearTokens()
    }

    override func tearDown() {
        storage.clearTokens()
        storage = nil
    }

    func testInitiallyNoTokens() {
        XCTAssertNil(storage.accessToken)
        XCTAssertNil(storage.refreshToken)
    }

    func testSetAndGetAccessToken() {
        storage.accessToken = "test-access-token"
        XCTAssertEqual(storage.accessToken, "test-access-token")
    }

    func testSetAndGetRefreshToken() {
        storage.refreshToken = "test-refresh-token"
        XCTAssertEqual(storage.refreshToken, "test-refresh-token")
    }

    func testClearTokens() {
        storage.accessToken = "test-access"
        storage.refreshToken = "test-refresh"

        storage.clearTokens()

        XCTAssertNil(storage.accessToken)
        XCTAssertNil(storage.refreshToken)
    }
}
