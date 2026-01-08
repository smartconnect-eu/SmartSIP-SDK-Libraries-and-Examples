//
//  smartsip_sdk.swift
//  smartsip-sdk
//
//  Created by Franz Iacob on 08/01/2026.
//

import Foundation
import os

public final class SmartSipSDK {
    
    public static let shared = SmartSipSDK()
    
    internal var isInitialized = false
    internal var token: String!
    internal var flowId: String!
    internal var domain: String!
    
    private init() {}
    
    // MARK: - Models
    
    public typealias CallDestination = String
    
    public struct SessionResult {
        public let sessionId: String
        public let server: String
        public let port: Int
        public let username: String
        public let password: String
    }
    
    // MARK: - Public API
    /// Initializes the SDK with the required middleware credentials.
    public func initialize(token: String!, flowId: String!, domain: String!) {
        if isInitialized {
            Logger.sdk.warning("The SmartSipSDK was already initialized!!! Re-initialization in progress")
        }
        
        Logger.sdk.info("SDK Initializing with token: \(token ?? "nil", privacy: .private) flowId: \(flowId ?? "nil", privacy: .private) domain: \(domain ?? "nil", privacy: .public)")

        self.token = token
        self.flowId = flowId
        self.domain = domain
        isInitialized = true
    }
    
    /// Fetches the available call destinations from the SmartSIP API.
    public func getCallDestinations() async -> [CallDestination] {
        return await performGetCallDestinations()
    }
    
    /// High-level function to create a session and immediately initiate the SIP call.
        public func makeCall(
            clientData: [String: Any]? = nil,
            destination: String? = nil,
            phoneNumber: String? = nil,
            userFullName: String? = nil,
            otherRoutingData: [String: Any]? = nil
        ) async {
            // 1. Create the session first
            guard let session = await performCreateSession(
                clientData: clientData,
                destination: destination,
                phoneNumber: phoneNumber,
                userFullName: userFullName,
                otherRoutingData: otherRoutingData
            ) else {
                Logger.sdk.error("❌ makeCall failed: Could not establish session.")
                return
            }
            
            // 2. Use the session result to perform the actual SIP call
            await performSIPCall(with: session)
        }
}
