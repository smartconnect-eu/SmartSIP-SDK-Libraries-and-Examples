# SmartSipSDK

A high-level Swift SDK for SIP-based VoIP and messaging, powered by the Linphone stack. This SDK simplifies registration, call handling, and logging for iOS applications.

## Features

- **Easy Registration:** Simplified login/logout states.
- **Call Management:** High-level abstractions for dialing, ringing, and connected states.
- **Debug Logging:** Toggleable SIP stack logs for easy troubleshooting.
- **Modern Swift:** Built with Swift 5.9+ and supports iOS 15.0+.

---

## Installation

### Swift Package Manager (Recommended)

1. In Xcode, go to **File > Add Packages...**
2. Enter the repository URL: `https://github.com/your-org/smartsip-sdk-mirror.git`
3. Select the version you wish to use (e.g., `1.0.0`).
4. Click **Add Package**.

> **Note:** `SmartSipSDK` automatically includes the `Linphone-SDK` as a dependency. Xcode will resolve and download it automatically.

---
## Quick Start

### 1. Initialize the Service
Create an instance of the `CallService` to manage your SIP lifecycle.

```swift
import smartsip_sdk

let callService = CallService()