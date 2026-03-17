import SwiftUI
import API

struct SplashView: View {
    var body: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            Image(systemName: "app.fill")
                .font(.system(size: 80))
                .foregroundColor(.accentColor)

            Text("MyApp")
                .font(.largeTitle)
                .fontWeight(.bold)

            ProgressView()
                .padding(.top, AppTheme.Spacing.sm)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    SplashView()
}
