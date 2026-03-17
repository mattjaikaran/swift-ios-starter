import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    private var gridColumns: [GridItem] {
        #if os(macOS)
        [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
        #else
        [GridItem(.flexible()), GridItem(.flexible())]
        #endif
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    if let user = authViewModel.user {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Welcome back,")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            Text(user.firstName.isEmpty ? user.username : user.firstName)
                                .font(.largeTitle)
                                .fontWeight(.bold)
                        }
                    }

                    LazyVGrid(columns: gridColumns, spacing: 16) {
                        StatCard(title: "Status", value: "Active", icon: "checkmark.circle.fill", color: .green)
                        StatCard(title: "Member Since", value: formattedDate, icon: "calendar", color: .blue)
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Quick Actions")
                            .font(.headline)

                        HStack(spacing: 12) {
                            QuickActionButton(title: "Settings", icon: "gear") {}
                            QuickActionButton(title: "Help", icon: "questionmark.circle") {}
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Dashboard")
        }
    }

    var formattedDate: String {
        guard let user = authViewModel.user else { return "N/A" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: user.dateJoined)
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Spacer()
            }
            Text(value)
                .font(.title2)
                .fontWeight(.semibold)
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(.fill.tertiary)
        .cornerRadius(12)
    }
}

struct QuickActionButton: View {
    let title: String
    let icon: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                Text(title)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(.fill.tertiary)
            .cornerRadius(10)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    DashboardView()
        .environmentObject(AuthViewModel())
}
