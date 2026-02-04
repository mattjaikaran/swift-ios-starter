// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "MyApp",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
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
