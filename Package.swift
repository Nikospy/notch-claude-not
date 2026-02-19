// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "NotchDrop",
    platforms: [.macOS(.v13)],
    products: [
        .executable(name: "NotchDropApp", targets: ["NotchDropApp"]),
        .executable(name: "notchdrop", targets: ["NotchDropCLI"]),
    ],
    targets: [
        .executableTarget(
            name: "NotchDropApp",
            dependencies: [],
            path: "NotchDrop/Sources",
            resources: [
                .copy("../Resources/Sprites"),
            ]
        ),
        .executableTarget(
            name: "NotchDropCLI",
            dependencies: [],
            path: "CLI/Sources"
        ),
    ]
)
