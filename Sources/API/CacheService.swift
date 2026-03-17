import Foundation
import SwiftData

@MainActor
public final class CacheService {
    private let modelContainer: ModelContainer
    private let modelContext: ModelContext

    /// Cache duration in seconds (default 5 minutes)
    public var cacheDuration: TimeInterval = 300

    public static let shared: CacheService = {
        do {
            return try CacheService()
        } catch {
            fatalError("Failed to initialize CacheService: \(error)")
        }
    }()

    public init() throws {
        let schema = Schema([CachedUser.self, CachedResponse.self])
        let config = ModelConfiguration("MyAppCache", isStoredInMemoryOnly: false)
        self.modelContainer = try ModelContainer(for: schema, configurations: [config])
        self.modelContext = modelContainer.mainContext
    }

    // MARK: - Model Container (for SwiftUI .modelContainer modifier)

    public var container: ModelContainer { modelContainer }

    // MARK: - User Caching

    public func cacheUser(_ user: User) {
        let descriptor = FetchDescriptor<CachedUser>(
            predicate: #Predicate { $0.id == user.id }
        )

        if let existing = try? modelContext.fetch(descriptor).first {
            existing.update(from: user)
        } else {
            let cached = CachedUser(from: user)
            modelContext.insert(cached)
        }

        try? modelContext.save()
    }

    public func getCachedUser() -> User? {
        let descriptor = FetchDescriptor<CachedUser>(
            sortBy: [SortDescriptor(\.lastFetchedAt, order: .reverse)]
        )

        guard let cached = try? modelContext.fetch(descriptor).first else { return nil }

        let elapsed = Date().timeIntervalSince(cached.lastFetchedAt)
        guard elapsed < cacheDuration else {
            return nil
        }

        return cached.toUser()
    }

    public func clearUserCache() {
        let descriptor = FetchDescriptor<CachedUser>()
        if let all = try? modelContext.fetch(descriptor) {
            for item in all {
                modelContext.delete(item)
            }
        }
        try? modelContext.save()
    }

    // MARK: - Generic Response Caching

    public func cacheResponse(for key: String, data: Data) {
        let expiresAt = Date().addingTimeInterval(cacheDuration)

        let descriptor = FetchDescriptor<CachedResponse>(
            predicate: #Predicate { $0.key == key }
        )

        if let existing = try? modelContext.fetch(descriptor).first {
            existing.data = data
            existing.cachedAt = Date()
            existing.expiresAt = expiresAt
        } else {
            let cached = CachedResponse(key: key, data: data, expiresAt: expiresAt)
            modelContext.insert(cached)
        }

        try? modelContext.save()
    }

    public func getCachedResponse(for key: String) -> Data? {
        let descriptor = FetchDescriptor<CachedResponse>(
            predicate: #Predicate { $0.key == key }
        )

        guard let cached = try? modelContext.fetch(descriptor).first,
              !cached.isExpired else {
            return nil
        }

        return cached.data
    }

    public func isCacheValid(for key: String) -> Bool {
        let descriptor = FetchDescriptor<CachedResponse>(
            predicate: #Predicate { $0.key == key }
        )

        guard let cached = try? modelContext.fetch(descriptor).first else {
            return false
        }

        return !cached.isExpired
    }

    // MARK: - Clear All

    public func clearAll() {
        clearUserCache()

        let descriptor = FetchDescriptor<CachedResponse>()
        if let all = try? modelContext.fetch(descriptor) {
            for item in all {
                modelContext.delete(item)
            }
        }
        try? modelContext.save()
    }
}
