import SwiftUI
import API

struct ResetPasswordView: View {
    let token: String
    let onDismiss: () -> Void

    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var isLoading = false
    @State private var successMessage: String?
    @State private var errorMessage: String?

    private var passwordsMatch: Bool {
        !newPassword.isEmpty && newPassword == confirmPassword
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()

                VStack(spacing: 8) {
                    Image(systemName: "key.fill")
                        .font(.system(size: 48))
                        .foregroundColor(.accentColor)

                    Text("Reset Password")
                        .font(.title)
                        .fontWeight(.bold)

                    Text("Enter your new password below.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                if let successMessage {
                    Label(successMessage, systemImage: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .padding()
                } else {
                    VStack(spacing: 16) {
                        SecureField("New Password", text: $newPassword)
                            .textFieldStyle(.roundedBorder)
                            .textContentType(.newPassword)

                        SecureField("Confirm Password", text: $confirmPassword)
                            .textFieldStyle(.roundedBorder)
                            .textContentType(.newPassword)

                        if !confirmPassword.isEmpty && !passwordsMatch {
                            Text("Passwords do not match")
                                .font(.caption)
                                .foregroundColor(.red)
                        }

                        Button {
                            Task { await resetPassword() }
                        } label: {
                            if isLoading {
                                ProgressView()
                                    .frame(maxWidth: .infinity)
                            } else {
                                Text("Reset Password")
                                    .frame(maxWidth: .infinity)
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(!passwordsMatch || isLoading)
                    }
                    .padding(.horizontal)
                    .frame(maxWidth: 400)
                }

                Spacer()
            }
            .navigationTitle("Reset Password")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: onDismiss)
                }
            }
            .alert("Error", isPresented: .init(
                get: { errorMessage != nil },
                set: { if !$0 { errorMessage = nil } }
            )) {
                Button("OK") { errorMessage = nil }
            } message: {
                Text(errorMessage ?? "An unknown error occurred.")
            }
        }
    }

    private func resetPassword() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let client = APIClient(baseURL: authViewModel.environment.baseURL)
            let authService = AuthService(client: client)
            let response = try await authService.resetPassword(token: token, newPassword: newPassword)
            successMessage = response.message

            // Auto-dismiss after success
            try? await Task.sleep(for: .seconds(2))
            onDismiss()
        } catch let apiError as APIError {
            errorMessage = apiError.localizedDescription
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

#Preview {
    ResetPasswordView(token: "preview-token", onDismiss: {})
        .environmentObject(AuthViewModel())
}
