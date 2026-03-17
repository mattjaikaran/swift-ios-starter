import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        Group {
            if authViewModel.isCheckingAuth {
                SplashView()
            } else if authViewModel.isAuthenticated {
                #if os(macOS)
                SidebarNavigationView()
                #else
                MainTabView()
                #endif
            } else {
                LoginView()
            }
        }
        .task {
            await authViewModel.checkAuth()
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthViewModel())
}
