# --- Configuration ---
VERSION="0.0.1"               # <--- UPDATE THIS FOR EVERY RELEASE
SDK_NAME="smartsip_sdk"
SCHEME_NAME="smartsip-sdk"
MIRROR_DIR="../SDK_ReleaseMirror"
OUTPUT_DIR="./GeneratedSDK"
BUILD_DIR="./build"
ZIP_NAME="SmartSipSDK.xcframework.zip"
PACKAGE_PATH="$MIRROR_DIR/Package.swift"

# --- 1. Clean up ---
echo "🧹 Cleaning up previous builds..."
rm -rf "$OUTPUT_DIR" "$BUILD_DIR"
mkdir -p "$OUTPUT_DIR"

# --- 2. Archive for Device & Simulator ---
echo "📱 Archiving for iOS Devices..."
xcodebuild archive -scheme "$SCHEME_NAME" -destination "generic/platform=iOS" -archivePath "$BUILD_DIR/SmartSip-iOS.xcarchive" SKIP_INSTALL=NO BUILD_LIBRARIES_FOR_DISTRIBUTION=YES

echo "💻 Archiving for iOS Simulators..."
xcodebuild archive -scheme "$SCHEME_NAME" -destination "generic/platform=iOS Simulator" -archivePath "$BUILD_DIR/SmartSip-Sim.xcarchive" SKIP_INSTALL=NO BUILD_LIBRARIES_FOR_DISTRIBUTION=YES

# --- 3. Create XCFramework ---
echo "📦 Creating XCFramework..."
xcodebuild -create-xcframework \
  -framework "$BUILD_DIR/SmartSip-iOS.xcarchive/Products/Library/Frameworks/$SDK_NAME.framework" \
  -framework "$BUILD_DIR/SmartSip-Sim.xcarchive/Products/Library/Frameworks/$SDK_NAME.framework" \
  -output "$OUTPUT_DIR/SmartSipSDK.xcframework"

# --- 4. Zip for Distribution ---
echo "🤐 Zipping XCFramework..."
cd "$OUTPUT_DIR"
zip -r "$ZIP_NAME" "SmartSipSDK.xcframework"
cd ..

# --- 5. Generate Checksum ---
echo "🔢 Generating SHA256 Checksum..."
CHECKSUM=$(swift package compute-checksum "$OUTPUT_DIR/$ZIP_NAME")

# --- 6. Move to Mirror Folder ---
echo "🚚 Moving Zip to Release Mirror..."
cp "$OUTPUT_DIR/$ZIP_NAME" "$MIRROR_DIR/"

# --- 7. Update Checksum in Package.swift ---
echo "📝 Updating Package.swift Checksum..."
sed -i '' "s/checksum: \".*\"/checksum: \"$CHECKSUM\"/" "$PACKAGE_PATH"

# --- 8. Update Version in URL (NEW) ---
# This looks for the /download/X.X.X/ part of your URL and replaces it
echo "🔗 Updating Version in URL to $VERSION..."
sed -i '' "s/download\/.*\/$ZIP_NAME/download\/$VERSION\/$ZIP_NAME/" "$PACKAGE_PATH"

# --- 9. Final Cleanup ---
rm -rf "$BUILD_DIR"
# rm -rf "$OUTPUT_DIR" # Optional: keep if you want to inspect locally

echo "----------------------------------------------------"
echo "✅ SUCCESS: SmartSipSDK $VERSION is ready!"
echo "🔢 Checksum: $CHECKSUM"
echo "----------------------------------------------------"