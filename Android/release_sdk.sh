#!/bin/bash

# =====================================================
# SmartSip SDK: Unified Multi-Platform Release Script
# =====================================================

set -e

# --- 1. CONFIGURATION & PATHS ---
ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ANDROID_DIR="$ROOT_DIR/Android"
IOS_DIR="$ROOT_DIR/iOS/SDK"
DISTRIBUTION_DIR="/Users/franziacob/Documents/GitHub/SmartSIP-SDK-Libraries-and-Examples"

GRADLE_PROPS="$ANDROID_DIR/gradle.properties"
XCODE_PROJ="$IOS_DIR/smartsip-sdk.xcodeproj"

GITHUB_ORG="smartconnect-eu"
REPO_NAME="SmartSIP-SDK-Libraries-and-Examples"
PUBLIC_TARGET="SmartSipSDK"
BINARY_TARGET="SmartSipImplementation"

# --- 2. VERSION MANAGEMENT (Force GitHub Sync) ---
echo "🔍 Fetching all tags from Public GitHub Repo..."
cd "$DISTRIBUTION_DIR"
git fetch --tags --force

# Improved logic to find the absolute highest version number
# This filters for X.X.X and ensures we get the latest even if local tags are messy
LATEST_TAG=$(git tag -l | grep -E '^[0-9]+\.[0-9]+\.[0-9]+$' | sort -V | tail -n 1)

if [ -z "$LATEST_TAG" ]; then
    echo "⚠️ No tags found in distribution repo. Defaulting to 0.0.1"
    VERSION="0.0.1"
else
    echo "📊 Latest Public Tag Found: $LATEST_TAG"
    # Increment the patch (e.g., 0.0.42 -> 0.0.43)
    IFS='.' read -r major minor patch <<< "$LATEST_TAG"
    VERSION="$major.$minor.$((patch + 1))"
fi

echo "🚀 Starting Unified Release: v$VERSION"
echo "--------------------------------------"

# --- 3. PREPARE REPOS & SYNC VERSIONS ---
echo "🔄 Updating local project version files..."

# Update Android gradle.properties
sed -i '' "s/SDK_VERSION=.*/SDK_VERSION=$VERSION/" "$GRADLE_PROPS"

# Update iOS Marketing Version
cd "$IOS_DIR"
# agvtool is the official way to update Xcode project versions
xcrun agvtool new-marketing-version "$VERSION" > /dev/null

# Prepare Distribution Repo
cd "$DISTRIBUTION_DIR"
git checkout -B main
git reset --hard origin/main

# --- 4. ANDROID BUILD & PUBLISH ---
echo "🤖 [Android] Building and Publishing AAR..."
cd "$ANDROID_DIR"
./gradlew clean :smartsip-sdk:publishReleasePublicationToGitHubPackagesRepository

# --- 5. IOS BUILD (XCFRAMEWORK) ---
echo "🍎 [iOS] Building XCFramework..."
cd "$IOS_DIR"
OUTPUT_DIR="$IOS_DIR/GeneratedSDK"
BUILD_DIR="$IOS_DIR/build"
ZIP_NAME="SmartSipImplementation-$VERSION.xcframework.zip"

rm -rf "$OUTPUT_DIR" "$BUILD_DIR"
mkdir -p "$OUTPUT_DIR"

xcodebuild archive -scheme "smartsip-sdk" -destination "generic/platform=iOS" -archivePath "$BUILD_DIR/iOS.xcarchive" SKIP_INSTALL=NO BUILD_LIBRARIES_FOR_DISTRIBUTION=YES > /dev/null
xcodebuild archive -scheme "smartsip-sdk" -destination "generic/platform=iOS Simulator" -archivePath "$BUILD_DIR/Sim.xcarchive" SKIP_INSTALL=NO BUILD_LIBRARIES_FOR_DISTRIBUTION=YES > /dev/null

xcodebuild -create-xcframework \
    -framework "$BUILD_DIR/iOS.xcarchive/Products/Library/Frameworks/smartsip_sdk.framework" \
    -framework "$BUILD_DIR/Sim.xcarchive/Products/Library/Frameworks/smartsip_sdk.framework" \
    -output "$OUTPUT_DIR/SmartSipImplementation.xcframework"

cd "$OUTPUT_DIR"
zip -r "$ZIP_NAME" "SmartSipImplementation.xcframework" > /dev/null
SDK_CHECKSUM=$(swift package compute-checksum "$ZIP_NAME")

# --- 6. UPDATE PUBLIC REPO (Package.swift & Interface) ---
echo "📝 [Public] Updating Package.swift and Interface..."
cd "$DISTRIBUTION_DIR"
mkdir -p "Sources/$PUBLIC_TARGET"

cat <<EOF > "Sources/$PUBLIC_TARGET/SmartSipSDK.swift"
import Foundation

public protocol CallDelegate: AnyObject {
    func callDidChangeState(_ state: CallState)
    func callDidFail(withError error: String)
}

public enum CallState: String {
    case loginInProgress, loggedIn, loggedOut, dialing, ringing, connected, held, disconnected, failed
}

public enum DTMFButton: String {
    case zero = "0", one = "1", two = "2", three = "3", four = "4"
    case five = "5", six = "6", seven = "7", eight = "8", nine = "9"
    case star = "*", pound = "#"
}

public final class SmartSipSDK {
    public static let sdkVersion = "$VERSION"
    public static func setDelegate(_ delegate: CallDelegate) {}
    public typealias CallDestination = String
    public static func initialize(token: String, flowId: String, domain: String) {}
    @discardableResult
    public static func getCallDestinations() async -> [CallDestination] { return [] }
    public static func makeCall(clientData: [String: Any]? = nil, destinationQueue: String? = nil, callerPhoneNumber: String? = nil, callerFullName: String? = nil, otherRoutingData: [String: Any]? = nil) async {}
    public static func hangUp() {}
    public static func sendDTMF(_ button: DTMFButton) {}
    public static func setMicrophoneMuted(_ muted: Bool) {}
    public static func setSpeakerOn(_ isSpeakerOn: Bool) {}
    public static func setSIPDebugMode(enabled: Bool) {}
}
EOF

BINARY_URL="https://github.com/$GITHUB_ORG/$REPO_NAME/releases/download/$VERSION/$ZIP_NAME"
cat <<EOF > "Package.swift"
// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "$REPO_NAME",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "$PUBLIC_TARGET", targets: ["$PUBLIC_TARGET"])
    ],
    dependencies: [
        .package(url: "https://gitlab.linphone.org/BC/public/linphone-sdk-swift-ios.git", exact: "5.4.73")
    ],
    targets: [
        .target(
            name: "$PUBLIC_TARGET",
            dependencies: [
                .target(name: "$BINARY_TARGET"),
                .product(name: "linphonesw", package: "linphone-sdk-swift-ios")
            ],
            path: "Sources/$PUBLIC_TARGET"
        ),
        .binaryTarget(
            name: "$BINARY_TARGET",
            url: "$BINARY_URL",
            checksum: "$SDK_CHECKSUM"
        )
    ]
)
EOF

# --- 7. FINAL PUSH & GITHUB RELEASE ---
echo "💾 [Public] Pushing to GitHub..."
git add .
git commit -m "Release $VERSION - Unified Android/iOS Update"
git push origin main
git tag -a "$VERSION" -m "Release $VERSION"
git push origin "$VERSION"

echo "🚀 [GitHub] Creating Release and uploading assets..."
RELEASE_JSON=$(curl -s -X POST -H "Authorization: token $GITHUB_TOKEN" \
    -d "{\"tag_name\":\"$VERSION\", \"name\":\"$VERSION\"}" \
    "https://api.github.com/repos/$GITHUB_ORG/$REPO_NAME/releases")

RELEASE_ID=$(echo "$RELEASE_JSON" | python3 -c "import sys, json; print(json.load(sys.stdin).get('id', ''))")

curl -s -H "Authorization: token $GITHUB_TOKEN" \
     -H "Content-Type: application/zip" \
     --data-binary @"$OUTPUT_DIR/$ZIP_NAME" \
     "https://uploads.github.com/repos/$GITHUB_ORG/$REPO_NAME/releases/$RELEASE_ID/assets?name=$ZIP_NAME" > /dev/null

echo "💾 [Private] Pushing source code to Bitbucket..."
cd "$ROOT_DIR"
git add Android/gradle.properties
git add iOS/SDK/smartsip-sdk.xcodeproj
git commit -m "chore: release version $VERSION"
git tag "$VERSION"
git push origin main
git push origin "$VERSION"

echo "✅ ALL DONE! Version $VERSION is live for Android and iOS."