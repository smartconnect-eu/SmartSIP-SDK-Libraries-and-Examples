//
//  CallDelegate.swift
//  smartsip-sdk
//
//  Created by Franz Iacob on 08/01/2026.
//
import Foundation

/// The protocol used to monitor call progress and events.
///
/// Implement this delegate to update your UI or application logic based
/// on real-time state changes from the SDK.
public protocol CallDelegate: AnyObject {

    /// Triggered when the call transitions to a new state.
    /// - Parameter state: The current `CallState` (e.g., .ringing, .connected).
    func callDidChangeState(_ state: CallState)
    
    /// Triggered when a call fails to connect or encounters a mid-call error.
    /// - Parameter error: A human-readable string or error code explaining the failure.
    func callDidFail(withError error: String)
}
