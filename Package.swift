// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "SmartSIP-SDK-Libraries-and-examples",
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
                "smartsip-sdk-binary",
                .product(name: "linphonesw", package: "linphone-sdk-swift-ios")
            ],
            path: "Sources/smartsip-sdk"
        ),
        .binaryTarget(
            name: "smartsip-sdk-binary",
            url: "https://github.com/FranzIacobCegeka/SmartSIP-SDK-Libraries-and-examples/releases/download/0.0.2/smartsip-sdk-0.0.2.xcframework.zip",
            checksum: "9e9f568e414d3c7d0ab7f418e5504c97fb66986bbc5400b68c19e2068bfa451f"
        )
    ]
)
