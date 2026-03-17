import SwiftUI
import API

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var showRegister = false
    @State private var showError = false

    var body: some View {
        NavigationStack {
            VStack(spacing: AppTheme.Spacing.lg) {
                Spacer()

                VStack(spacing: AppTheme.Spacing.sm) {
                    Image(systemName: "app.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.accentColor)

                    Text("MyApp")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                }

                Spacer()

                VStack(spacing: AppTheme.Spacing.md) {
                    TextField("Email", text: $email)
                        .textFieldStyle(.roundedBorder)
                        .textContentType(.emailAddress)
                        #if os(iOS)
                        .textInputAutocapitalization(.never)
                        #endif
                        .autocorrectionDisabled()

                    SecureField("Password", text: $password)
                        .textFieldStyle(.roundedBorder)
                        .textContentType(.password)

                    Button {
                        Task {
                            await authViewModel.login(email: email, password: password)
                            if authViewModel.error != nil {
                                showError = true
                            }
                        }
                    } label: {
                        if authViewModel.isLoading {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                        } else {
                            Text("Sign In")
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(email.isEmpty || password.isEmpty || authViewModel.isLoading)
                }
                .padding(.horizontal)
                .frame(maxWidth: 400)

                if authViewModel.isBiometricAvailable && authViewModel.biometricEnabled {
                    Button {
                        Task {
                            let success = await authViewModel.authenticateWithBiometrics()
                            if success {
                                await authViewModel.checkAuth()
                            }
                        }
                    } label: {
                        Label(
                            "Sign in with \(authViewModel.biometricName)",
                            systemImage: authViewModel.biometricName == "Face ID" ? "faceid" : "touchid"
                        )
                    }
                    .padding(.top, AppTheme.Spacing.xs)
                }

                Button("Don't have an account? Sign Up") {
                    showRegister = true
                }
                .font(.footnote)

                Spacer()
            }
            .navigationDestination(isPresented: $showRegister) {
                RegisterView()
            }
            .alert("Sign In Failed", isPresented: $showError) {
                Button("OK") { authViewModel.error = nil }
            } message: {
                Text(authViewModel.error ?? "An unknown error occurred.")
            }
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthViewModel())
}
