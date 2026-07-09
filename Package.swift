// swift-tools-version: 5.9
import PackageDescription
let package = Package(
    name: "SmartSIP-SDK-Libraries-and-Examples",
    platforms: [.iOS(.v15)],
    products: [.library(name: "SmartSipSDK", targets: ["SmartSipSDK"])],
    targets: [
        .target(name: "SmartSipSDK", dependencies: [.target(name: "SmartSipImplementation"), .target(name: "linphonesw")], path: "Sources/SmartSipSDK"),
        .binaryTarget(name: "SmartSipImplementation", url: "https://github.com/smartconnect-eu/SmartSIP-SDK-Libraries-and-Examples/releases/download/0.1.13/SmartSipImplementation-0.1.13.xcframework.zip", checksum: "4f36e0263755c8ce962fcea0060e6884e073be97f72cac27fd94158852013070"),
        .binaryTarget(name: "bctoolboxios", url: "https://github.com/smartconnect-eu/SmartSIP-SDK-Libraries-and-Examples/releases/download/0.1.13/bctoolbox-ios.xcframework.zip", checksum: "8fe6a14ae4863e7f4e31940e08857bb31eb7e03ae979df021f38e3e5f3db1b2c"),
        .binaryTarget(name: "bctoolbox", url: "https://github.com/smartconnect-eu/SmartSIP-SDK-Libraries-and-Examples/releases/download/0.1.13/bctoolbox.xcframework.zip", checksum: "25ebaede86b08199fb7f6bc6dfd33358f315ab92ca50fc4f4e36d4a850a61904"),
        .binaryTarget(name: "belcard", url: "https://github.com/smartconnect-eu/SmartSIP-SDK-Libraries-and-Examples/releases/download/0.1.13/belcard.xcframework.zip", checksum: "84d750ce03b0442f526fc7497cf5a9b7db94ad24ad3a0387c2160c0bee26d8c6"),
        .binaryTarget(name: "bellesip", url: "https://github.com/smartconnect-eu/SmartSIP-SDK-Libraries-and-Examples/releases/download/0.1.13/belle-sip.xcframework.zip", checksum: "1caf7c9a8e7bab4d551fe91792fe2829363ce7820b0e9ccf782cfabb54e8ec3f"),
        .binaryTarget(name: "belr", url: "https://github.com/smartconnect-eu/SmartSIP-SDK-Libraries-and-Examples/releases/download/0.1.13/belr.xcframework.zip", checksum: "0c91d2f4892bf61f2c7357370005e4019dfad60a976c6da4543968e94bcc1459"),
        .binaryTarget(name: "lime", url: "https://github.com/smartconnect-eu/SmartSIP-SDK-Libraries-and-Examples/releases/download/0.1.13/lime.xcframework.zip", checksum: "af0e9adb38c911079a6dfc71ca3968f4a78c1db39cb0657ac958b071caa489bb"),
        .binaryTarget(name: "linphone", url: "https://github.com/smartconnect-eu/SmartSIP-SDK-Libraries-and-Examples/releases/download/0.1.13/linphone.xcframework.zip", checksum: "cf8e29fec4728edcb5ae99e8caea27b808a3b361b22f637834610931a4b1951e"),
        .binaryTarget(name: "mediastreamer2", url: "https://github.com/smartconnect-eu/SmartSIP-SDK-Libraries-and-Examples/releases/download/0.1.13/mediastreamer2.xcframework.zip", checksum: "8298c9ebe16b7281dafa8b823c0c869b6cba647df4042a825e495675c7455dca"),
        .binaryTarget(name: "msamr", url: "https://github.com/smartconnect-eu/SmartSIP-SDK-Libraries-and-Examples/releases/download/0.1.13/msamr.xcframework.zip", checksum: "08f73cec780ac36358cf74235c0e5a65d7797cf5dcfae7daf279a6f095b28992"),
        .binaryTarget(name: "mscodec2", url: "https://github.com/smartconnect-eu/SmartSIP-SDK-Libraries-and-Examples/releases/download/0.1.13/mscodec2.xcframework.zip", checksum: "dd70b8cb9c9c3ebf1badb959a6086f7a2ebcfaf01b1cf04c2cc56b423b7fbeae"),
        .binaryTarget(name: "msopenh264", url: "https://github.com/smartconnect-eu/SmartSIP-SDK-Libraries-and-Examples/releases/download/0.1.13/msopenh264.xcframework.zip", checksum: "2ce3c0759a4179fc40788be07973a4ae200c2074fce27aa999ea1c15bf4a94d7"),
        .binaryTarget(name: "mssilk", url: "https://github.com/smartconnect-eu/SmartSIP-SDK-Libraries-and-Examples/releases/download/0.1.13/mssilk.xcframework.zip", checksum: "841755a3ca6fd388cc58b475565745b2eb82e32061eb8492539d1e0e59ddade3"),
        .binaryTarget(name: "ortp", url: "https://github.com/smartconnect-eu/SmartSIP-SDK-Libraries-and-Examples/releases/download/0.1.13/ortp.xcframework.zip", checksum: "49301017890043f4111c157aaeb9b4164b42e2cb576b6c3b5655222e5b22ba3d"),
        .binaryTarget(name: "mbedcrypto", url: "https://github.com/smartconnect-eu/SmartSIP-SDK-Libraries-and-Examples/releases/download/0.1.13/mbedcrypto.xcframework.zip", checksum: "fcc24436fc6c4f6365f53fa0612c72637bc9ab6e2cf328c592e3e4216995d185"),
        .binaryTarget(name: "mbedtls", url: "https://github.com/smartconnect-eu/SmartSIP-SDK-Libraries-and-Examples/releases/download/0.1.13/mbedtls.xcframework.zip", checksum: "f4586fa488bf2dc5825862fbd760f162030d61551b669b57339b401732199ea1"),
        .binaryTarget(name: "mbedx509", url: "https://github.com/smartconnect-eu/SmartSIP-SDK-Libraries-and-Examples/releases/download/0.1.13/mbedx509.xcframework.zip", checksum: "fa496838b70d1befcaa057f348fc12003931366076ff9ee0d73a015c9effd045"),
        .target(
            name: "linphonesw",
            dependencies: [
                "bctoolboxios",
                "bctoolbox",
                "belcard",
                "bellesip",
                "belr",
                "lime",
                "linphone",
                "mediastreamer2",
                "msamr",
                "mscodec2",
                "msopenh264",
                "mssilk",
                "ortp",
                "mbedcrypto",
                "mbedtls",
                "mbedx509",
            ],
            path: "Sources/linphonesw"
        )
    ]
)
