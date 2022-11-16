// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "Telemetry",
    platforms: [
        .iOS(.v14),
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "Telemetry",
            targets: ["Telemetry"]
        )
    ],
    dependencies: [
        .package(
            name: "Gauntlet",
            url: "https://github.com/krogerco/Gauntlet-iOS.git",
            .upToNextMajor(from: Version(1, 0, 0))
        )
    ],
    targets: [
        .target(
            name: "Telemetry"
        ),
        .testTarget(
            name: "TelemetryTests",
            dependencies: ["Telemetry", "Gauntlet"]
        )
    ]
)
