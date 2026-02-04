import XCTest
@testable import API

final class ModelsTests: XCTestCase {

    let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }()

    let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()

    // MARK: - User Model Tests

    func testUserInitialization() {
        let user = User(
            id: 1,
            email: "test@example.com",
            username: "testuser",
            firstName: "Test",
            lastName: "User"
        )

        XCTAssertEqual(user.id, 1)
        XCTAssertEqual(user.email, "test@example.com")
        XCTAssertEqual(user.username, "testuser")
        XCTAssertEqual(user.firstName, "Test")
        XCTAssertEqual(user.lastName, "User")
        XCTAssertTrue(user.isActive)
    }

    func testUserDefaultValues() {
        let user = User(id: 1, email: "test@example.com", username: "testuser")

        XCTAssertEqual(user.firstName, "")
        XCTAssertEqual(user.lastName, "")
        XCTAssertNil(user.avatarUrl)
        XCTAssertEqual(user.bio, "")
        XCTAssertTrue(user.isActive)
    }

    func testUserCodable() throws {
        let user = User(
            id: 1,
            email: "test@example.com",
            username: "testuser",
            firstName: "Test",
            lastName: "User"
        )

        let data = try encoder.encode(user)
        let decoded = try decoder.decode(User.self, from: data)

        XCTAssertEqual(decoded.id, user.id)
        XCTAssertEqual(decoded.email, user.email)
        XCTAssertEqual(decoded.username, user.username)
    }

    // MARK: - LoginRequest Tests

    func testLoginRequestInitialization() {
        let request = LoginRequest(email: "test@example.com", password: "password123")

        XCTAssertEqual(request.email, "test@example.com")
        XCTAssertEqual(request.password, "password123")
    }

    func testLoginRequestCodable() throws {
        let request = LoginRequest(email: "test@example.com", password: "password123")

        let data = try encoder.encode(request)
        let decoded = try decoder.decode(LoginRequest.self, from: data)

        XCTAssertEqual(decoded.email, request.email)
        XCTAssertEqual(decoded.password, request.password)
    }

    // MARK: - RegisterRequest Tests

    func testRegisterRequestInitialization() {
        let request = RegisterRequest(
            email: "test@example.com",
            username: "testuser",
            password: "password123",
            firstName: "Test",
            lastName: "User"
        )

        XCTAssertEqual(request.email, "test@example.com")
        XCTAssertEqual(request.username, "testuser")
        XCTAssertEqual(request.password, "password123")
        XCTAssertEqual(request.firstName, "Test")
        XCTAssertEqual(request.lastName, "User")
    }

    // MARK: - TokenResponse Tests

    func testTokenResponseInitialization() {
        let response = TokenResponse(
            accessToken: "access123",
            refreshToken: "refresh456"
        )

        XCTAssertEqual(response.accessToken, "access123")
        XCTAssertEqual(response.refreshToken, "refresh456")
        XCTAssertEqual(response.tokenType, "bearer")
    }

    // MARK: - Organization Tests

    func testOrganizationInitialization() {
        let orgId = UUID()
        let org = Organization(
            id: orgId,
            name: "Test Org",
            slug: "test-org"
        )

        XCTAssertEqual(org.id, orgId)
        XCTAssertEqual(org.name, "Test Org")
        XCTAssertEqual(org.slug, "test-org")
        XCTAssertEqual(org.plan, "free")
        XCTAssertEqual(org.role, "member")
        XCTAssertTrue(org.isActive)
    }

    // MARK: - Team Tests

    func testTeamInitialization() {
        let teamId = UUID()
        let orgId = UUID()
        let team = Team(
            id: teamId,
            organizationId: orgId,
            name: "Engineering",
            slug: "engineering"
        )

        XCTAssertEqual(team.id, teamId)
        XCTAssertEqual(team.organizationId, orgId)
        XCTAssertEqual(team.name, "Engineering")
        XCTAssertEqual(team.slug, "engineering")
    }

    // MARK: - PaginatedResponse Tests

    func testPaginatedResponseCalculation() {
        let users = [
            User(id: 1, email: "user1@example.com", username: "user1"),
            User(id: 2, email: "user2@example.com", username: "user2")
        ]

        let response = PaginatedResponse(items: users, total: 50, page: 1, pageSize: 20)

        XCTAssertEqual(response.items.count, 2)
        XCTAssertEqual(response.total, 50)
        XCTAssertEqual(response.page, 1)
        XCTAssertEqual(response.pageSize, 20)
        XCTAssertEqual(response.totalPages, 3)
    }

    func testPaginatedResponseTotalPagesRounding() {
        let users: [User] = []

        // 25 items with page size 20 should be 2 pages
        let response = PaginatedResponse(items: users, total: 25, page: 1, pageSize: 20)
        XCTAssertEqual(response.totalPages, 2)

        // 40 items with page size 20 should be exactly 2 pages
        let response2 = PaginatedResponse(items: users, total: 40, page: 1, pageSize: 20)
        XCTAssertEqual(response2.totalPages, 2)
    }
}
