// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "terminalHangul",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .executable(name: "terminalHangul", targets: ["terminalHangul"])
    ],
    targets: [
        .executableTarget(
            name: "terminalHangul",
            path: "Sources/terminalHangul",
            linkerSettings: [
                .linkedFramework("Cocoa"),
                .linkedFramework("InputMethodKit")
            ]
        )
    ]
)
