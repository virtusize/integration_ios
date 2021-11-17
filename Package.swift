// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
	name: "Virtusize",
	defaultLocalization: "en",
	platforms: [.iOS(.v10)],
	products: [
		.library(
			name: "Virtusize",
			targets: ["Virtusize"]),
		.library(
			name: "VirtusizeCore",
			targets: ["VirtusizeCore"])
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
