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
            url: "https://github.com/smartconnect-eu/SmartSIP-SDK-Libraries-and-Examples/releases/download/0.0.43/SmartSipImplementation-0.0.43.xcframework.zip",
            checksum: "1733263cb9fd27c5f8c9a16f00657740a366513f27229d1c4ca06642b9dbec78"
        )
    ]
)
