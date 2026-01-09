//
//  CallState+linphone.swift
//  smartsip-sdk
//
//  Created by Franz Iacob on 08/01/2026.
//

internal import linphonesw

extension CallState {
    /// Maps internal Linphone Call.State to the public SDK CallState
    static func from(linphoneState: Call.State) -> CallState? {
        switch linphoneState {
        case .OutgoingInit, .OutgoingProgress:
            return .dialing
            
        case .OutgoingRinging, .IncomingReceived, .PushIncomingReceived:
            return .ringing
            
        case .Connected, .StreamsRunning:
            return .connected
            
        case .Pausing, .Paused, .PausedByRemote:
            return .held
            
        case .End, .Released:
            return .disconnected
            
        case .Error:
            return .failed
            
        default:
            // Ignore internal technical transitions like 'Updating' or 'Referred'
            // unless you specifically want to handle them.
            return nil
        }
    }
    
    static func from(linphoneState: RegistrationState) -> CallState? {
        switch linphoneState {
        case .Ok:
            return .loggedIn
            
        case .Progress, .Refreshing:
            return .loginInProgress
    
        default:
            return .loggedOut
        }
    }
}

