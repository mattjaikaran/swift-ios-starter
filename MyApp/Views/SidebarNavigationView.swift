import SwiftUI

#if os(macOS)
enum SidebarDestination: String, CaseIterable, Identifiable {
    case dashboard = "Dashboard"
    case profile = "Profile"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .dashboard: "house"
        case .profile: "person"
        }
    }
}

struct SidebarNavigationView: View {
    @State private var selection: SidebarDestination? = .dashboard

    var body: some View {
        NavigationSplitView {
            List(SidebarDestination.allCases, selection: $selection) { item in
                Label(item.rawValue, systemImage: item.icon)
            }
            .navigationSplitViewColumnWidth(min: 180, ideal: 220)
        } detail: {
            switch selection {
            case .dashboard:
                DashboardView()
            case .profile:
                ProfileView()
            case nil:
                Text("Select an item")
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    SidebarNavigationView()
        .environmentObject(AuthViewModel())
}
#endif
