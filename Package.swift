// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "SmartSIP-SDK-Libraries-and-Examples",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "smartsip-sdk", targets: ["smartsip-sdk"])
    ],
    dependencies: [
        .package(url: "https://gitlab.linphone.org/BC/public/linphone-sdk-swift-ios.git", exact: "5.4.73")
    ],
    targets: [
        .target(
            name: "smartsip-sdk",
            dependencies: [
                .target(name: "smartsip-sdk-binary"),
                .product(name: "linphonesw", package: "linphone-sdk-swift-ios")
            ],
            path: "Sources/smartsip-sdk"
        ),
        .binaryTarget(
            name: "smartsip-sdk-binary",
            url: "https://github.com/smartconnect-eu/SmartSIP-SDK-Libraries-and-Examples/releases/download/0.0.25/smartsip-sdk-0.0.25.xcframework.zip",
            checksum: "9853065889e53f356f2ac172e5ee62749b0f21d9301d92943e99527e34d5cec6"
        )
    ]
)
