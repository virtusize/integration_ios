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
			targets: ["Virtusize"])
	],
	dependencies: [],
	targets: [
		.target(
			name: "Virtusize",
			dependencies: [],
			path: "Virtusize/Sources",
			exclude: ["Info.plist"],
			resources: [.copy("Resources")]
		),
		.testTarget(
			name: "VirtusizeTests",
			dependencies: ["Virtusize"],
			path: "Virtusize/Tests",
			exclude: ["Info.plist"],
			resources: [
				.process("i18n_en.json"),
				.process("i18n_jp.json"),
				.process("i18n_ko.json")
			]
		)
	]
)
