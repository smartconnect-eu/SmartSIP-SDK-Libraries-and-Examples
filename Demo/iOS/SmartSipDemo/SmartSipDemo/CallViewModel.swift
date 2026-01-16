//
//  CallViewModel.swift
//  SmartSipDemo
//
//  Created by Franz Iacob on 09/01/2026.
//
import SwiftUI
import smartsip_sdk
import Combine

enum CallFlow {
    case callKit, customUI
}

@MainActor
class CallViewModel: ObservableObject {
    
    @Published var callStatus: String = "Idle"
    @Published var isCallActive: Bool = false
    @Published var destinations: [String] = []
    @Published var selectedDestination: String = ""
    
    @Published var userFullName: String = ""
    @Published var userPhoneNumber: String = ""
    @Published var clientDataString: String = ""
    @Published var jsonErrorMessage: String? = nil
    
    @Published var activeFlow: CallFlow = .callKit
    @Published var showCustomUI: Bool = false

    init() {
        // 1. Setup SDK basic config
        SmartSipSDK.initialize(
            token: "SS_SA_ZBuDfr7dDD4gF8cJ",
            flowId: "DF00683B-181D-5665-9AE0-41133D6F9D74",
            domain: "webrtc.smartcall.cc"
        )
        SmartSipSDK.setSIPDebugMode(enabled: false)
        SmartSipSDK.setDelegate(self)
        
        // 2. Fetch available targets
        fetchDestinations()
    }

    private func fetchDestinations() {
        Task {
            let targets = await SmartSipSDK.getCallDestinations()
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
        let clientData = parseClientData()
        
        if activeFlow == .customUI {
                    self.showCustomUI = true
                }
        
        Task {
            // Give the UI a frame to appear before hitting the CPU with SDK init
            try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
            // Passing the selected destination to the SDK
            await SmartSipSDK.makeCall(
                clientData: clientData,
                destinationQueue: selectedDestination,
                callerPhoneNumber: userPhoneNumber.isEmpty ? nil : userPhoneNumber,
                callerFullName: userFullName.isEmpty ? nil : userFullName)
        }
    }

    func endTestCall() {
        // 1. Tell SDK to hang up
        SmartSipSDK.hangUp()
        
        // 2. Local cleanup
        isCallActive = false
        callStatus = "Disconnected"
        
        // 3. Dismiss the blue dialer immediately
        if showCustomUI {
            self.showCustomUI = false
        }
    }
    
    private func parseClientData() -> [String: Any]? {
        jsonErrorMessage = nil
        guard !clientDataString.trimmingCharacters(in: .whitespaces).isEmpty else { return nil }
        
        guard let data = clientDataString.data(using: .utf8) else { return nil }
        
        do {
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                jsonErrorMessage = nil
                return json
            }
        } catch {
            jsonErrorMessage = "Invalid JSON format"
        }
        return nil
    }
}

extension CallViewModel: CallDelegate {
    func callDidChangeState(_ state: CallState) {
            Task { @MainActor in
                self.callStatus = "State: \(state.rawValue)"
                
                switch state {
                case .connected:
                    self.isCallActive = true
                    
                case .failed, .disconnected, .loggedOut:
                    // Terminal states: Reset status and hide the dialer
                    self.isCallActive = false
                    
                    // We add a tiny delay so the user can actually see "Failed"
                    // for a split second before the screen slides away
                    try? await Task.sleep(nanoseconds: 800_000_000) // 0.8 seconds
                    self.showCustomUI = false
                    
                default:
                    break
                }
            }
        }

    func callDidFail(withError error: String) {
        self.callStatus = "Error: \(error)"
        self.isCallActive = false
    }
}
