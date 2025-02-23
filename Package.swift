// swift-tools-version: 5.4

import PackageDescription

let package = Package(
	name: "DSFAppearanceManager",
	platforms: [
		.macOS(.v10_11),
	],
	products: [
		.library(name: "DSFAppearanceManager", targets: ["DSFAppearanceManager"]),
		.library(name: "DSFAppearanceManager-static", type: .static, targets: ["DSFAppearanceManager"]),
		.library(name: "DSFAppearanceManager-shared", type: .dynamic, targets: ["DSFAppearanceManager"]),
	],
	dependencies: [],
	targets: [
		.target(
			name: "DSFAppearanceManager",
			dependencies: [],
			resources: [
				.copy("PrivacyInfo.xcprivacy"),
			]
		),
		.testTarget(
			name: "DSFAppearanceManagerTests",
			dependencies: ["DSFAppearanceManager"]),
	]
)
