import SwiftUI
import API

struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var deepLinkHandler: DeepLinkHandler
    @StateObject private var networkMonitor = NetworkMonitor.shared

    @State private var showResetPassword = false
    @State private var showEmailVerification = false
    @State private var deepLinkToken = ""

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
        .onChange(of: deepLinkHandler.pendingDeepLink) { _, newLink in
            handleDeepLink(newLink)
        }
        .sheet(isPresented: $showResetPassword) {
            ResetPasswordView(token: deepLinkToken) {
                showResetPassword = false
                deepLinkHandler.clearPendingLink()
            }
            .environmentObject(authViewModel)
        }
        .sheet(isPresented: $showEmailVerification) {
            EmailVerificationView(token: deepLinkToken) {
                showEmailVerification = false
                deepLinkHandler.clearPendingLink()
            }
            .environmentObject(authViewModel)
        }
    }

    private func handleDeepLink(_ link: DeepLink?) {
        guard let link else { return }

        switch link {
        case .verifyEmail(let token):
            deepLinkToken = token
            showEmailVerification = true

        case .resetPassword(let token):
            deepLinkToken = token
            showResetPassword = true

        case .profile:
            deepLinkHandler.clearPendingLink()

        case .dashboard:
            deepLinkHandler.clearPendingLink()
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthViewModel())
        .environmentObject(DeepLinkHandler())
}
