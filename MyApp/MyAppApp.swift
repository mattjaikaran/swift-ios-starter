import SwiftUI
import SwiftData
import API

@main
struct MyAppApp: App {
    @StateObject private var authViewModel = AuthViewModel()
    @StateObject private var deepLinkHandler = DeepLinkHandler()
    @AppStorage("appearance") private var appearance: String = "system"

    var colorScheme: ColorScheme? {
        switch appearance {
        case "light": return .light
        case "dark": return .dark
        default: return nil
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authViewModel)
                .environmentObject(deepLinkHandler)
                .onOpenURL { url in
                    deepLinkHandler.handle(url: url)
                }
                .preferredColorScheme(colorScheme)
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
