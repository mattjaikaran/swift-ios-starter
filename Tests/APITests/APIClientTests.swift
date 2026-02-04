import XCTest
@testable import API

final class APIClientTests: XCTestCase {

    var client: APIClient!

    override func setUp() async throws {
        let url = URL(string: "https://api.example.com")!
        client = APIClient(baseURL: url)
    }

    override func tearDown() async throws {
        await client.clearTokens()
        client = nil
    }

    // MARK: - Initialization Tests

    func testClientInitialization() async {
        let url = URL(string: "https://api.example.com")!
        let testClient = APIClient(baseURL: url)

        let baseURL = await testClient.baseURL
        XCTAssertEqual(baseURL.absoluteString, "https://api.example.com")
    }

    func testInitiallyNotAuthenticated() async {
        let isAuthenticated = await client.isAuthenticated
        XCTAssertFalse(isAuthenticated)
    }

    // MARK: - Token Management Tests

    func testSetTokensMakesClientAuthenticated() async {
        await client.setTokens(access: "test-access-token", refresh: "test-refresh-token")

        let isAuthenticated = await client.isAuthenticated
        XCTAssertTrue(isAuthenticated)
    }

    func testClearTokensMakesClientUnauthenticated() async {
        await client.setTokens(access: "test-access-token", refresh: "test-refresh-token")
        await client.clearTokens()

        let isAuthenticated = await client.isAuthenticated
        XCTAssertFalse(isAuthenticated)
    }
}

// MARK: - API Error Tests

final class APIErrorTests: XCTestCase {

    func testInvalidURLErrorDescription() {
        let error = APIError.invalidURL
        XCTAssertEqual(error.errorDescription, "Invalid URL")
    }

    func testUnauthorizedErrorDescription() {
        let error = APIError.unauthorized
        XCTAssertEqual(error.errorDescription, "Unauthorized - please login again")
    }

    func testNotFoundErrorDescription() {
        let error = APIError.notFound
        XCTAssertEqual(error.errorDescription, "Resource not found")
    }

    func testServerErrorDescription() {
        let error = APIError.serverError
        XCTAssertEqual(error.errorDescription, "Server error - please try again later")
    }

    func testHTTPErrorDescriptionWithMessage() {
        let error = APIError.httpError(statusCode: 400, message: "Bad request")
        XCTAssertEqual(error.errorDescription, "HTTP 400: Bad request")
    }

    func testHTTPErrorDescriptionWithoutMessage() {
        let error = APIError.httpError(statusCode: 400, message: nil)
        XCTAssertEqual(error.errorDescription, "HTTP 400: Unknown error")
    }
}
