//
//  CallState.swift
//  smartsip-sdk
//
//  Created by Franz Iacob on 08/01/2026.
//

import Foundation

/// Represents the high-level states of the SIP session and individual calls.
public enum CallState: String {
    // --- Registration (Login) States ---
    
    /// The SDK is authenticating with the SIP proxy.
    case loginInProgress
    
    /// The SDK has successfully authenticated with the SIP proxy.
    case loggedIn
    
    /// The SDK is not connected to the server or has been explicitly logged out.
    case loggedOut
    
    
    // --- Call Lifecycle States ---
    
    /// The call is being prepared or waiting for the network.
    case dialing
    
    /// The remote party is being alerted (ringing).
    case ringing
    
    /// The call is active and audio is flowing.
    case connected
    
    /// The call is currently on hold (local or remote).
    case held
    
    /// The call is in the process of ending or being released.
    case disconnected
    
    /// The call failed due to an error, rejection, or timeout.
    case failed
}
