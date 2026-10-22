// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "AviationMaths",
    platforms: [.iOS(.v13), .macOS(.v11)],
    products: [
        .library(
            name: "AviationMaths",
            targets: ["AviationMaths"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/Haelix-Code/VincentySwift", .upToNextMinor(from: "0.0.1"))
    ],
    targets: [
        .target(
            name: "AviationMaths",
            dependencies: [
               .product(name: "Vincenty", package: "VincentySwift")
           ]
        ),
        .testTarget(
            name: "AviationMathsTests",
            dependencies: [
                "AviationMaths",
                .product(name: "Vincenty", package: "VincentySwift")
            ]
        )
    ]
)
