//
//  CallViewModel.swift
//  SmartSipTest
//
//  Created by Franz Iacob on 09/01/2026.
//

import SwiftUI
import smartsip_sdk // Make sure to import your framework
import SwiftUI
import smartsip_sdk
internal import Combine

@MainActor
class CallViewModel: ObservableObject { // Remove Delegate here for a moment
    
    @Published var callStatus: String = "Idle"
    @Published var isCallActive: Bool = false
    
    private let sdk = SmartSipSDK.shared

    init() {
        // We set the delegate below
        sdk.initialize(token: "SS_SA_ZBuDfr7dDD4gF8cJ", flowId: "DF00683B-181D-5665-9AE0-41133D6F9D74", domain: "webrtc.smartcall.cc")
        sdk.setSIPDebugMode(enabled: true)
        
        // This is the key: set the delegate AFTER initialization
        sdk.setDelegate(self)
    }

    func startTestCall() {
        callStatus = "Creating Session..."
        Task {
            await sdk.makeCall(
                destinationQueue: "default", userFullName: "Franz Iacob"
            )
        }
    }

    func endTestCall() {
        sdk.hangUp() // Using the public method we just commented!
        isCallActive = false
        callStatus = "Hanging up..."
    }
}

// Move the delegate to an extension to make conformance clear to the compiler
extension CallViewModel: CallDelegate {
    
    func callDidChangeState(_ state: CallState) {
        // Since we are on @MainActor, this UI update is safe
        self.callStatus = "State: \(state)"
        
        if state == .connected {
            isCallActive = true
        } else if state == .disconnected || state == .loggedOut {
            isCallActive = false
        }
    }

    func callDidFail(withError error: String) {
        self.callStatus = "Error: \(error)"
        self.isCallActive = false
    }
}
