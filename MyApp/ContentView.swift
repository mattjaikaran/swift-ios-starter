import SwiftUI
import API

struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var deepLinkHandler: DeepLinkHandler

    @State private var showResetPassword = false
    @State private var showEmailVerification = false
    @State private var deepLinkToken = ""

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
            // Navigate to profile — only meaningful when authenticated
            // For tab-based navigation, the MainTabView would observe this
            deepLinkHandler.clearPendingLink()

        case .dashboard:
            // Navigate to dashboard — only meaningful when authenticated
            deepLinkHandler.clearPendingLink()
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthViewModel())
        .environmentObject(DeepLinkHandler())
}
