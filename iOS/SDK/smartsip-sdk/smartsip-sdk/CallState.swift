//
//  CallState.swift
//  smartsip-sdk
//
//  Created by Franz Iacob on 08/01/2026.
//

import Foundation

/// Represents the various lifecycle stages of a SIP or VoIP call.
public enum CallState: String {
    /// The call is being initiated but has not reached the recipient yet.
    case dialing
    /// The recipient's device is alerting (ringing).
    case ringing
    /// The call has been answered and media is flowing.
    case connected
    /// The call has ended normally.
    case disconnected
    /// The call could not be completed due to an error or rejection.
    case failed
}
