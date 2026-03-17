# Swift Multiplatform Starter

A modern iOS + macOS app template with SwiftUI and auto-generated API client for use with Django backends.

## Features

- **SwiftUI** - Modern declarative UI framework
- **Swift 6.0** - Latest Swift with async/await and strict concurrency
- **Multiplatform** - Native iOS and macOS from one codebase
- **URLSession API Client** - Type-safe networking
- **Token Management** - JWT auth with refresh
- **MVVM Architecture** - Clean separation of concerns
- **Platform-adaptive navigation** - TabView on iOS, NavigationSplitView on macOS
- **macOS Settings** - Native Preferences window with appearance & account tabs

## Platform Targets

| Platform | Minimum | Target Device |
|----------|---------|---------------|
| iOS | 26.0 | iPhone 17 Pro |
| macOS | 15.0 | macOS Sequoia |

## Project Structure

```
swift-ios-starter/
├── Package.swift              # Swift Package Manager config
├── Sources/
│   └── API/
│       ├── APIClient.swift    # HTTP client with auth
│       ├── Models.swift       # Codable models
│       └── AuthService.swift  # Auth logic
├── MyApp/
│   ├── MyAppApp.swift         # App entry point (multiplatform)
│   ├── ContentView.swift      # Root view (platform-adaptive)
│   ├── Views/
│   │   ├── LoginView.swift              # Auth (iOS + macOS)
│   │   ├── RegisterView.swift           # Auth (iOS + macOS)
│   │   ├── MainTabView.swift            # iOS tab navigation
│   │   ├── SidebarNavigationView.swift  # macOS sidebar navigation
│   │   ├── DashboardView.swift          # Shared dashboard
│   │   ├── ProfileView.swift            # Shared profile
│   │   └── SettingsView.swift           # macOS Settings window
│   └── ViewModels/
│       └── AuthViewModel.swift
└── Tests/
```

## Quick Start

1. Open the project in Xcode
2. Update the API base URL in `AuthViewModel.swift`:
   ```swift
   let baseURL = URL(string: "https://your-api.com/api")!
   ```
3. Select your target:
   - **iOS**: Choose iPhone 17 Pro simulator
   - **macOS**: Choose "My Mac"
4. Build and run

## Platform Differences

### iOS
- Tab-based navigation (Home, Profile)
- Standard iOS form styling
- Mobile-optimized layouts

### macOS
- Sidebar navigation with NavigationSplitView
- Native Settings window (Cmd+,) with General & Account tabs
- Resizable window with min 800x500, default 1000x700
- Wider grid layouts for dashboard cards

## API Client Usage

```swift
// Initialize
let client = APIClient(baseURL: URL(string: "https://api.example.com")!)

// GET request
let users: [User] = try await client.get("/users")

// POST request
let newUser: User = try await client.post("/users", body: CreateUserRequest(...))

// With authentication
await client.setTokens(access: "token", refresh: "refresh")
let me: User = try await client.get("/auth/me")  // Adds Bearer token
```

## Models

The `Models.swift` file contains Codable structs matching your backend:

- `User` - User profile
- `LoginRequest` / `TokenResponse` - Auth
- `Organization`, `Team`, `Member` - B2B models

## Generating Types from Backend

Use django-matt's sync_types command:

```bash
cd backend
python manage.py sync_types --target swift --output ../ios/Sources/API
```

## Backend Integration

Works with:
- [django-api-starter](https://github.com/yourusername/django-api-starter)
- [django-api-b2b](https://github.com/yourusername/django-api-b2b)

## Requirements

- Xcode 26+
- iOS 26+ / macOS 15+
- Swift 6.0+

## License

MIT
