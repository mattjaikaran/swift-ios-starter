import Foundation
import SwiftData

@Model
public final class CachedUser {
    @Attribute(.unique) public var id: Int
    public var email: String
    public var username: String
    public var firstName: String
    public var lastName: String
    public var avatarUrl: String?
    public var bio: String
    public var isActive: Bool
    public var dateJoined: Date
    public var lastFetchedAt: Date

    public init(
        id: Int,
        email: String,
        username: String,
        firstName: String,
        lastName: String,
        avatarUrl: String?,
        bio: String,
        isActive: Bool,
        dateJoined: Date,
        lastFetchedAt: Date = Date()
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
        self.lastFetchedAt = lastFetchedAt
    }

    public convenience init(from user: User) {
        self.init(
            id: user.id,
            email: user.email,
            username: user.username,
            firstName: user.firstName,
            lastName: user.lastName,
            avatarUrl: user.avatarUrl,
            bio: user.bio,
            isActive: user.isActive,
            dateJoined: user.dateJoined
        )
    }

    public func update(from user: User) {
        email = user.email
        username = user.username
        firstName = user.firstName
        lastName = user.lastName
        avatarUrl = user.avatarUrl
        bio = user.bio
        isActive = user.isActive
        dateJoined = user.dateJoined
        lastFetchedAt = Date()
    }

    public func toUser() -> User {
        User(
            id: id,
            email: email,
            username: username,
            firstName: firstName,
            lastName: lastName,
            avatarUrl: avatarUrl,
            bio: bio,
            isActive: isActive,
            dateJoined: dateJoined
        )
    }
}
