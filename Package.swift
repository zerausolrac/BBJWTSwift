// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "BBJWTSwift",
    platforms: [
          .macOS(.v10_15), .iOS(.v13)
       ],
    products: [
        .library(
            name: "BBJWTSwift",
            targets: ["BBJWTSwift"]),
    ],
    dependencies: [
    .package(url: "https://github.com/apple/swift-crypto.git", from: "1.0.2"),
    ], 
    targets: [
        .target(
            name: "BBJWTSwift",
            dependencies: [.product(name: "Crypto", package: "swift-crypto")])
        ,
        //.testTarget(name: "BBJWTSwiftTests",dependencies: ["BBJWTSwift"]),
    ]
)
