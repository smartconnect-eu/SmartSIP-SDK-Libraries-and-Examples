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
                "smartsip-sdk-binary",
                .product(name: "linphonesw", package: "linphone-sdk-swift-ios")
            ],
            path: "Sources/smartsip-sdk"
        ),
        .binaryTarget(
            name: "smartsip-sdk-binary",
            url: "https://github.com/FranzIacobCegeka/SmartSIP-SDK-Libraries-and-Examples/releases/download/0.0.2/smartsip-sdk-0.0.2.xcframework.zip",
            checksum: "98b4c02401e061939dbf9bbcb2ed65760b06e10b8a1a490624b0d9c1bf9fccfc"
        )
    ]
)
