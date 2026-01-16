//
//  SmartSipSDK.swift
//  smartsip-sdk
//
//  Created by Franz Iacob on 08/01/2026.
//

import Foundation
import os

public final class SmartSipSDK {
    
    /// The current version of the SDK.
    public static let sdkVersion = "0.0.19"
    
    private static let shared = SmartSipSDK()
    
    // Changed internal storage to standard optionals to avoid ABI issues
    internal static var isInitialized = false
    internal static var token: String?
    internal static var flowId: String?
    internal static var domain: String?
    
    /// Sip core reference
    var sipCore: PhoneCore
   
    private init() {
        sipCore = PhoneCore()
    }
    
    /// Assigns a delegate to listen for call state changes and errors.
    public static func setDelegate(_ delegate: CallDelegate) {
        shared.sipCore.setDelegate(delegate)
    }
    
    // MARK: - Models
    
    public typealias CallDestination = String
    
    // MARK: - Public API
    
    /**
     Initializes the SDK with the required middleware credentials.
     
     - Parameters:
        - token: The security token for authentication.
        - flowId: The identifier for the specific call flow.
        - domain: The server domain address.
     */
    public static func initialize(token: String, flowId: String, domain: String) {
        if SmartSipSDK.isInitialized {
            Logger.sdk.warning("The SmartSipSDK was already initialized!!! Re-initialization in progress")
        }
        
        Logger.sdk.info("SDK Initializing with token: \(token, privacy: .private) flowId: \(flowId, privacy: .private) domain: \(domain, privacy: .public)")

        SmartSipSDK.token = token
        SmartSipSDK.flowId = flowId
        SmartSipSDK.domain = domain
        SmartSipSDK.isInitialized = true
    }
    
    /**
     Retrieves authorized call targets from the middleware.
     
     - Returns: An array of `CallDestination` strings representing available peers.
     */
    @discardableResult
    public static func getCallDestinations() async -> [CallDestination] {
        return await shared.performGetCallDestinations()
    }
    
    /**
     Initiates a VoIP call session.
     
     - Parameters:
        - clientData: Optional metadata to attach to the call.
        - destinationQueue: The specific queue to route the call to.
        - callerPhoneNumber: The phone number to display to the recipient.
        - callerFullName: The name to display to the recipient.
        - otherRoutingData: Additional key-value pairs for routing logic.
     */
    public static func makeCall(
        clientData: [String: Any]? = nil,
        destinationQueue: String? = nil,
        callerPhoneNumber: String? = nil,
        callerFullName: String? = nil,
        otherRoutingData: [String: Any]? = nil
    ) async {
        // 1. Create the session first
        guard var callInfo = await shared.performCreateSession(
            clientData: clientData,
            destinationQueue: destinationQueue,
            callerPhoneNumber: callerPhoneNumber,
            callerFullName: callerFullName,
            otherRoutingData: otherRoutingData
        ) else {
            Logger.sdk.error("❌ makeCall failed: Could not establish Smartconnect session.")
            return
        }
        
        callInfo.callerFullName = callerFullName
        
        // 2. Use the session result to perform the actual SIP call
        await shared.performSIPCall(with: callInfo)
    }
    
    /**
     Terminates the active call session and unregisters the user from the SIP server.
     */
    public static func hangUp() {
        shared.sipCore.terminateCallAndLogout()
    }
    
    /**
     Configures the verbosity of the underlying SIP stack logs.
     
     - Parameter enabled: If true, outputs detailed logs; if false, only critical errors.
     */
    public static func setSIPDebugMode(enabled: Bool) {
        shared.sipCore.setDebugMode(enabled: enabled)
    }
}
