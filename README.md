# SmartSip SDK for iOS

A powerful, wrapper-based SDK for SIP communication, built on top of a SIP engine. This repository contains the distribution manifest and example projects.

## 📂 Repository Structure

This repository follows the industry standard for binary Swift Package distribution:

* **`Package.swift`**: The main manifest that links the SDK to your project and manages dependencies.
* **`Sources/smartsip-sdk/`**: Contains an `Empty.swift` file required by SPM to acknowledge the library target.
* **`Demo/`**: Contains complete, ready-to-run example applications:
    * `iOS/SmartSipDemo`: A SwiftUI project demonstrating call initialization, state handling, and UI integration.
    * `Android/`: Showcase for the Android implementation.
* **GitHub Releases**: The actual compiled binary (`.xcframework`) is hosted in the "Releases" section of this repository to keep the Git history lightweight.



## 📦 Installation

### Swift Package Manager
1. In Xcode, go to **File > Add Package Dependencies...**
2. Enter the repository URL:
   `https://github.com/smartconnect-eu/SmartSIP-SDK-Libraries-and-Examples.git`
3. Select the version you wish to use (e.g., `0.0.2`).

## 🚀 Quick Start

### 1. Configure Permissions
Add the following keys to your app's `Info.plist`:
* `NSMicrophoneUsageDescription`: Required for audio calls.
* `UIBackgroundModes`: Add `voip` and `audio`.

### 2. Initialization
```swift
import smartsip_sdk

@main
struct YourApp: App {
    init() {
        // Initialize the SDK with your credentials
        SmartSipSDK.initialize(
            token: "YOUR_TOKEN",
            flowId: "YOUR_FLOW_ID",
            domain: "YOUR_DOMAIN"
        )
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}