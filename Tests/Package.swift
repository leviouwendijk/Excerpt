// swift-tools-version: 6.3

import PackageDescription

let package = Package(
    name: "ExcerptTests",
    products: [
    ],
    dependencies: [
        .package(
            url: "https://github.com/leviouwendijk/Position.git",
            branch: "master"
        ),
        .package(path: ".."),
    ],
    targets: [
        .executableTarget(
            name: "ExcerptTests",
            dependencies: [
                .product(name: "Excerpt", package: "Excerpt"),
                .product(name: "ExcerptPresentation", package: "Excerpt"),
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
