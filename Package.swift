// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "vapor-route",
    platforms: [
        .macOS(.v10_15)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "VaporRoute",
            targets: ["VaporRoute"])
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/leaf.git", from: "4.2.4"),
        .package(url: "https://github.com/vapor/vapor.git", from: "4.89.0"),

        .package(name: "vapor-utils", path: "../vapor-utils"),
    ],
    targets: [
        .target(
            name: "VaporRoute",
            dependencies: [
                .product(name: "Leaf", package: "leaf"),
                .product(name: "Vapor", package: "vapor"),
                
                .product(name: "VaporUtils", package: "vapor-utils"),
            ]
        ),
        .testTarget(name: "VaporRouteTests", dependencies: [
            .target(name: "VaporRoute"),

            .product(name: "XCTVapor", package: "vapor"),

            .product(name: "Vapor", package: "vapor"),
            .product(name: "Leaf", package: "leaf"),
        ])
    ]
)
