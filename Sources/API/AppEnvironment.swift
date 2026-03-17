import Foundation

/// App environment configuration for switching between dev/staging/prod API endpoints
public enum AppEnvironment: String, CaseIterable, Sendable {
    case development
    case staging
    case production

    public var baseURL: URL {
        switch self {
        case .development:
            URL(string: "http://localhost:8000/api")!
        case .staging:
            URL(string: "https://staging-api.example.com/api")!
        case .production:
            URL(string: "https://api.example.com/api")!
        }
    }

    public var name: String { rawValue.capitalized }

    /// Resolve the current environment from:
    /// 1. APP_ENVIRONMENT env var (for CI/testing)
    /// 2. Info.plist AppEnvironment key (set via Xcode scheme)
    /// 3. Falls back to .development in DEBUG, .production in release
    public static var current: AppEnvironment {
        // Check environment variable first
        if let envVar = ProcessInfo.processInfo.environment["APP_ENVIRONMENT"],
           let env = AppEnvironment(rawValue: envVar.lowercased()) {
            return env
        }

        // Check Info.plist
        if let plistValue = Bundle.main.infoDictionary?["AppEnvironment"] as? String,
           let env = AppEnvironment(rawValue: plistValue.lowercased()) {
            return env
        }

        // Default based on build config
        #if DEBUG
        return .development
        #else
        return .production
        #endif
    }
}
