// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "Virtusize",
    defaultLocalization: "en",
    platforms: [.iOS(.v13)],
    products: [
        .library(
            name: "Virtusize",
            targets: ["Virtusize"]
        ),
        .library(
            name: "VirtusizeAuth",
            targets: ["VirtusizeAuth"]
        ),
        .library(
            name: "VirtusizeCore",
            targets: ["VirtusizeCore"]
        )
    ],

    targets: [
        .target(
            name: "Virtusize",
            dependencies: ["VirtusizeCore", "VirtusizeAuth"],
            path: "Virtusize/Sources",
            exclude: ["Info.plist"],
            resources: [.process("Resources")]
        ),
        .target(
            name: "VirtusizeAuth",
            dependencies: ["VirtusizeCore"],
            path: "VirtusizeAuth/Sources",
            exclude: ["Info.plist"],
            resources: [.process("Resources")]
        ),
        .target(
            name: "VirtusizeCore",
            dependencies: [],
            path: "VirtusizeCore/Sources",
            exclude: ["Info.plist"],
            resources: [.process("Resources")]
        )
    ]
)
