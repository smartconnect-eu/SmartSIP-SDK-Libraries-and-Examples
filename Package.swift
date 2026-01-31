// swift-tools-version: 5.9
import PackageDescription
let package = Package(
    name: "SmartSIP-SDK-Libraries-and-Examples",
    platforms: [.iOS(.v15)],
    products: [.library(name: "SmartSipSDK", targets: ["SmartSipSDK"])],
    dependencies: [.package(url: "https://gitlab.linphone.org/BC/public/linphone-sdk-swift-ios.git", exact: "5.4.73")],
    targets: [
        .target(name: "SmartSipSDK", dependencies: [.target(name: "SmartSipImplementation"), .product(name: "linphonesw", package: "linphone-sdk-swift-ios")], path: "Sources/SmartSipSDK"),
        .binaryTarget(name: "SmartSipImplementation", url: "https://github.com/smartconnect-eu/SmartSIP-SDK-Libraries-and-Examples/releases/download/0.0.75/SmartSipImplementation-0.0.75.xcframework.zip", checksum: "e5e91f2e7c5afabeecc3a5b4925bbe25ca8d00c7fbf5f9765648afa3d8d59f02")
    ]
)
