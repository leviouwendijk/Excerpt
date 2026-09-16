// swift-tools-version: 6.3

import PackageDescription

let package = Package(
    name: "Excerpt",
    products: [
        .library(
            name: "Excerpt",
            targets: [
                "Excerpt",
            ]
        ),
        .library(
            name: "ExcerptPresentation",
            targets: [
                "ExcerptPresentation",
            ]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/leviouwendijk/Position.git",
            branch: "master"
        ),
    ],
    targets: [
        .target(
            name: "Excerpt",
            dependencies: [
                .product(
                    name: "Position",
                    package: "Position"
                ),
            ]
        ),
        .target(
            name: "ExcerptPresentation"
        ),
        .executableTarget(
            name: "ExcerptTests",
            dependencies: [
                "Excerpt",
                "ExcerptPresentation",
                .product(
                    name: "Position",
                    package: "Position"
                ),
            ]
        ),
    ],
    swiftLanguageModes: [
        .v6,
    ]
)
