import SwiftUI

#if os(macOS)
struct SettingsView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        TabView {
            GeneralSettingsView()
                .tabItem {
                    Label("General", systemImage: "gear")
                }

            AccountSettingsView()
                .tabItem {
                    Label("Account", systemImage: "person.circle")
                }
        }
        .frame(width: 450, height: 300)
    }
}

struct GeneralSettingsView: View {
    @AppStorage("appearance") private var appearance: String = "system"

    var body: some View {
        Form {
            Picker("Appearance", selection: $appearance) {
                Text("System").tag("system")
                Text("Light").tag("light")
                Text("Dark").tag("dark")
            }
        }
        .padding()
    }
}

struct AccountSettingsView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        Form {
            if let user = authViewModel.user {
                LabeledContent("Email", value: user.email)
                LabeledContent("Username", value: user.username)
            }

            Button("Sign Out", role: .destructive) {
                Task {
                    await authViewModel.logout()
                }
            }
        }
        .padding()
    }
}

#Preview {
    SettingsView()
        .environmentObject(AuthViewModel())
}
#endif
