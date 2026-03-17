import Foundation

/// Protocol for crash reporting services (Sentry, Crashlytics, etc.)
public protocol CrashReporting: Sendable {
    func configure()
    func captureError(_ error: Error, context: [String: String])
    func captureMessage(_ message: String, level: CrashReportLevel)
    func setUser(id: String?, email: String?)
}

/// Severity levels for crash reports
public enum CrashReportLevel: String, Sendable {
    case debug, info, warning, error, fatal
}

/// No-op implementation for development — logs to AppLogger instead of a remote service
public final class NoOpCrashReporter: CrashReporting, Sendable {
    public static let shared = NoOpCrashReporter()

    private init() {}

    public func configure() {
        AppLogger.info("Crash reporter: NoOp (development)", category: AppLogger.general)
    }

    public func captureError(_ error: Error, context: [String: String] = [:]) {
        AppLogger.error("Captured: \(error)", category: AppLogger.general)
    }

    public func captureMessage(_ message: String, level: CrashReportLevel = .info) {
        AppLogger.info("Crash report [\(level.rawValue)]: \(message)", category: AppLogger.general)
    }

    public func setUser(id: String?, email: String?) {
        // No-op in development
    }
}
