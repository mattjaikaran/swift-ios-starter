import Foundation
import Combine

/// Supported deep link routes
public enum DeepLink: Equatable, Sendable {
    case verifyEmail(token: String)
    case resetPassword(token: String)
    case profile
    case dashboard
}

/// Handles deep link URL parsing and routing
@MainActor
public class DeepLinkHandler: ObservableObject {
    @Published public var pendingDeepLink: DeepLink?

    private static let scheme = "myapp"

    public init() {}

    /// Parse a URL and set the pending deep link
    /// - Returns: `true` if the URL was recognized and handled
    @discardableResult
    public func handle(url: URL) -> Bool {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            return false
        }

        // Support both custom scheme (myapp://) and universal links
        let host: String?
        let path: String

        if components.scheme == Self.scheme {
            // myapp://verify-email?token=xxx — host is the route
            host = components.host
            path = components.path
        } else {
            // Universal link: https://example.com/verify-email?token=xxx
            host = nil
            path = components.path
        }

        let route = host ?? path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        let queryItems = components.queryItems ?? []

        switch route {
        case "verify-email":
            guard let token = queryItems.first(where: { $0.name == "token" })?.value,
                  !token.isEmpty else {
                return false
            }
            pendingDeepLink = .verifyEmail(token: token)
            return true

        case "reset-password":
            guard let token = queryItems.first(where: { $0.name == "token" })?.value,
                  !token.isEmpty else {
                return false
            }
            pendingDeepLink = .resetPassword(token: token)
            return true

        case "profile":
            pendingDeepLink = .profile
            return true

        case "dashboard":
            pendingDeepLink = .dashboard
            return true

        default:
            return false
        }
    }

    /// Clear the pending deep link after it has been handled
    public func clearPendingLink() {
        pendingDeepLink = nil
    }
}
