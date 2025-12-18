// swift-tools-version: 6.0
// Slow Quit Apps - 防止 Cmd+Q 误触的 macOS 工具

import PackageDescription

let package = Package(
    name: "SlowQuitApps",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "SlowQuitApps", targets: ["SlowQuitApps"])
    ],
    targets: [
        .executableTarget(
            name: "SlowQuitApps",
            path: "Sources/SlowQuitApps"
        )
    ]
)
