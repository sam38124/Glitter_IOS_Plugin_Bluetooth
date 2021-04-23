// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Glitter_BLE",
    platforms: [
        .iOS(.v11)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "Glitter_BLE",
            targets: ["Glitter_BLE"]),
    ],
    dependencies: [
        .package(url: "https://github.com/sam38124/JzOsBleHelper",from: "1.0.5"),
        .package(url: "https://github.com/sam38124/Glitter_IOS",from: "2.1.8")
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "Glitter_BLE",
            dependencies: ["JzOsBleHelper","Glitter_IOS"]),
        .testTarget(
            name: "Glitter_BLETests",
            dependencies: ["Glitter_BLE"]),
    ]
)
