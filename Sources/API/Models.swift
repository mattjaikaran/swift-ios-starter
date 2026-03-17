import Foundation

// MARK: - User Models

public struct User: Codable, Identifiable, Sendable {
    public let id: Int
    public let email: String
    public let username: String
    public let firstName: String
    public let lastName: String
    public let avatarUrl: String?
    public let bio: String
    public let isActive: Bool
    public let dateJoined: Date

    public init(
        id: Int,
        email: String,
        username: String,
        firstName: String = "",
        lastName: String = "",
        avatarUrl: String? = nil,
        bio: String = "",
        isActive: Bool = true,
        dateJoined: Date = Date()
    ) {
        self.id = id
        self.email = email
        self.username = username
        self.firstName = firstName
        self.lastName = lastName
        self.avatarUrl = avatarUrl
        self.bio = bio
        self.isActive = isActive
        self.dateJoined = dateJoined
    }
}

// MARK: - Auth Models

public struct LoginRequest: Codable, Sendable {
    public let email: String
    public let password: String

    public init(email: String, password: String) {
        self.email = email
        self.password = password
    }
}

public struct RegisterRequest: Codable, Sendable {
    public let email: String
    public let username: String
    public let password: String
    public let firstName: String?
    public let lastName: String?

    public init(
        email: String,
        username: String,
        password: String,
        firstName: String? = nil,
        lastName: String? = nil
    ) {
        self.email = email
        self.username = username
        self.password = password
        self.firstName = firstName
        self.lastName = lastName
    }
}

public struct TokenResponse: Codable, Sendable {
    public let accessToken: String
    public let refreshToken: String
    public let tokenType: String

    public init(accessToken: String, refreshToken: String, tokenType: String = "bearer") {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.tokenType = tokenType
    }
}

public struct RefreshTokenRequest: Codable, Sendable {
    public let refreshToken: String

    public init(refreshToken: String) {
        self.refreshToken = refreshToken
    }
}

public struct UserUpdateRequest: Codable, Sendable {
    public let firstName: String?
    public let lastName: String?
    public let avatarUrl: String?
    public let bio: String?

    public init(
        firstName: String? = nil,
        lastName: String? = nil,
        avatarUrl: String? = nil,
        bio: String? = nil
    ) {
        self.firstName = firstName
        self.lastName = lastName
        self.avatarUrl = avatarUrl
        self.bio = bio
    }
}

// MARK: - Organization Models (B2B)

public struct Organization: Codable, Identifiable, Sendable {
    public let id: UUID
    public let name: String
    public let slug: String
    public let logoUrl: String?
    public let plan: String
    public let role: String
    public let isActive: Bool

    public init(
        id: UUID,
        name: String,
        slug: String,
        logoUrl: String? = nil,
        plan: String = "free",
        role: String = "member",
        isActive: Bool = true
    ) {
        self.id = id
        self.name = name
        self.slug = slug
        self.logoUrl = logoUrl
        self.plan = plan
        self.role = role
        self.isActive = isActive
    }
}

public struct Team: Codable, Identifiable, Sendable {
    public let id: UUID
    public let organizationId: UUID
    public let name: String
    public let slug: String
    public let description: String
    public let createdAt: Date

    public init(
        id: UUID,
        organizationId: UUID,
        name: String,
        slug: String,
        description: String = "",
        createdAt: Date = Date()
    ) {
        self.id = id
        self.organizationId = organizationId
        self.name = name
        self.slug = slug
        self.description = description
        self.createdAt = createdAt
    }
}

public struct Member: Codable, Identifiable, Sendable {
    public let id: UUID
    public let userId: Int
    public let userEmail: String
    public let organizationId: UUID
    public let organizationName: String
    public let role: String
    public let isActive: Bool
    public let createdAt: Date

    public init(
        id: UUID,
        userId: Int,
        userEmail: String,
        organizationId: UUID,
        organizationName: String,
        role: String = "member",
        isActive: Bool = true,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.userId = userId
        self.userEmail = userEmail
        self.organizationId = organizationId
        self.organizationName = organizationName
        self.role = role
        self.isActive = isActive
        self.createdAt = createdAt
    }
}

// MARK: - Deep Link / Password Reset Models

public struct VerifyEmailRequest: Codable, Sendable {
    public let token: String

    public init(token: String) {
        self.token = token
    }
}

public struct ResetPasswordRequest: Codable, Sendable {
    public let token: String
    public let newPassword: String

    public init(token: String, newPassword: String) {
        self.token = token
        self.newPassword = newPassword
    }
}

public struct ForgotPasswordRequest: Codable, Sendable {
    public let email: String

    public init(email: String) {
        self.email = email
    }
}

// MARK: - Generic Response Types

public struct MessageResponse: Codable, Sendable {
    public let message: String

    public init(message: String) {
        self.message = message
    }
}

public struct PaginatedResponse<T: Codable & Sendable>: Codable, Sendable {
    public let items: [T]
    public let total: Int
    public let page: Int
    public let pageSize: Int
    public let totalPages: Int

    public init(items: [T], total: Int, page: Int = 1, pageSize: Int = 20) {
        self.items = items
        self.total = total
        self.page = page
        self.pageSize = pageSize
        self.totalPages = (total + pageSize - 1) / pageSize
    }
}
