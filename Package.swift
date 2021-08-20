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
			dependencies: ["VirtusizeUIKit"],
			path: "Virtusize/Sources",
			exclude: ["Info.plist"],
			resources: [.process("Resources")]
		),
		.target(
			name: "VirtusizeUIKit",
			dependencies: [],
			path: "VirtusizeUIKit/Sources",
			exclude: ["Info.plist"],
			resources: [.process("Resources")]
		)
	]
)
