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

/// Represents the standard 12-key DTMF tones used in telephony.
public enum DTMFButton: String {
    case zero = "0", one = "1", two = "2", three = "3", four = "4"
    case five = "5", six = "6", seven = "7", eight = "8", nine = "9"
    case star = "*", pound = "#"
}

/// The main entry point for the SmartSip VoIP SDK.
///
/// Use this class to initialize the SDK, manage call lifecycles, and control audio hardware.
public final class SmartSipSDK {
    
    /// The current semantic version of the SmartSip SDK.
    public static let sdkVersion = "0.0.40"
    
    /// Assigns a delegate to receive real-time call state updates.
    /// - Parameter delegate: An object conforming to `CallDelegate`.
    public static func setDelegate(_ delegate: CallDelegate) {}
    
    /// Represents a valid destination identifier (e.g., an extension or queue name).
    public typealias CallDestination = String
    
    /**
     Initializes the SDK with the required middleware credentials.
     
     - Parameters:
        - token: Security token for authentication.
        - flowId: Identifier for the specific call flow.
        - domain: Server domain address.
     */
    public static func initialize(token: String, flowId: String, domain: String) {}
    
    /**
     Retrieves a list of authorized call targets from the middleware.
     
     - Returns: A collection of `CallDestination` strings.
     */
    @discardableResult
    public static func getCallDestinations() async -> [CallDestination] { return [] }
    
    /**
     Initiates an outgoing VoIP call session.
     
     - Parameters:
        - clientData: Optional metadata to attach to the session.
        - destinationQueue: The target queue or peer.
        - callerPhoneNumber: The phone number to display (E.164).
        - callerFullName: The display name for the caller.
        - otherRoutingData: Custom key-value pairs for routing.
     */
    public static func makeCall(
        clientData: [String: Any]? = nil,
        destinationQueue: String? = nil,
        callerPhoneNumber: String? = nil,
        callerFullName: String? = nil,
        otherRoutingData: [String: Any]? = nil
    ) async {}
    
    /**
     Terminates the active call session and unregisters the client.
     */
    public static func hangUp() {}

    /**
     Sends a DTMF (Dual-Tone Multi-Frequency) tone during an active call.
     
     - Parameter button: The DTMF digit to send (0-9, *, #).
     */
    public static func sendDTMF(_ button: DTMFButton) {}
    
    /**
     Toggles the microphone mute state during an active call.
     
     - Parameter muted: If `true`, the microphone is silenced.
     */
    public static func setMicrophoneMuted(_ muted: Bool) {}
    
    /**
     Toggles the audio output between the earpiece and the loud speaker.
     
     - Parameter isSpeakerOn: If `true`, audio is routed to the loud speaker.
     */
    public static func setSpeakerOn(_ isSpeakerOn: Bool) {}
    
    /**
     Configures the verbosity of the underlying SIP stack logs.
     
     - Parameter enabled: If `true`, detailed logs are output to the console.
     */
    public static func setSIPDebugMode(enabled: Bool) {}
}
