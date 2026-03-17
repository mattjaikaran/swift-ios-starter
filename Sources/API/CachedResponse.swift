import Foundation
import SwiftData

@Model
public final class CachedResponse {
    @Attribute(.unique) public var key: String
    public var data: Data
    public var cachedAt: Date
    public var expiresAt: Date

    public init(key: String, data: Data, cachedAt: Date = Date(), expiresAt: Date) {
        self.key = key
        self.data = data
        self.cachedAt = cachedAt
        self.expiresAt = expiresAt
    }

    public var isExpired: Bool {
        Date() > expiresAt
    }
}
