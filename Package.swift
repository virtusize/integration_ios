// swift-tools-version:5.3
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
            name: "VirtusizeCore",
            targets: ["VirtusizeCore"]
        )
	],
	dependencies: [],
	targets: [
		.target(
			name: "Virtusize",
			dependencies: ["VirtusizeCore", "VirtusizeAuth"],
			path: "Virtusize/Sources",
			exclude: ["Info.plist"],
			resources: [.process("Resources")]
		),
		.target(
			name: "VirtusizeCore",
			dependencies: [],
			path: "VirtusizeCore/Sources",
			exclude: ["Info.plist"],
			resources: [.process("Resources")]
		),
        .binaryTarget(
            name: "VirtusizeAuth",
            path: "Frameworks/VirtusizeAuth.xcframework"
        )
	]
)
