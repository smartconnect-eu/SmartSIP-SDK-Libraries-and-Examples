//
//  SmartSipSDK.swift
//  smartsip-sdk
//
//  Created by Franz Iacob on 08/01/2026.
//

import Foundation

public protocol CallDelegate: AnyObject {
    func callDidChangeState(_ state: CallState)
    func callDidFail(withError error: String)
}

public enum CallState: String {
    case loginInProgress, loggedIn, loggedOut, dialing, ringing, connected, held, disconnected, failed
}

public final class SmartSipSDK {
    public static let sdkVersion = "0.0.36"
    public static func setDelegate(_ delegate: CallDelegate) {}
    public typealias CallDestination = String
    public static func initialize(token: String, flowId: String, domain: String) {}
    @discardableResult
    public static func getCallDestinations() async -> [CallDestination] { return [] }
    public static func makeCall(clientData: [String: Any]? = nil, destinationQueue: String? = nil, callerPhoneNumber: String? = nil, callerFullName: String? = nil, otherRoutingData: [String: Any]? = nil) async {}
    public static func hangUp() {}
    public static func setSIPDebugMode(enabled: Bool) {}
}
