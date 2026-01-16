// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "SmartSIP-SDK-Libraries-and-Examples",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "SmartSipSDK", targets: ["SmartSipSDK"])
    ],
    dependencies: [
        .package(url: "https://gitlab.linphone.org/BC/public/linphone-sdk-swift-ios.git", exact: "5.4.73")
    ],
    targets: [
        .target(
            name: "SmartSipSDK",
            dependencies: [
                .target(name: "SmartSipImplementation"),
                .product(name: "linphonesw", package: "linphone-sdk-swift-ios")
            ],
            path: "Sources/SmartSipSDK"
        ),
        .binaryTarget(
            name: "SmartSipImplementation",
            url: "https://github.com/smartconnect-eu/SmartSIP-SDK-Libraries-and-Examples/releases/download/0.0.35/SmartSipImplementation-0.0.35.xcframework.zip",
            checksum: "c6d47761c421bb8c1caf0f24ab68859b8f4a27ea35a60b487cb8c80961763c6b"
        )
    ]
)
