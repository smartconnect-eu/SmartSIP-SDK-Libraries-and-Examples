# SmartSip SDK for iOS

A professional-grade, wrapper-based VoIP SDK for SIP communication. This SDK is designed to handle complex signaling and hardware optimization while providing a simple, modern Swift interface for developers.

## 📂 Repository Structure

* **`Package.swift`**: Manifest for Swift Package Manager (SPM).
* **`Sources/SmartSipSDK/`**: The public-facing Swift interface and DocC documentation.
* **`Demo/SmartSipDemo`**: A complete SwiftUI example project demonstrating:
    * **CallKit Integration**: Standard native iOS call experience.
    * **Custom UI Flow**: A "Blue Dialer" with proximity sensor and haptic feedback.
    * **AudioManager & DTMFPlayer**: Best practices for hardware routing and local UI sounds.

## 📦 Installation

### Swift Package Manager
1. In Xcode: **File > Add Package Dependencies...**
2. URL: `https://github.com/smartconnect-eu/SmartSIP-SDK-Libraries-and-Examples.git`
3. Version: `0.0.38` or higher.

## 🚀 Quick Start

### 1. Configure Permissions (`Info.plist`)
You must include the following keys to allow background audio and microphone access:

* `NSMicrophoneUsageDescription`: "This app requires microphone access for VoIP calls."
* `UIBackgroundModes`: Add `voip` and `audio`.
* `NSCameraUsageDescription`: Required by underlying dependencies (even if video is not used).

### 2. Initialization
Initialize the SDK once at app launch (e.g., in your `AppDelegate` or `App` init).

```swift
import SmartSipSDK

SmartSipSDK.initialize(
    token: "YOUR_TOKEN",
    flowId: "YOUR_FLOW_ID",
    domain: "YOUR_DOMAIN"
)

// Assign a delegate to listen for call states
SmartSipSDK.setDelegate(yourDelegate)
📞 Core Functionality
Managing Calls
Initiate and terminate calls using the high-level API:

Swift

// Initiate an outgoing call
await SmartSipSDK.makeCall(
    destinationQueue: "Support_Queue",
    callerFullName: "John Doe"
)

// Hang up an active session
SmartSipSDK.hangUp()


// Route audio to the loud speaker
SmartSipSDK.setSpeakerOn(true)

// Mute the microphone stream
SmartSipSDK.setMicrophoneMuted(true)



DTMF Signaling (IVR Interaction)
Use the type-safe DTMFButton enum to interact with automated systems (e.g., "Press 1 for Stolen Cards").
SmartSipSDK.sendDTMF(.one)

🛠 Best Practices (From the Demo App)
Proximity Sensor Logic
In a custom UI, use the proximity sensor to turn the screen off when the phone is held to the ear to prevent "cheek-dialing" and save battery.


The SDK automatically configures the AVAudioSession using .voiceChat mode. This ensures:
Hardware Echo Cancellation is enabled to prevent feedback loops.
Physical Volume Buttons control the "In-Call" volume instead of the system ringer.

Bluetooth HFP support is automatically handled.
Decoupled UI Audio (DTMF Sounds)

For DTMF "beeps" in the UI, we recommend playing sounds in the App layer using AudioToolbox system sounds (IDs 1200-1211). This ensures zero latency and a native iOS feel.

📋 Delegate Handling
Implement the CallDelegate to react to state changes:
extension YourViewModel: CallDelegate {
    func callDidChangeState(_ state: CallState) {
        switch state {
        case .connected:
            print("Call is active")
        case .disconnected, .failed:
            print("Call ended")
        default:
            break
        }
    }
    
    func callDidFail(withError error: String) {
        print("Call Error: \(error)")
    }
}

Debugging & Troubleshooting
If you encounter signaling or network issues, enable detailed low-level logs:
SmartSipSDK.setSIPDebugMode(enabled: true)