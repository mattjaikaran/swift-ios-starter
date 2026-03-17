import SwiftUI

struct RegisterView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss
    @State private var email = ""
    @State private var username = ""
    @State private var password = ""
    @State private var confirmPassword = ""

    var isFormValid: Bool {
        !email.isEmpty && !username.isEmpty && !password.isEmpty && password == confirmPassword
    }

    var body: some View {
        VStack(spacing: 24) {
            Text("Create Account")
                .font(.largeTitle)
                .fontWeight(.bold)

            VStack(spacing: 16) {
                TextField("Email", text: $email)
                    .textFieldStyle(.roundedBorder)
                    .textContentType(.emailAddress)
                    #if os(iOS)
                    .textInputAutocapitalization(.never)
                    #endif

                TextField("Username", text: $username)
                    .textFieldStyle(.roundedBorder)
                    .textContentType(.username)
                    #if os(iOS)
                    .textInputAutocapitalization(.never)
                    #endif

                SecureField("Password", text: $password)
                    .textFieldStyle(.roundedBorder)
                    .textContentType(.newPassword)

                SecureField("Confirm Password", text: $confirmPassword)
                    .textFieldStyle(.roundedBorder)
                    .textContentType(.newPassword)

                if password != confirmPassword && !confirmPassword.isEmpty {
                    Text("Passwords don't match")
                        .foregroundColor(.red)
                        .font(.caption)
                }

                if let error = authViewModel.error {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.caption)
                }

                Button {
                    Task {
                        await authViewModel.register(
                            email: email,
                            username: username,
                            password: password
                        )
                    }
                } label: {
                    if authViewModel.isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                    } else {
                        Text("Create Account")
                            .frame(maxWidth: .infinity)
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(!isFormValid || authViewModel.isLoading)
            }
            .padding(.horizontal)
            .frame(maxWidth: 400)

            Spacer()
        }
        .padding(.top, 40)
    }
}

#Preview {
    RegisterView()
        .environmentObject(AuthViewModel())
}
