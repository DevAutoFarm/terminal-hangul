// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "terminalHangul",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .executable(
            name: "terminalHangul",
            targets: ["terminalHangul"]
        )
    ],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "terminalHangul",
            dependencies: [],
            path: "Sources/terminalHangul"
        )
    ]
)
