import SwiftUI

public enum AppTheme {
    // MARK: - Colors
    public enum Colors {
        public static let primary = Color.accentColor
        public static let secondary = Color.secondary
        public static let error = Color.red
        public static let success = Color.green
        public static let warning = Color.orange
        public static let textPrimary = Color.primary
        public static let textSecondary = Color.secondary

        #if os(iOS)
        public static let background = Color(.systemBackground)
        public static let surface = Color(.secondarySystemBackground)
        #else
        public static let background = Color(.windowBackgroundColor)
        public static let surface = Color(.controlBackgroundColor)
        #endif
    }

    // MARK: - Typography
    public enum Typography {
        public static let largeTitle = Font.largeTitle.weight(.bold)
        public static let title = Font.title.weight(.semibold)
        public static let title2 = Font.title2.weight(.semibold)
        public static let headline = Font.headline
        public static let body = Font.body
        public static let callout = Font.callout
        public static let caption = Font.caption
        public static let footnote = Font.footnote
    }

    // MARK: - Spacing
    public enum Spacing {
        public static let xxs: CGFloat = 2
        public static let xs: CGFloat = 4
        public static let sm: CGFloat = 8
        public static let md: CGFloat = 16
        public static let lg: CGFloat = 24
        public static let xl: CGFloat = 32
        public static let xxl: CGFloat = 48
    }

    // MARK: - Corner Radius
    public enum CornerRadius {
        public static let sm: CGFloat = 8
        public static let md: CGFloat = 12
        public static let lg: CGFloat = 16
        public static let full: CGFloat = 999
    }
}
