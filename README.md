# SmartSIP SDK: Unified Mobile VoIP

A professional-grade, wrapper-based VoIP SDK for SIP communication. This SDK is designed to handle complex signaling and hardware optimization while providing simple, modern interfaces for both iOS and Android.

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
3. Version: `0.0.74` or higher.

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

2. Dependency & Java 17 Support
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
    implementation("cc.smartconnect:smartsip-sdk:0.0.74")
}
</pre>

🚀 Quick Start
On Android, you must provide a SmartSipNotificationConfig. This branding is used by the Foreground Service to maintain the call session and prevent the OS from killing the app.

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

Required Permissions :
Depending on the Android version, your app may need to request these at runtime:

RECORD_AUDIO: For microphone access.
POST_NOTIFICATIONS: Required for Android 13+ to show the mandatory foreground service notification.
READ_PHONE_STATE / MANAGE_OWN_CALLS: Required for the Native Dialer / Telecom Framework integration.

---

## 📞 Managing Calls
You can initiate and terminate calls using the high-level API. The SDK handles the underlying SIP signaling and Native Dialer integration automatically.
Outgoing Calls with Custom Metadata
Both platforms support a customParameters dictionary. This is useful for passing contextual data—such as Session IDs, CRM IDs, or Ticket Numbers—that your SIP server needs to process the call.

iOS (Swift):

<pre>
// Initiate an outgoing call with custom metadata
await SmartSipSDK.makeCall(
destinationQueue: "Support_Queue",
callerFullName: "John Doe",
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
customParameters = metadata
)

// Hang up an active session
SmartSipSDK.hangUp()
</pre>

How Custom Parameters Work:
SIP Headers: These parameters are injected into the SIP INVITE message as custom X-Headers (e.g., X-ticket-id: 12345).
Server-Side Access: Your SIP Proxy or PBX can read these headers to route the call intelligently or display information to an agent.
Format: Keys and values should be standard strings. Avoid using special characters or very long strings to stay within SIP packet size limits.

---

## 📞 The Native Dialer Experience (Android vs iOS)
The SmartSIP SDK bridges your app to the underlying OS Telecom Frameworks (CallKit on iOS, ConnectionService on Android). This treats your VoIP session as a "real" call rather than simple media.

Why this is Essential:
Priority: Prevents cellular calls from "cutting off" or overriding your active VoIP audio.
Hardware Control: Connects Bluetooth headsets and Car buttons (Answer/Hang-up) directly to your app.
Sync: Links system-wide hardware mute and volume controls directly to your SIP stream.
Stability: Prevents the OS from killing your app's process during long background calls.

[!WARNING]
Android Audio Caution: When using a custom Native Dialer, the system manages ringtones at a high priority. It will ring very loud in your ears! Ensure your volume is moderated during initial testing.

---

## 🎹 DTMF Support (Signaling & IVR)
The SDK provides dual-mode support for DTMF (Press 1 for Sales, etc.).
System-Native Interface: When using the native OS call screen, DTMF is handled via In-Band Audio.
Custom Dialer: For high-reliability digital signaling, use the SDK's explicit data methods:

<pre>
// iOS
SmartSipSDK.sendDTMF(.one)

// Android
SmartSipSDK.sendDTMF(DTMFButton.ONE)
</pre>

---

## 📋 Delegate / Listener Handling
iOS (CallDelegate):

<pre>
extension YourViewModel: CallDelegate {
func callDidChangeState(_ state: CallState) {
if state == .connected { /* Update UI */ }
}
}
</pre>

Android (CallListener):

<pre>
class YourViewModel : CallListener {
override fun onCallStateChanged(state: CallState) {
if (state == CallState.CONNECTED) { /* Update UI */ }
}
}
</pre>

---

## 🔊 Audio & DTMF Control
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
It is the developer's responsibility to ensure that the device has a stable internet connection (WiFi or Data) before attempting to perform a call. The SDK will fail to register or signal if the network is unreachable.

Runtime Permissions
Developers must ensure all required system permissions are requested and granted by the user before starting the SDK flow.
