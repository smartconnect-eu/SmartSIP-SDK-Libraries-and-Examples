//
//  CallViewModel.swift
//  SmartSipDemo
//
//  Created by Franz Iacob on 09/01/2026.
//import SwiftUI
import smartsip_sdk
import Combine
import UIKit

enum CallFlow {
    case callKit, customUI
}

@MainActor
class CallViewModel: ObservableObject, CallDelegate {
    // MARK: - CallDelegate
    func callDidChangeState(_ state: smartsip_sdk.CallState) {
        Task { @MainActor in
            self.callStatus = "State: \(state.rawValue)"
            
            switch state {
            case .dialing:
                // 1. Tell iOS we are currently attempting to connect
                if activeFlow == .callKit {
                    CallKitManager.shared.reportConnecting()
                }
                
            case .connected:
                self.isCallActive = true
                // 2. Tell iOS the call is now live (triggers the Green Pill/Status Bar)
                if activeFlow == .callKit {
                    CallKitManager.shared.reportConnected()
                }
                
            case .failed, .disconnected, .loggedOut:
                self.isCallActive = false
                
                // 3. Tell CallKit the session is over so the native UI disappears
                if activeFlow == .callKit {
                    CallKitManager.shared.reportEndFromServer()
                }
                
                // Cleanup UI and Hardware
                try? await Task.sleep(nanoseconds: 800_000_000)
                
                UIDevice.current.isProximityMonitoringEnabled = false
                self.showCustomUI = false
                
                // Reset hardware toggles for next call
                self.isMuted = false
                self.isSpeakerOn = false
                
            default:
                break
            }
        }
    }
    
    func callDidFail(withError error: String) {
        Task { @MainActor in
               self.callStatus = "Error: \(error)"
               self.isCallActive = false
               try? await Task.sleep(nanoseconds: 1_500_000_000)
               self.showCustomUI = false
       }
    }
    
    
    // MARK: - members
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
    
    // Hardware States
    @Published var isMuted: Bool = false
    @Published var isSpeakerOn: Bool = false

    init() {
        SmartSipSDK.initialize(
            token: "SS_SA_ZBuDfr7dDD4gF8cJ",
            flowId: "DF00683B-181D-5665-9AE0-41133D6F9D74",
            domain: "webrtc.smartcall.cc"
        )
        SmartSipSDK.setSIPDebugMode(enabled: false)
        SmartSipSDK.setDelegate(self)
        // --- Add CallKit Callbacks ---
        CallKitManager.shared.onMuteToggle = { [weak self] isMuted in
            Task { @MainActor in
                self?.isMuted = isMuted
            }
        }
        CallKitManager.shared.onEndCall = { [weak self] in
            Task { @MainActor in
                self?.resetCallUI()
            }
        }
        //
        fetchDestinations()
    }

    private func fetchDestinations() {
        Task {
            let targets = await SmartSipSDK.getCallDestinations()
            self.destinations = targets
            if let first = targets.first {
                self.selectedDestination = first
            }
        }
    }

    // Hardware Controls calling SDK
    func toggleMute() {
        isMuted.toggle()
        SmartSipSDK.setMicrophoneMuted(isMuted)
    }

    func toggleSpeaker() {
        isSpeakerOn.toggle()
        SmartSipSDK.setSpeakerOn(isSpeakerOn)
    }

    func startTestCall() {
        guard !selectedDestination.isEmpty else {
            callStatus = "Error: No destination selected"
            return
        }
        
        callStatus = "Creating Session..."
        let clientData = parseClientData()
        
        if activeFlow == .customUI {
            //Enable Proximity Sensor for Custom UI
            UIDevice.current.isProximityMonitoringEnabled = true
            self.showCustomUI = true
        }
        else
        {
            // Native Flow: Ask CallKit to start the call
            // CallKit will handle the UI and Audio Session
            // here you can change what is shown to the user according to the business decision. It is not mandatory to match the SIP data
            CallKitManager.shared.startCall(
                handle: selectedDestination,
                displayName: userFullName.isEmpty ? selectedDestination : userFullName
            )
        }
        //start the SIP call
        Task {
            try? await Task.sleep(nanoseconds: 100_000_000)
            await SmartSipSDK.makeCall(
                clientData: clientData,
                destinationQueue: selectedDestination,
                callerPhoneNumber: userPhoneNumber.isEmpty ? nil : userPhoneNumber,
                callerFullName: userFullName.isEmpty ? nil : userFullName)
        }
    }

    func endTestCall() {
        if activeFlow == .customUI
        {
            SmartSipSDK.hangUp()
            resetCallUI()
        }
        else {
            // Tell CallKit to end the call, which will trigger our CXProviderDelegate hangUp
            CallKitManager.shared.endCall()
            resetCallUI()
        }
    }
    
    func resetCallUI() {
        UIDevice.current.isProximityMonitoringEnabled = false
        isCallActive = false
        isMuted = false
        isSpeakerOn = false
        callStatus = "Disconnected"
        if showCustomUI {
            self.showCustomUI = false
        }
    }
    
    func parseClientData() -> [String: Any]? {
        jsonErrorMessage = nil
        guard !clientDataString.trimmingCharacters(in: .whitespaces).isEmpty else { return nil }
        guard let data = clientDataString.data(using: .utf8) else { return nil }
        do {
            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            return json
        } catch {
            jsonErrorMessage = "Invalid JSON format"
            return nil
        }
    }
        
}
