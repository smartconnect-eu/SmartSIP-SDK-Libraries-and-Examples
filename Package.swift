// swift-tools-version: 5.9
import PackageDescription
let package = Package(
    name: "SmartSIP-SDK-Libraries-and-Examples",
    platforms: [.iOS(.v15)],
    products: [.library(name: "SmartSipSDK", targets: ["SmartSipSDK"])],
    dependencies: [.package(url: "https://gitlab.linphone.org/BC/public/linphone-sdk-swift-ios.git", exact: "5.4.73")],
    targets: [
        .target(name: "SmartSipSDK", dependencies: [.target(name: "SmartSipImplementation"), .product(name: "linphonesw", package: "linphone-sdk-swift-ios")], path: "Sources/SmartSipSDK"),
        .binaryTarget(name: "SmartSipImplementation", url: "https://github.com/smartconnect-eu/SmartSIP-SDK-Libraries-and-Examples/releases/download/0.0.76/SmartSipImplementation-0.0.76.xcframework.zip", checksum: "f364325e264e47f459df2730215d7f481c94f4dc0f217bca2240f2f0b89d5bc6")
    ]
)
