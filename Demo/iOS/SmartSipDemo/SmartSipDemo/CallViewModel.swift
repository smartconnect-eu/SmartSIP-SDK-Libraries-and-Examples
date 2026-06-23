//
//  CallViewModel.swift
//  SmartSipDemo
//
//  Created by Franz Iacob on 09/01/2026.
//import SwiftUI
import smartsip_sdk
import Combine
import UIKit
import AVFoundation

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
                    CallKitManager.shared.reportFailed()
                }
                
                // Cleanup UI and Hardware
                try? await Task.sleep(nanoseconds: 800_000_000)
                
                UIDevice.current.isProximityMonitoringEnabled = false
                // Standard cleanup
                self.resetCallUI()
                
            default:
                break
            }
        }
    }
    
    func callDidFail(withError error: String) {
        Task { @MainActor in
            self.callStatus = "Error: \(error)"
            self.isCallActive = false
         
            if activeFlow == .callKit {
                        // Signal the failure to the system UI immediately
                        CallKitManager.shared.reportFailed()
                    }
            
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
    @Published var alertMessage: String? = nil
    @Published var isAlertPresented: Bool = false
    
    @Published var activeFlow: CallFlow = .callKit
    @Published var showCustomUI: Bool = false
    
    // Hardware States
    @Published var isMuted: Bool = false
    @Published var isSpeakerOn: Bool = false

    init() {
        SmartSipSDK.initialize(
            token : "xxxx",
            flowId : "yyy",
            domain : "zzz",
        )
        
        SmartSipSDK.setSIPDebugMode(enabled: true)
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
            do
            {
                let targets = try await SmartSipSDK.getCallDestinations()
                self.destinations = targets
                if let first = targets.first {
                    self.selectedDestination = first
                }
            }catch{
                self.destinations = [];
                await MainActor.run {
                    let alert = UIAlertController(title: "Error fetching call destinations", message: error.localizedDescription, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    
                    // Find the top controller and present
                    if let topController = UIApplication.shared.connectedScenes
                        .compactMap({ $0 as? UIWindowScene })
                        .flatMap({ $0.windows })
                        .first(where: { $0.isKeyWindow })?.rootViewController {
                        
                        var current = topController
                        while let presented = current.presentedViewController {
                            current = presented
                        }
                        current.present(alert, animated: true)
                    }
                }
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

        Task { @MainActor in
            let granted = await requestMicrophonePermissionIfNeeded()
            guard granted else {
                let message = "Microphone permission is required to start a call. Please enable it in Settings."
                self.callStatus = "Error: \(message)"
                self.presentAlert(message)
                return
            }
            self.launchCallFlow()
        }
    }

    private func requestMicrophonePermissionIfNeeded() async -> Bool {
        let session = AVAudioSession.sharedInstance()
        switch session.recordPermission {
        case .granted:
            return true
        case .undetermined:
            return await withCheckedContinuation { continuation in
                session.requestRecordPermission { granted in
                    continuation.resume(returning: granted)
                }
            }
        case .denied:
            return false
        @unknown default:
            return false
        }
    }

    private func launchCallFlow() {
        
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
            do {
                let session = try await SmartSipSDK.createSessionOrThrow(
                    clientData: clientData,
                    destinationQueue: selectedDestination,
                    callerPhoneNumber: userPhoneNumber.isEmpty ? nil : userPhoneNumber,
                    callerFullName: userFullName.isEmpty ? nil : userFullName
                )

                // Async checkpoint: run validations/waits/backend checks here.
                await SmartSipSDK.makeCall(session)
            } catch {
                await MainActor.run {
                    self.callStatus = "Error: \(error.localizedDescription)"
                    self.isCallActive = false
                }
                if self.activeFlow == .callKit {
                    CallKitManager.shared.reportFailed()
                }
            }
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

    private func presentAlert(_ message: String) {
        alertMessage = message
        isAlertPresented = true
    }
        
}
