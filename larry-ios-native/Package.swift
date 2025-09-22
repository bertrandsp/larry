// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Larry",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "Larry",
            targets: ["Larry"]
        ),
    ],
    dependencies: [
        // Networking
        .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.8.0"),
        // Keychain Services
        .package(url: "https://github.com/kishikawakatsumi/KeychainAccess.git", from: "4.2.2"),
        // Google Sign In
        .package(url: "https://github.com/google/GoogleSignIn-iOS", from: "7.0.0")
    ],
    targets: [
        .target(
            name: "Larry",
            dependencies: [
                "Alamofire",
                "KeychainAccess",
                .product(name: "GoogleSignIn", package: "GoogleSignIn-iOS")
            ]
        ),
        .testTarget(
            name: "LarryTests",
            dependencies: ["Larry"]
        ),
    ]
)
