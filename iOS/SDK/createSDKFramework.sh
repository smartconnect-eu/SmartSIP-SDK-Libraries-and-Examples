#!/bin/bash

# --- Configuration ---
SDK_NAME="smartsip_sdk"
SCHEME_NAME="smartsip-sdk"
MIRROR_DIR="../SDK_ReleaseMirror"  # Path to your public distribution folder
OUTPUT_DIR="./GeneratedSDK"
BUILD_DIR="./build"
ZIP_NAME="SmartSipSDK.xcframework.zip"
PACKAGE_PATH="$MIRROR_DIR/Package.swift"

# --- 1. Clean up previous builds ---
echo "🧹 Cleaning up previous builds..."
rm -rf "$OUTPUT_DIR"
rm -rf "$BUILD_DIR"
rm -f "$MIRROR_DIR/$ZIP_NAME"
mkdir -p "$OUTPUT_DIR"

echo "🚀 Starting professional build for $SDK_NAME..."

# --- 2. Archive for physical iOS Devices (arm64) ---
echo "📱 Archiving for iOS Devices..."
xcodebuild archive \
  -scheme "$SCHEME_NAME" \
  -destination "generic/platform=iOS" \
  -archivePath "$BUILD_DIR/SmartSip-iOS.xcarchive" \
  SKIP_INSTALL=NO \
  BUILD_LIBRARIES_FOR_DISTRIBUTION=YES

# --- 3. Archive for iOS Simulators (arm64 + x86_64) ---
echo "💻 Archiving for iOS Simulators..."
xcodebuild archive \
  -scheme "$SCHEME_NAME" \
  -destination "generic/platform=iOS Simulator" \
  -archivePath "$BUILD_DIR/SmartSip-Sim.xcarchive" \
  SKIP_INSTALL=NO \
  BUILD_LIBRARIES_FOR_DISTRIBUTION=YES

# --- 4. Combine into XCFramework ---
echo "📦 Merging into XCFramework..."
xcodebuild -create-xcframework \
  -framework "$BUILD_DIR/SmartSip-iOS.xcarchive/Products/Library/Frameworks/$SDK_NAME.framework" \
  -framework "$BUILD_DIR/SmartSip-Sim.xcarchive/Products/Library/Frameworks/$SDK_NAME.framework" \
  -output "$OUTPUT_DIR/SmartSipSDK.xcframework"

# --- 5. Zip for Distribution ---
echo "🤐 Zipping XCFramework..."
# We 'cd' in and out to ensure the zip doesn't contain the 'GeneratedSDK' parent folder path
cd "$OUTPUT_DIR"
zip -r "$ZIP_NAME" "SmartSipSDK.xcframework"
cd ..

# --- 6. Generate Checksum ---
echo "🔢 Generating SHA256 Checksum..."
CHECKSUM=$(swift package compute-checksum "$OUTPUT_DIR/$ZIP_NAME")

# --- 7. Move to Mirror Folder ---
echo "🚚 Moving Zip to Release Mirror..."
cp "$OUTPUT_DIR/$ZIP_NAME" "$MIRROR_DIR/"

# --- 8. Auto-Update Package.swift ---
echo "📝 Updating Package.swift checksum..."
if [ -f "$PACKAGE_PATH" ]; then
    # This sed command finds the 'checksum:' line and replaces the value
    # Works on macOS (BSD sed)
    sed -i '' "s/checksum: \".*\"/checksum: \"$CHECKSUM\"/" "$PACKAGE_PATH"
    echo "✅ Package.swift updated."
else
    echo "⚠️  Warning: Package.swift not found at $PACKAGE_PATH. Please update manually."
fi

# --- 9. Final Cleanup ---
rm -rf "$BUILD_DIR"
rm -rf "$OUTPUT_DIR"

echo "----------------------------------------------------"
echo "✅ SUCCESS: SmartSipSDK is ready for release!"
echo "📍 Zip Location: $MIRROR_DIR/$ZIP_NAME"
echo "🔢 New Checksum: $CHECKSUM"
echo "----------------------------------------------------"
echo "Next Steps:"
echo "1. cd $MIRROR_DIR"
echo "2. git add . && git commit -m 'Release update' && git push"
echo "3. Create a GitHub Release and upload the ZIP file."