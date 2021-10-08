// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
	name: "Virtusize",
	defaultLocalization: "en",
	platforms: [.iOS(.v10)],
	products: [
		.library(name: "Virtusize", targets: ["Virtusize"]),
		.library(name: "VirtusizeUIKit", targets: ["VirtusizeUIKit"])
	],
	dependencies: [],
	targets: [
		.target(
			name: "Virtusize",
			dependencies: ["VirtusizeUIKit", "VirtusizeCore"],
			path: "Virtusize/Sources",
			exclude: ["Info.plist"]
		),
		.target(
			name: "VirtusizeUIKit",
			dependencies: ["VirtusizeCore"],
			path: "VirtusizeUIKit/Sources",
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
