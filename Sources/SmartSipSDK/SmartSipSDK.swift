//
//  SmartSipSDK.swift
//  smartsip-sdk
//
//  Created by Franz Iacob on 08/01/2026.
//

import Foundation

/// Delegate protocol to receive real-time updates regarding call states and errors.
public protocol CallDelegate: AnyObject {
    /// Called whenever the call state transitions (e.g., from dialing to connected).
    func callDidChangeState(_ state: CallState)
    
    /// Called when an operation fails or a call is interrupted by an error.
    func callDidFail(withError error: String)
}

/// Represents the possible states of a VoIP call session.
public enum CallState: String {
    case loginInProgress, loggedIn, loggedOut, dialing, ringing, connected, held, disconnected, failed
}

/// The main entry point for the SmartSip VoIP SDK.
///
/// This class provides high-level methods to initialize the service, manage call sessions,
/// and control hardware routing such as speakerphone and microphone states.
public final class SmartSipSDK {
    
    /// The current semantic version of the SmartSip SDK.
    public static let sdkVersion = "0.0.37"
    
    /// Assigns a delegate to receive real-time call state updates and error notifications.
    /// - Parameter delegate: An object conforming to `CallDelegate`.
    public static func setDelegate(_ delegate: CallDelegate) {}
    
    /// Represents a valid destination identifier (e.g., an extension or queue name).
    public typealias CallDestination = String
    
    /**
     Initializes the SDK with the required middleware credentials.
     
     Call this method once at app launch before attempting to fetch destinations or initiate calls.
     
     - Parameters:
        - token: The security token for authentication with the SmartConnect middleware.
        - flowId: The UUID or identifier for the specific business call flow.
        - domain: The server domain address (e.g., "webrtc.smartcall.cc").
     */
    public static func initialize(token: String, flowId: String, domain: String) {}
    
    /**
     Retrieves a list of authorized call targets from the middleware.
     
     - Returns: A collection of `CallDestination` strings representing available queues or agents.
     */
    @discardableResult
    public static func getCallDestinations() async -> [CallDestination] { return [] }
    
    /**
     Initiates an outgoing VoIP call session.
     
     This method first establishes a session with the SmartConnect middleware before triggering the SIP stack.
     
     - Parameters:
        - clientData: A dictionary of custom metadata to be attached to the session (e.g., CRM IDs).
        - destinationQueue: The target queue or peer for the call.
        - callerPhoneNumber: The E.164 formatted number to be displayed to the recipient.
        - callerFullName: The display name for the caller.
        - otherRoutingData: Additional key-value pairs used for custom routing logic.
     */
    public static func makeCall(
        clientData: [String: Any]? = nil,
        destinationQueue: String? = nil,
        callerPhoneNumber: String? = nil,
        callerFullName: String? = nil,
        otherRoutingData: [String: Any]? = nil
    ) async {}
    
    /**
     Terminates the active call session and unregisters the client from the SIP server.
     
     Call this to hang up or cancel an invitation in progress.
     */
    public static func hangUp() {}
    
    /**
     Toggles the microphone mute state during an active call.
     
     - Parameter muted: If `true`, the microphone is silenced and no audio is transmitted to the peer.
     */
    public static func setMicrophoneMuted(_ muted: Bool) {}
    
    /**
     Toggles the audio output between the internal earpiece and the loud speaker.
     
     - Parameter isSpeakerOn: If `true`, audio is routed to the device's loud speaker.
     */
    public static func setSpeakerOn(_ isSpeakerOn: Bool) {}
    
    /**
     Configures the verbosity of the underlying SIP stack logs.
     
     - Note: Enable this during development to troubleshoot signaling or network issues.
     - Parameter enabled: Set to `true` to output detailed low-level logs to the console.
     */
    public static func setSIPDebugMode(enabled: Bool) {}
}
