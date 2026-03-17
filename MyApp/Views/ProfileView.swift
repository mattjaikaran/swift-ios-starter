import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showError = false

    var body: some View {
        NavigationStack {
            List {
                if let user = authViewModel.user {
                    Section {
                        HStack(spacing: 16) {
                            Circle()
                                .fill(Color.accentColor.opacity(0.2))
                                .frame(width: 60, height: 60)
                                .overlay {
                                    Text(user.firstName.prefix(1).uppercased() + user.lastName.prefix(1).uppercased())
                                        .font(.title2)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.accentColor)
                                }

                            VStack(alignment: .leading, spacing: 4) {
                                Text("\(user.firstName) \(user.lastName)")
                                    .font(.headline)
                                Text(user.email)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }

                Section("Account") {
                    NavigationLink {
                        Text("Edit Profile")
                    } label: {
                        Label("Edit Profile", systemImage: "person.circle")
                    }

                    NavigationLink {
                        Text("Change Password")
                    } label: {
                        Label("Change Password", systemImage: "lock")
                    }
                }

                Section("Preferences") {
                    NavigationLink {
                        Text("Notifications")
                    } label: {
                        Label("Notifications", systemImage: "bell")
                    }

                    NavigationLink {
                        Text("Appearance")
                    } label: {
                        Label("Appearance", systemImage: "paintbrush")
                    }
                }

                Section {
                    Button(role: .destructive) {
                        Task {
                            await authViewModel.logout()
                        }
                    } label: {
                        Label("Sign Out", systemImage: "rectangle.portrait.and.arrow.right")
                    }
                }
            }
            .navigationTitle("Profile")
            .alert("Error", isPresented: $showError) {
                Button("OK") { authViewModel.error = nil }
            } message: {
                Text(authViewModel.error ?? "An unknown error occurred.")
            }
            .onChange(of: authViewModel.error) {
                showError = authViewModel.error != nil
            }
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(AuthViewModel())
}
