// swift-tools-version: 5.9
import PackageDescription
let package = Package(
    name: "SmartSIP-SDK-Libraries-and-Examples",
    platforms: [.iOS(.v15)],
    products: [.library(name: "SmartSipSDK", targets: ["SmartSipSDK"])],
    dependencies: [.package(url: "https://gitlab.linphone.org/BC/public/linphone-sdk-swift-ios.git", exact: "5.4.73")],
    targets: [
        .target(name: "SmartSipSDK", dependencies: [.target(name: "SmartSipImplementation"), .product(name: "linphonesw", package: "linphone-sdk-swift-ios")], path: "Sources/SmartSipSDK"),
        .binaryTarget(name: "SmartSipImplementation", url: "https://github.com/smartconnect-eu/SmartSIP-SDK-Libraries-and-Examples/releases/download/0.0.71/SmartSipImplementation-0.0.71.xcframework.zip", checksum: "e89c8fcabe1e50b9c140692461e04b65d0d62ea7511697a62b2b91ef8f6074dc")
    ]
)
