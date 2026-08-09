// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "HomelabMenuBar",
    platforms: [.macOS(.v15)],
    targets: [
        .target(
            name: "HomelabMenuBarCore",
            swiftSettings: [.swiftLanguageMode(.v6)]
        ),
        .executableTarget(
            name: "HomelabMenuBar",
            dependencies: ["HomelabMenuBarCore"],
            swiftSettings: [.swiftLanguageMode(.v6)]
        ),
        .testTarget(
            name: "HomelabMenuBarCoreTests",
            dependencies: ["HomelabMenuBarCore"],
            swiftSettings: [.swiftLanguageMode(.v6)]
        ),
    ]
)
