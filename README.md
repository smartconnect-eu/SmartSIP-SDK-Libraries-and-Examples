# SmartSIP SDK: Unified Mobile VoIP
![iOS](https://img.shields.io/badge/platform-iOS-blue) ![Android](https://img.shields.io/badge/platform-Android-green) ![License](https://img.shields.io/badge/license-Commercial-red) ![Version](https://img.shields.io/badge/version-0.0.64-orange)

A professional-grade, wrapper-based VoIP SDK for SIP communication. This SDK is designed to handle complex signaling and hardware optimization while providing simple, modern interfaces for both iOS and Android.

## 📑 Table of Contents
* [📂 Repository Structure](#-repository-structure)
* [🍎 iOS Integration](#-ios-integration)
    * [📦 Installation](#-installation)
    * [🚀 Quick Start](#-quick-start)
* [🤖 Android Integration](#-android-integration)
    * [📦 Installation](#-installation-1)
    * [🚀 Quick Start](#-quick-start-1)
    * [🛡️ Permissions & System Requirements](#️-permissions--system-requirements-android)
* [📞 Managing Calls](#-managing-calls)
    * [🔍 Discovering Destinations](#discovering-destinations)
    * [📤 Outgoing Calls & Metadata](#outgoing-calls-with-custom-metadata)
* [📱 Dialer Experience & UI](#-dialer-experience--ui)
* [🎹 DTMF Support](#-dtmf-support-signaling--ivr)
* [👂 Listening to Call Events](#-listening-to-call-events)
* [🔊 Audio Control](#-audio-control)
* [🛠 Debugging & SIP Tracing](#-debugging--sip-tracing)
* [🛡️ Developer Responsibility & Constraints](#️-developer-responsibility--constraints)
* [⚠️ Limitations & System Behavior](#️-limitations--system-behavior)
* [📩 Contact & Support](#-contact--support)

---

## 📂 Repository Structure

* **`Package.swift`**: Manifest for iOS Swift Package Manager (SPM).
* **`Sources/SmartSipSDK/`**: The public-facing Swift interface and DocC documentation.
* **`maven-repo/`**: The public Android Maven repository containing compiled AAR binaries.
* **`Demo/`**: Example projects for both platforms demonstrating best practices.

---

## 🍎 iOS Integration

The iOS SDK is distributed as a Swift Package Manager (SPM) dependency.

### 📦 Installation
1. In Xcode: **File > Add Package Dependencies...**
2. URL: `https://github.com/smartconnect-eu/SmartSIP-SDK-Libraries-and-Examples.git`
3. Version: `0.0.77` or higher.

### 🚀 Quick Start
#### 1. Configure Permissions (`Info.plist`)
* `NSMicrophoneUsageDescription`: "This app requires microphone access for VoIP calls."
* `UIBackgroundModes`: Add `voip` and `audio`.
* `NSCameraUsageDescription`: Required by underlying dependencies.

#### 2. Initialization
<pre>
import SmartSipSDK

SmartSipSDK.initialize(
    token: "YOUR_TOKEN",
    flowId: "YOUR_FLOW_ID",
    domain: "YOUR_DOMAIN"
)

// Assign a delegate to listen for call states
SmartSipSDK.setDelegate(yourDelegate)
</pre>

---

## 🤖 Android Integration

The Android SDK uses a custom Maven repository structure for **public access without requiring GitHub credentials or tokens.**

### 📦 Installation

#### 1. Repository Configuration
Add the following to your **`settings.gradle.kts`**:

<pre>
dependencyResolutionManagement {
    repositories {
        google()
        mavenCentral()
        // Public access to SmartSIP SDK (No token required)
        maven { url = uri("https://raw.githubusercontent.com/smartconnect-eu/SmartSIP-SDK-Libraries-and-Examples/main/maven-repo") }
        // Required for underlying SIP engine
        maven { url = uri("https://linphone.org/maven_repository") }
    }
}
</pre>

#### 2. Dependency & Java 17 Support
Update your app/build.gradle.kts:

<pre>
android {
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
    kotlinOptions {
        jvmTarget = "17"
    }
}

dependencies {
    implementation("cc.smartconnect:smartsip-sdk:0.0.77")
}
</pre>

#### 🚀 Quick Start On Android
You must provide a SmartSipNotificationConfig. This branding is used by the Foreground Service to maintain the call session and prevent the OS from killing the app.

<pre>
import cc.smartconnect.smartsip_sdk.SmartSipSDK
import cc.smartconnect.smartsip_sdk.SmartSipNotificationConfig

// 1. Configure the Foreground Service notification
val notificationBranding = SmartSipNotificationConfig(
title = "SmartSip VoIP",
message = "Active call in progress...",
iconResourceId = R.drawable.ic_menu_call // Your custom icon
)

// 2. Initialize the SDK
SmartSipSDK.initialize(
context = applicationContext,
token = "YOUR_TOKEN",
flowId = "YOUR_FLOW_ID",
domain = "YOUR_DOMAIN",
notificationConfig = notificationBranding
)

SmartSipSDK.setListener(yourListener)
</pre>


### 🛡️ Permissions & System Requirements (Android)

The SmartSIP SDK includes all necessary <uses-permission> tags in its own manifest. When you build your project, these are automatically merged into your application's final manifest.

However, the host application is still responsible for requesting these permissions at runtime before a call is initiated.

To simplify integration, the SDK provides a helper property containing all mandatory permissions tailored for the user's current Android API level.
<pre>
// Fetch the required permissions list from the SDK
val permissions = SmartSipSDK.requiredPermissions

// Launch the system permission requester
ActivityCompat.requestPermissions(this, permissions, PERMISSION_REQUEST_CODE)
</pre>

#### The Camera Permission Requirement
Even if your application only supports Audio Calls, the CAMERA permission is included in the SDK's required list.
Note: The underlying SIP engine requires this permission to initialize its media stack correctly. You must request and receive this permission to ensure SDK stability, even if you never intend to use video.

#### ⚠️ Best Practice: "Pre-Flight" Check
Before calling makeCall(), always verify that the permissions are granted. If the user denies these permissions, the SIP registration or audio hardware initialization will fail.

---

## 📞 Managing Calls
You can initiate and terminate calls using the high-level API. The SDK handles the underlying SIP signaling while allowing you to choose between native OS integration or a fully custom UI.

### Discovering Destinations
Before making a call, you can fetch the available queues or destinations configured for your Flow ID. This allows you to build a dynamic list in your UI.

iOS (Swift):

<pre>
// Returns an array of Destination objects
let destinations = await SmartSipSDK.getCallDestinations()
</pre>

Android (Kotlin):

<pre>
// Returns a List of Destination objects via a suspend function or callback
val destinations = SmartSipSDK.getCallDestinations()
</pre>

The `Destination` object provides the following attributes:
* `id`: Unique identifier for the queue.
* `name`: Display name (e.g., "Customer Support").
* `isAvailable`: Boolean status of the destination.

### Outgoing Calls with Custom Metadata
Both platforms support a customParameters dictionary. This is useful for passing contextual data—such as Session IDs, CRM IDs, or Ticket Numbers—that your SIP server needs to process the call.

iOS (Swift):

<pre>
// Initiate an outgoing call with custom metadata
await SmartSipSDK.makeCall(
destinationQueue: "Support_Queue",
callerFullName: "John Doe",
callerPhoneNumber:"0470112233",
customParameters: [
"ticket_id": "12345",
"user_tier": "premium",
"source": "mobile_app"
]
)

// Hang up an active session
SmartSipSDK.hangUp()
</pre>

Android (Kotlin):

<pre>
// Initiate an outgoing call with custom metadata
val metadata = mapOf(
"ticket_id" to "12345",
"user_tier" to "premium",
"source" to "mobile_app"
)

SmartSipSDK.makeCall(
destinationQueue = "Support_Queue",
callerFullName = "John Doe",
callerPhoneNumber = "0470112233",
customParameters = metadata
)

// Hang up an active session
SmartSipSDK.hangUp()
</pre>

#### How Custom Parameters Work:
* SIP Headers: These parameters are injected into the SIP message as custom Headers
* Server-Side Access: Your SIP Proxy or PBX can read these headers
* Format: Keys and values should be standard strings. Avoid using special characters or very long strings to stay within SIP packet size limits.

---

## 📞 Native Dialer vs. Custom UI
The SmartSIP SDK provides the option to bridge your app to the underlying OS Telecom Frameworks (CallKit on iOS, ConnectionService on Android).

### iOS Implementation
The included Demo App provides the flexibility to choose between several integration paths:
* "Blue Dialer" (Custom UI): Demonstrates how to layer a custom SwiftUI interface on top of the native system state.
* Native Dialer: Provides a pure system-native experience.
These options ensure you can leverage the benefits of deep system integration while maintaining complete control over the user experience.

### Android Flexibility
On Android, you can explicitly toggle this behavior in the API. Using the Native Dialer (Telecom Framework) treats your VoIP session as a "real" call at the OS level, which provides:
* Priority: Prevents cellular calls from "cutting off" your audio.
* Hardware Control: Connects Bluetooth and Car buttons (Answer/Hang-up).
* Sync: Links hardware mute/volume buttons to the SIP stream.
If disabled, you have total control over the UI, but you must handle audio focus manually.

[!WARNING]
Android Audio Caution: When using a custom Native Dialer, the system manages ringtones at a high priority. It will ring very loud in your ears! Ensure your volume is moderated during initial testing.

---

## 🎹 DTMF Support (Signaling & IVR)
The SDK provides dual-mode support for DTMF (Press 1 for Stolen Cards, etc.).
System-Native Interface: When using the native OS call screen, DTMF is handled via In-Band Audio and is not sent via data!!.
Custom Dialer: For high-reliability digital signaling, use the SDK's explicit data methods:

<pre>
// iOS
SmartSipSDK.sendDTMF(.one)

// Android
SmartSipSDK.sendDTMF(DTMFButton.ONE)
</pre>

---

## 👂 Listening to Call Events
The SDK uses a Listener (Android) or Delegate (iOS) pattern to provide real-time updates on call progress, quality, and errors.
#### State Descriptions
* Idle - No active call session. The SDK is ready for a new request.
* Connecting - The SIP INVITE has been sent; waiting for the server to acknowledge.
* Ringing - The destination has received the call and is currently alerting.
* Connected - The call is active. Media (audio) session is established.
* Disconnecting - The hang-up command has been sent; the SDK is cleaning up resources.
* Error - The call failed (e.g., Forbidden, Not Found, or Network Timeout).

#### Implementation

iOS (Delegate)
Conform to SmartSipDelegate to receive updates.
<pre>
class CallManager: SmartSipDelegate {
func smartSip(didChangeState state: SmartSipCallState) {
switch state {
case .connected:
print("Talk time!")
case .error(let message):
print("Call failed: (message)")
default: break
}
}
}
</pre>
Android (Listener)
Register a SmartSipListener within your Activity or ViewModel.

<pre>
SmartSipSDK.setListener(object : SmartSipListener {
override fun onStateChanged(state: SmartSipState) {
when (state) {
SmartSipState.CONNECTED -> logger.info("Call established")
is SmartSipState.ERROR -> logger.error("Error: ${state.message}")
else -> {}
}
}
})
</pre>

---

## 🔊 Audio Control
Both platforms share a similar interface for managing the active call session:

Audio Routing:

<pre>
// Route audio to the loud speaker
SmartSipSDK.setSpeakerOn(true)

// Mute the microphone stream
SmartSipSDK.setMicrophoneMuted(true)
</pre>

---

## 🛠 Debugging & SIP Tracing
For troubleshooting connection issues, registration failures, or audio negotiation problems, you can enable verbose debug mode.
What enabling Debug Mode does:
 - Full SIP Traces: Outputs the raw SIP signaling (REGISTER, INVITE, ACK, BYE) directly to the console/Logcat. This is essential for diagnosing server-side rejections or firewall issues.
 - Stack Internal Logs: Provides low-level details regarding the media engine, hardware echo cancellation, and network state changes.
 - Lifecycle Events: Detailed logs regarding the Foreground Service (Android) and CallKit (iOS) transition states.
<pre>
// iOS
SmartSipSDK.setSIPDebugMode(enabled: true)

// Android
SmartSipSDK.setSIPDebugMode(true)
</pre>

---

## 🛡️ Developer Responsibility & Constraints
Connectivity & Network
It is the developer's responsibility to ensure that the device has a stable internet connection (WiFi or Data) before attempting to perform a call. The SDK might fail to register or signal if the network is unreachable.

Runtime Permissions
Developers must ensure all required system permissions are requested and granted by the user before starting the SDK flow.

---

## ⚠️ Limitations & System Behavior
The SDK is pre-configured with specific behaviors to ensure privacy and audio consistency across both platforms:

Call History (Privacy): SIP calls are configured not to show in the "Recents" tab of the native system dialers. This ensures that VoIP sessions remain private and do not clutter the user's standard cellular call logs.

Native Call Precedence: To prevent audio conflicts and prioritize the cellular network, the SDK is configured to automatically hang up the active SIP call if a Native (Cellular) call is ACCEPTED by the user.

---

## 🤖 Android Auto vs. 🍎 iOS Car Play
While we strive for cross-platform parity, architectural differences between Android Auto and iOS CarPlay result in the following inherent limitations:

#### The "UI Bypass" Effect
 * On iOS, CallKit forces the vehicle’s system to treat every VoIP call as a native telephony event, ensuring the car UI takes over the call interface.
 * On Android, the system frequently treats third-party VoIP calls as secondary "Communication" streams rather than primary system calls.

#### The Problem on 🤖 Android Auto:
Many vehicle head units do not trigger the "In-Call" screen for self-managed VoIP sessions.

The Result: The car effectively ignores the call event on its display. This forces the mobile device to handle the call independently, as if it were not connected to the vehicle at all.

---

## 📩 Contact & Support

For technical support, integration inquiries, or to request a **Flow ID** for testing, please reach out to our team:

* **Email:** [info@smartconnect.eu](mailto:info@smartconnect.eu)
* **Website:** [https://smartconnect.eu](https://smartconnect.eu)

---