// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "SmartSipSDK",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "smartsip_sdk", targets: ["smartsip_sdk"])
    ],
    dependencies: [
        .package(url: "https://gitlab.linphone.org/BC/public/linphone-sdk.git", from: "5.4.73")
    ],
    targets: [
        .target(
            name: "smartsip_sdk",
            dependencies: [
                .target(name: "SmartSipSDKBinary"),
                .product(name: "LinphoneSDK", package: "linphone-sdk")
            ],
            path: "Sources/SmartSipSDK"
        ),
        // This URL and Checksum will be managed by the build script
        .binaryTarget(
            name: "SmartSipSDKBinary",
            url: "https://github.com/your-org/smartsip-public/releases/download/1.0.0/SmartSipSDK.xcframework.zip",
            checksum: "067b9e367a39d4f291281e7f00882c0180bdf5eebd4c75bb3c3fc53cd1712cd3" 
        )
    ]
)