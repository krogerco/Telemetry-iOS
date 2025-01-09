// swift-tools-version: 6.0

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
        .package(url: "https://github.com/krogerco/Gauntlet-iOS.git", from: "1.0.0")
    ],
    targets: [
        .target(
            name: "Telemetry"
        ),
        .testTarget(
            name: "TelemetryTests",
            dependencies: [
                "Telemetry",
                .product(name: "Gauntlet", package: "Gauntlet-iOS")
            ]
        )
    ]
)
