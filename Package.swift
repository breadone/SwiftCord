// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftCord",
    platforms: [
        .macOS(.v12 )
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "SwiftCord",
            targets: ["SwiftCord"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(name: "Starscream", url: "https://github.com/daltoniam/Starscream", .upToNextMajor(from: .init(4, 0, 0))),
        .package(url: "https://github.com/SwiftyJSON/SwiftyJSON.git", from: "4.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "SwiftCord",
            dependencies: ["Starscream", "SwiftyJSON"]),
        .testTarget(
            name: "SwiftCordTests",
            dependencies: ["SwiftCord"]),
    ]
)
