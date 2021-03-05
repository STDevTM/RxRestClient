// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "RxRestClient",
    platforms: [
        .macOS(.v10_12), .iOS(.v10), .tvOS(.v10)
    ],
    products: [
        .library(
            name: "RxRestClient",
            targets: ["RxRestClient"]),
    ],
    dependencies: [
        .package(url: "https://github.com/ReactiveX/RxSwift.git", .upToNextMajor(from: "6.0.0")),
        .package(url: "https://github.com/RxSwiftCommunity/RxAlamofire.git", .upToNextMajor(from: "6.0.0")),
    ],
    targets: [
        .target(
            name: "RxRestClient",
            dependencies: [
                .product(name: "RxSwift", package: "RxSwift"),
                .product(name: "RxAlamofire", package: "RxAlamofire"),
            ]),
        .testTarget(
            name: "RxRestClientTests",
            dependencies: ["RxRestClient"]),
    ])
