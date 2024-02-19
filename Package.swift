// swift-tools-version: 5.9

import PackageDescription

let globalPlugins: [Target.PluginUsage] = [
  .plugin(name: "SwiftLintPlugin", package: "SwiftLint")
]

let globalDependancies: [Target.Dependency] = [
  .product(name: "ArgumentParser", package: "swift-argument-parser"),
  .product(name: "Logging", package: "swift-log"),
]

let executableDependancies: [Target.Dependency] = globalDependancies + ["ArpyCore"]

let package = Package(
  name: "arpy",
  platforms: [.macOS(.v14)],
  products: [
    .library(name: "ArpyCore", targets: ["ArpyCore"])
  ],
  // There's confliction between swift-argument-parser and swift-lint's dependancy requirements, hence
  // why we use swift-argument-parser "1.2.0 < version < 1.3.0"
  dependencies: [
    .package(url: "https://github.com/vapor/vapor.git", from: "4.90.0"),
    .package(url: "https://github.com/uraimo/SwiftyGPIO.git", from: "1.0.0"),
    .package(url: "https://github.com/apple/swift-argument-parser", from: "1.2.0"),
    .package(url: "https://github.com/apple/swift-log.git", from: "1.0.0"),
    .package(url: "https://github.com/realm/SwiftLint.git", from: "0.54.0" )
  ],
  targets: [
    .target(
      name: "ArpyCore",
      dependencies: globalDependancies + [
        .product(name: "Vapor", package: "vapor"),
        "SwiftyGPIO"
      ],
      plugins: globalPlugins
    ),
    .executableTarget(
      name: "arpy",
      dependencies: executableDependancies,
      plugins: globalPlugins
    ),
    .executableTarget(
      name: "remote-build",
      dependencies: executableDependancies,
      plugins: globalPlugins
    )
  ]
)
