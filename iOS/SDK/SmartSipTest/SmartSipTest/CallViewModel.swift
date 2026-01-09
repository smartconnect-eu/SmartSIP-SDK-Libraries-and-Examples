//
//  CallViewModel.swift
//  SmartSipTest
//
//  Created by Franz Iacob on 09/01/2026.
//
import SwiftUI
import smartsip_sdk
import Combine

@MainActor
class CallViewModel: ObservableObject {
    
    @Published var callStatus: String = "Idle"
    @Published var isCallActive: Bool = false
    @Published var destinations: [String] = []
    @Published var selectedDestination: String = ""
    
    private let sdk = SmartSipSDK.shared

    init() {
        // 1. Setup SDK basic config
        sdk.initialize(
            token: "SS_SA_ZBuDfr7dDD4gF8cJ",
            flowId: "DF00683B-181D-5665-9AE0-41133D6F9D74",
            domain: "webrtc.smartcall.cc"
        )
        sdk.setSIPDebugMode(enabled: false)
        sdk.setDelegate(self)
        
        // 2. Fetch available targets
        fetchDestinations()
    }

    private func fetchDestinations() {
        Task {
            let targets = await sdk.getCallDestinations()
            self.destinations = targets
            // Default to first destination if available
            if let first = targets.first {
                self.selectedDestination = first
            }
        }
    }

    func startTestCall() {
        guard !selectedDestination.isEmpty else {
            callStatus = "Error: No destination selected"
            return
        }
        
        callStatus = "Creating Session..."
        Task {
            // Passing the selected destination to the SDK
            await sdk.makeCall(
                destinationQueue: selectedDestination,
                userFullName: "Franz Iacob"
            )
        }
    }

    func endTestCall() {
        sdk.hangUp()
        isCallActive = false
        callStatus = "Hanging up..."
    }
}

extension CallViewModel: CallDelegate {
    func callDidChangeState(_ state: CallState) {
        self.callStatus = "State: \(state)"
        
        // Note: adjust state checks based on your SDK's specific enum names
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
