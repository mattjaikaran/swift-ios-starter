import SwiftUI
import API

struct CardModifier: ViewModifier {
    var cornerRadius: CGFloat = AppTheme.CornerRadius.md
    var shadow: Bool = false

    func body(content: Content) -> some View {
        content
            .padding()
            .background(AppTheme.Colors.surface)
            .cornerRadius(cornerRadius)
            .shadow(
                color: shadow ? Color.black.opacity(0.1) : .clear,
                radius: shadow ? 4 : 0,
                y: shadow ? 2 : 0
            )
    }
}

struct PrimaryButtonModifier: ViewModifier {
    var isDisabled: Bool = false

    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity)
            .padding()
            .background(isDisabled ? AppTheme.Colors.primary.opacity(0.5) : AppTheme.Colors.primary)
            .foregroundColor(.white)
            .cornerRadius(AppTheme.CornerRadius.sm)
    }
}

extension View {
    func cardStyle(cornerRadius: CGFloat = AppTheme.CornerRadius.md, shadow: Bool = false) -> some View {
        modifier(CardModifier(cornerRadius: cornerRadius, shadow: shadow))
    }

    func primaryButtonStyle(isDisabled: Bool = false) -> some View {
        modifier(PrimaryButtonModifier(isDisabled: isDisabled))
    }
}
