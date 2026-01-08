//
//  CallState.swift
//  smartsip-sdk
//
//  Created by Franz Iacob on 08/01/2026.
//

import Foundation

/// Represents the high-level states of a call for UI and logic.
public enum CallState: String {
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
