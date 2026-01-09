//
//  SmartSipSDK+internal.swift
//  smartsip-sdk
//
//  Created by Franz Iacob on 08/01/2026.
//

import Foundation
import os

public final class SmartSipSDK {
    
    public static let shared = SmartSipSDK()
    
    internal var isInitialized = false
    internal var token: String!
    internal var flowId: String!
    internal var domain: String!
    ///Sip core reference
    var sipCore: PhoneCore!
   
    
    private init() {
        sipCore = PhoneCore();
    }
    
    public func  setDelegate(_ delegate: CallDelegate) {
        sipCore.setDelegate(delegate)
    }
    
    // MARK: - Models
    
    public typealias CallDestination = String
    
    // MARK: - Public API
    /// Initializes the SDK with the required middleware credentials.
    public func initialize(token: String!, flowId: String!, domain: String!) {
        if isInitialized {
            Logger.sdk.warning("The SmartSipSDK was already initialized!!! Re-initialization in progress")
        }
        
        Logger.sdk.info("SDK Initializing with token: \(token ?? "nil", privacy: .private) flowId: \(flowId ?? "nil", privacy: .private) domain: \(domain ?? "nil", privacy: .public)")

        self.token = token
        self.flowId = flowId
        self.domain = domain
        isInitialized = true
    }
    
    /**
     Retrieves authorized call targets from the middleware
     
     This function initiates a connection with the server. Upon a successful handshake,
     it returns a list of identifiers that the current user is permitted to dial.
     
     - Note: Ensure the network is reachable before calling this method.
     - Returns: An array of `CallDestination` strings representing available peers.
     */
    public func getCallDestinations() async -> [CallDestination] {
        return await performGetCallDestinations()
    }
    
    /**
     Retrieves authorized call targets from the middleware
     
     This function initiates a connection with the server. Upon a successful handshake,
     it returns a list of identifiers that the current user is permitted to dial.
     
     - Note: Ensure the network is reachable before calling this method.
     - Returns: An array of `CallDestination` strings representing available peers.
     */
    public func makeCall(
            clientData: [String: Any]? = nil,
            destinationQueue: String? = nil,
            phoneNumber: String? = nil,
            userFullName: String? = nil,
            otherRoutingData: [String: Any]? = nil
        ) async {
            //Create the session first
            guard var callInfo = await performCreateSession(
                clientData: clientData,
                destinationQueue: destinationQueue,
                phoneNumber: phoneNumber,
                userFullName: userFullName,
                otherRoutingData: otherRoutingData
            ) else {
                Logger.sdk.error("❌ makeCall failed: Could not establish Smartconnect session.")
                return
            }
            
            callInfo.callerFullName = userFullName
            // 2. Use the session result to perform the actual SIP call
            await performSIPCall(with: callInfo)
        }
    
    /**
     Terminates the active call session and unregisters the user from the SIP server.
    
     This is the primary method for ending a communication session. It performs a two-step teardown:
     1. Sends a `BYE` or `CANCEL` request to the remote peer to hang up the call.
     2. Disconnects from the SIP proxy and clears the account credentials from memory.
     
     - Note: Use this method for a "clean slate" exit. After calling this, you must call `makeCall` again to re-register and start a new session.
     */
    public func hangUp() {
        // Triggers the internal SIP core to terminate media and unregister.
        sipCore.terminateCallAndLogout()
    }
    
    /// Configures the verbosity of the underlying SIP stack logs.
    /// - Parameter enabled: If true, the SDK will output detailed debug information.
    ///   If false, only critical errors will be logged.
    public func setSIPDebugMode(enabled: Bool) {
        sipCore.setDebugMode(enabled: enabled);
    }
    
  
    
}
