//
//  CallKitManager.swift
//  SmartSipDemo
//
//  Created by Franz Iacob on 19/01/2026.
//

import Foundation
import CallKit
import smartsip_sdk

class CallKitManager: NSObject, CXProviderDelegate {
    static let shared = CallKitManager()
    private let provider: CXProvider
    private let callController = CXCallController()
    
    // We store a reference to the active call UUID
    private var currentCallUUID: UUID?
    
   var onMuteToggle: ((Bool) -> Void)?
   var onEndCall: (() -> Void)?

    override init() {
        let configuration = CXProviderConfiguration()
        configuration.supportsVideo = false
        configuration.maximumCallGroups = 1
        configuration.maximumCallsPerCallGroup = 1
        configuration.supportedHandleTypes = [.phoneNumber]
        
        provider = CXProvider(configuration: configuration)
        super.init()
        provider.setDelegate(self, queue: nil)
    }

    // MARK: - Actions
    func startCall(handle: String, displayName: String) {
        let uuid = UUID()
        self.currentCallUUID = uuid
        let handle = CXHandle(type: .phoneNumber, value: handle)
        let startCallAction = CXStartCallAction(call: uuid, handle: handle)
        startCallAction.contactIdentifier = displayName
        
        let transaction = CXTransaction(action: startCallAction)
        callController.request(transaction) { error in
            if let error = error {
                print("Error requesting transaction: \(error)")
            }
        }
    }

    func endCall() {
        guard let uuid = currentCallUUID else { return }
        let endCallAction = CXEndCallAction(call: uuid)
        let transaction = CXTransaction(action: endCallAction)
        callController.request(transaction) { _ in }
    }
    
    // MARK: - Reporting
    /// Reports to iOS that the outgoing call has started connecting to the server.
    func reportConnecting() {
        guard let uuid = currentCallUUID else { return }
        provider.reportOutgoingCall(with: uuid, startedConnectingAt: nil)
    }

    /// Reports to iOS that the call is now active (audio is flowing).
    func reportConnected() {
        guard let uuid = currentCallUUID else { return }
        provider.reportOutgoingCall(with: uuid, connectedAt: nil)
    }

    /// Reports that the call ended from the remote side (not the user).
    func reportEndFromServer() {
        guard let uuid = currentCallUUID else { return }
        provider.reportCall(with: uuid, endedAt: nil, reason: .remoteEnded)
        currentCallUUID = nil
    }
    
    /// Reports to iOS that the call failed to connect.
    func reportFailed() {
        guard let uuid = currentCallUUID else { return }
        // Reporting .failed makes the system UI turn red/show "Call Failed" before dismissing
        provider.reportCall(with: uuid, endedAt: nil, reason: .failed)
        currentCallUUID = nil
    }

    // MARK: - CXProviderDelegate
    func providerDidReset(_ provider: CXProvider) {
        currentCallUUID = nil
    }

    func provider(_ provider: CXProvider, perform action: CXStartCallAction) {
        // IMPORTANT: This is where we tell the system the call has started
        // In a real app, you wait for the SIP 'connected' state to fulfill,
        // but for now, we fulfill to allow the system to open the audio channel.
        action.fulfill()
    }

    func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
        // Tell the SDK to hang up when the user clicks 'End' on the native UI
        SmartSipSDK.hangUp()
        onEndCall?()
        action.fulfill()
        currentCallUUID = nil
    }

    func provider(_ provider: CXProvider, perform action: CXSetMutedCallAction) {
        SmartSipSDK.setMicrophoneMuted(action.isMuted)
        onMuteToggle?(action.isMuted)
        action.fulfill()
    }
}
