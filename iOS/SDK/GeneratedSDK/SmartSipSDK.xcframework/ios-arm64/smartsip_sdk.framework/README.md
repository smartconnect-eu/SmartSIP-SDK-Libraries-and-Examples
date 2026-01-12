# SmartSip SDK

SmartSip is a lightweight, secure Swift framework for handling singular audio calls via SIP. It manages the complex lifecycle of SIP registration and call signaling, providing a simple interface for developers.

---

## 🚀 Mandatory Integration Steps

To prevent runtime crashes and ensure call stability in the background, the host application **must** be configured with the following permissions and capabilities.

### 1. Info.plist Keys (Privacy)
iOS requires explicit descriptions for hardware access. If these keys are missing, the app will **crash** as soon as the SDK initializes the audio engine.

- **Microphone Usage:** `NSMicrophoneUsageDescription`  
  *Suggested Value:* "This app requires microphone access to make SIP calls."
- **Camera Usage (Optional):** `NSCameraUsageDescription`  
  *Suggested Value:* "This app requires camera access for video calling."

### 2. Background Modes (Capabilities)
To maintain the SIP connection and audio stream when the user locks the screen or moves the app to the background, you must enable the Background Modes capability. 

1.  Select your **Project** in the Project Navigator.
2.  Select your **App Target** > **Signing & Capabilities**.
3.  Click the **+ Capability** button (top left).
4.  Search for **"Background Modes"** and double-click it to add the section to your project.
5.  In the new **Background Modes** section that appears in your target settings, check the following:
    * [x] **Audio, AirPlay, and Picture in Picture** (Required for the media stream)
    * [x] **Voice over IP** (Ensures SIP signaling stability)
