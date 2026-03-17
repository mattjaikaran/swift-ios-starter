import SwiftUI
import SwiftData
import API

@main
struct MyAppApp: App {
    @StateObject private var authViewModel = AuthViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authViewModel)
                .modelContainer(CacheService.shared.container)
                #if os(macOS)
                .frame(minWidth: 800, minHeight: 500)
                #endif
        }
        #if os(macOS)
        .defaultSize(width: 1000, height: 700)

        Settings {
            SettingsView()
                .environmentObject(authViewModel)
        }
        #endif
    }
}
