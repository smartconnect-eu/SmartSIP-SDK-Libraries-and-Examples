//
//  CallCredentials.swift
//  smartsip-sdk
//
//  Created by Franz Iacob on 09/01/2026.
//

public struct CallInfo {
    public let sessionId: String
    public let domain: String
    public let port: Int
    public let username: String
    public let password: String
    public var callerFullName: String?
}
