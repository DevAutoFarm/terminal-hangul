// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "TerminalHangul",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .executable(name: "TerminalHangul", targets: ["TerminalHangul"])
    ],
    targets: [
        .executableTarget(
            name: "TerminalHangul",
            path: "Sources/TerminalHangul",
            linkerSettings: [
                .linkedFramework("Cocoa"),
                .linkedFramework("InputMethodKit")
            ]
        )
    ]
)
