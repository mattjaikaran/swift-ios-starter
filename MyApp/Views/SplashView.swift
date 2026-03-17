import SwiftUI

struct SplashView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "app.fill")
                .font(.system(size: 80))
                .foregroundColor(.accentColor)

            Text("MyApp")
                .font(.largeTitle)
                .fontWeight(.bold)

            ProgressView()
                .padding(.top, 8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    SplashView()
}
