// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SketchProto",
    platforms: [.iOS(.v14), .macOS(.v10_15),], // macOS is just to satisfy the compiler
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(name: "SketchStatusView", targets: ["SketchStatusView"]),
        .library(name: "Style", targets: ["Style"]),
        .library(name: "Sketcher", targets: ["Sketcher"]),
        .library(name: "NodeView", targets: ["NodeView"]),
        .library(name: "Models", targets: ["Models"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/SnapKit/SnapKit.git", .upToNextMajor(from: "5.0.1"))
    ],
    targets: [
        .target(
            name: "SketchStatusView",
            dependencies: [.target(name: "Style"),]),
        .target(
            name: "NodeView",
            dependencies: [.target(name: "Style"), .target(name: "Models"), "SnapKit"]),
        .target(
            name: "Sketcher",
            dependencies: [.target(name: "Style"), .target(name: "Models"), .target(name: "NodeView")]),
        .target(
            name: "Style",
            dependencies: []),
        .target(
            name: "Models",
            dependencies: []),

        .testTarget(name: "SketcherTests", dependencies: ["Sketcher"])
    ]
)
