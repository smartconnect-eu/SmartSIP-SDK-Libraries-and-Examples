// swift-tools-version: 5.9
import PackageDescription
let package = Package(
    name: "SmartSIP-SDK-Libraries-and-Examples",
    platforms: [.iOS(.v15)],
    products: [.library(name: "SmartSipSDK", targets: ["SmartSipSDK"])],
    dependencies: [.package(url: "https://gitlab.linphone.org/BC/public/linphone-sdk-swift-ios.git", exact: "5.4.73")],
    targets: [
        .target(name: "SmartSipSDK", dependencies: [.target(name: "SmartSipImplementation"), .product(name: "linphonesw", package: "linphone-sdk-swift-ios")], path: "Sources/SmartSipSDK"),
        .binaryTarget(name: "SmartSipImplementation", url: "https://github.com/smartconnect-eu/SmartSIP-SDK-Libraries-and-Examples/releases/download/0.0.47/SmartSipImplementation-0.0.47.xcframework.zip", checksum: "eaa99e2081e6b8332db0d5ead4096ab7f9b8a7a22ff6d8671dc66191e98aadcf")
    ]
)
