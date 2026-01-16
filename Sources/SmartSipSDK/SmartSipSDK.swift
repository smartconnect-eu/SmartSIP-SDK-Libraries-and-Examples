//
//  SmartSipSDK.swift
//  smartsip-sdk
//
//  Created by Franz Iacob on 08/01/2026.
//

import Foundation

/// Delegate protocol to receive updates regarding call states and errors.
public protocol CallDelegate: AnyObject {
    /// Called when the call state changes.
    /// - Parameter state: The new state of the call.
    func callDidChangeState(_ state: CallState)
    
    /// Called when a call or operation fails.
    /// - Parameter error: A string describing the failure.
    func callDidFail(withError error: String)
}

/// Represents the possible states of a VoIP call session.
public enum CallState: String {
    case loginInProgress, loggedIn, loggedOut, dialing, ringing, connected, held, disconnected, failed
}

/// The main entry point for the SmartSip SDK.
public final class SmartSipSDK {
    
    /// The current version of the SDK.
    public static let sdkVersion = "0.0.33"
    
    /// Assigns a delegate to listen for call state changes and errors.
    /// - Parameter delegate: An object conforming to CallDelegate.
    public static func setDelegate(_ delegate: CallDelegate) {
        // Implementation hidden in binary
    }
    
    /// A string representing the destination identifier for a call.
    public typealias CallDestination = String
    
    /**
     Initializes the SDK with the required middleware credentials.
     
     - Parameters:
        - token: The security token for authentication.
        - flowId: The identifier for the specific call flow.
        - domain: The server domain address.
     */
    public static func initialize(token: String, flowId: String, domain: String) {
        // Implementation hidden in binary
    }
    
    /**
     Retrieves authorized call targets from the middleware.
     
     - Returns: An array of `CallDestination` strings representing available peers.
     */
    @discardableResult
    public static func getCallDestinations() async -> [CallDestination] {
        return [] // Implementation hidden in binary
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
        // Implementation hidden in binary
    }
    
    /**
     Terminates the active call session and unregisters the user from the SIP server.
     */
    public static func hangUp() {
        // Implementation hidden in binary
    }
    
    /**
     Configures the verbosity of the underlying SIP stack logs.
     
     - Parameter enabled: If true, outputs detailed logs; if false, only critical errors.
     */
    public static func setSIPDebugMode(enabled: Bool) {
        // Implementation hidden in binary
    }
}
