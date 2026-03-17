import SwiftUI
import API

struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var networkMonitor = NetworkMonitor.shared

    var body: some View {
        ZStack(alignment: .top) {
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

            if !networkMonitor.isConnected {
                OfflineBannerView()
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.3), value: networkMonitor.isConnected)
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthViewModel())
}
