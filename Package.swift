// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "SmartSIP-SDK-Libraries-and-Examples",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "smartsip_sdk", targets: ["smartsip_sdk"])
    ],
    dependencies: [
        .package(url: "https://gitlab.linphone.org/BC/public/linphone-sdk-swift-ios.git", exact: "5.4.73")
    ],
    targets: [
        .target(
            name: "smartsip_sdk",
            dependencies: [
                .target(name: "smartsip_sdk_binary_dist"),
                .product(name: "linphonesw", package: "linphone-sdk-swift-ios")
            ],
            path: "Sources/smartsip_sdk"
        ),
        .binaryTarget(
            name: "smartsip_sdk_binary_dist",
            url: "https://github.com/smartconnect-eu/SmartSIP-SDK-Libraries-and-Examples/releases/download/0.0.28/smartsip-sdk-0.0.28.xcframework.zip",
            checksum: "2a5dc4671e0d7895f65f61e1399a05f058d2577f8da0e8f079244b33653fead1"
        )
    ]
)
