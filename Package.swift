// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "AviationMaths",
    platforms: [.iOS(.v13)],
    products: [
        .library(
            name: "AviationMaths",
            targets: ["AviationMaths"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/florianreinhart/Geodesy", .upToNextMajor(from: "0.2.2")),
        .package(url: "https://github.com/ngageoint/mgrs-ios.git", from: "2.0.0")
    ],
    targets: [
        .target(
            name: "AviationMaths",
            dependencies: [
               .product(name: "Geodesy", package: "Geodesy"),
               .product(name: "MGRS", package: "mgrs-ios")
           ]
        ),
        .testTarget(
            name: "AviationMathsTests",
            dependencies: ["AviationMaths"]
        )
    ]
)
