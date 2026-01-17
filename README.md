# Swift iOS Starter

A modern iOS app template with SwiftUI and auto-generated API client for use with Django backends.

## Features

- **SwiftUI** - Modern declarative UI framework
- **Swift 5.9+** - Latest Swift with async/await
- **URLSession API Client** - Type-safe networking
- **Token Management** - JWT auth with refresh
- **MVVM Architecture** - Clean separation of concerns
- **iOS 17+ / macOS 14+** - Latest platform features

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
│   ├── MyAppApp.swift         # App entry point
│   ├── ContentView.swift      # Root view
│   ├── Views/
│   │   ├── LoginView.swift
│   │   ├── RegisterView.swift
│   │   ├── MainTabView.swift
│   │   ├── DashboardView.swift
│   │   └── ProfileView.swift
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
3. Build and run

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

- Xcode 15+
- iOS 17+ / macOS 14+
- Swift 5.9+

## License

MIT
