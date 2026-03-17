// swift-tools-version:6.2
import PackageDescription

let package = Package(
    name: "MyApp",
    platforms: [
        .iOS(.v26),
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
