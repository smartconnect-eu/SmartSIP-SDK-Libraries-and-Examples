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
            url: "https://github.com/your-org/smartsip-public/releases/download/0.0.1/SmartSipSDK.xcframework.zip",
            checksum: "8b1c1fcc2ca75f0af89f9058a3c76614ff078e863c7d34e1a6ec7c8d87c9a3be" 
        )
    ]
)