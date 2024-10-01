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
	dependencies: [
        .package(url: "https://github.com/virtusize/virtusize_auth_ios.git", .branch("hotfix/1.1.3"))
    ],
	targets: [
		.target(
			name: "Virtusize",
			dependencies: ["VirtusizeCore", .product(name: "VirtusizeAuth", package: "virtusize_auth_ios")],
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
	]
)
