import SwiftUI
import API

struct EmailVerificationView: View {
    let token: String
    let onDismiss: () -> Void

    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var isVerifying = true
    @State private var successMessage: String?
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()

                if isVerifying {
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.5)

                        Text("Verifying your email...")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                } else if let successMessage {
                    VStack(spacing: 16) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.green)

                        Text("Email Verified")
                            .font(.title)
                            .fontWeight(.bold)

                        Text(successMessage)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)

                        Text("Redirecting to login...")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                } else if let errorMessage {
                    VStack(spacing: 16) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.red)

                        Text("Verification Failed")
                            .font(.title)
                            .fontWeight(.bold)

                        Text(errorMessage)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)

                        Button("Dismiss", action: onDismiss)
                            .buttonStyle(.borderedProminent)
                    }
                }

                Spacer()
            }
            .padding()
            .navigationTitle("Email Verification")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: onDismiss)
                }
            }
            .task {
                await verifyEmail()
            }
        }
    }

    private func verifyEmail() async {
        isVerifying = true

        do {
            let client = APIClient(baseURL: authViewModel.environment.baseURL)
            let authService = AuthService(client: client)
            let response = try await authService.verifyEmail(token: token)
            isVerifying = false
            successMessage = response.message

            // Auto-redirect to login after success
            try? await Task.sleep(for: .seconds(2))
            onDismiss()
        } catch let apiError as APIError {
            isVerifying = false
            errorMessage = apiError.localizedDescription
        } catch {
            isVerifying = false
            errorMessage = error.localizedDescription
        }
    }
}

#Preview {
    EmailVerificationView(token: "preview-token", onDismiss: {})
        .environmentObject(AuthViewModel())
}
