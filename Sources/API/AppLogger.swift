import os

/// Structured logging wrapper using Apple's os.Logger
public enum AppLogger {
    // Subsystem matches bundle ID pattern
    private static let subsystem = "com.myapp"

    // Category-based loggers
    public static let api = Logger(subsystem: subsystem, category: "API")
    public static let auth = Logger(subsystem: subsystem, category: "Auth")
    public static let network = Logger(subsystem: subsystem, category: "Network")
    public static let ui = Logger(subsystem: subsystem, category: "UI")
    public static let general = Logger(subsystem: subsystem, category: "General")

    // MARK: - Convenience Methods

    public static func debug(
        _ message: String,
        category: Logger = general,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        #if DEBUG
        category.debug("[\(function):\(line)] \(message)")
        #endif
    }

    public static func info(_ message: String, category: Logger = general) {
        category.info("\(message)")
    }

    public static func warning(_ message: String, category: Logger = general) {
        category.warning("\(message)")
    }

    public static func error(_ message: String, category: Logger = general) {
        category.error("\(message)")
    }

    public static func critical(_ message: String, category: Logger = general) {
        category.critical("\(message)")
    }
}
