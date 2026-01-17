// swift-tools-version:6.0
import PackageDescription

let package = Package(
    name: "MyApp",
    platforms: [
        .iOS(.v18),  // Targeting iOS 18+ (update to v26 when available)
        .macOS(.v15)
    ],
    products: [
        .library(name: "API", targets: ["API"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "API",
            dependencies: [],
            path: "Sources/API"
        ),
        .testTarget(
            name: "APITests",
            dependencies: ["API"],
            path: "Tests/APITests"
        ),
    ]
)
