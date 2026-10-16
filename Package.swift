// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let swiftSettings: [SwiftSetting] = [
    .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
    .enableUpcomingFeature("ExistentialAny"),
    .enableUpcomingFeature("MemberImportVisibility")
]

let package = Package(
    name: "Manuscript",
    products: [
        .library(
            name: "Manuscript",
            targets: [
                "Manuscript"
            ]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/swiftlang/swift-docc-plugin",
            from: "1.5.0"
        )
    ],
    targets: [
        .target(
            name: "Manuscript",
            swiftSettings: swiftSettings
        ),
        .testTarget(
            name: "ManuscriptTests",
            dependencies: [
                "Manuscript"
            ],
            resources: [
                .copy("Resources")
            ],
            swiftSettings: swiftSettings
        )
    ],
    swiftLanguageModes: [.v6]
)
