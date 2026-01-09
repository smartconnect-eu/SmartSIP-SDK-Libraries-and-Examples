//
//  LoggerExtension.swift
//  smartsip-sdk
//
//  Created by Franz Iacob on 08/01/2026.
//

import os
import Foundation


extension Logger {
    private static var subsystem = Bundle.main.bundleIdentifier ?? "smartconnect.smartsip.sdk"

    static let sdk = Logger(subsystem: subsystem, category: "SDK")
    static let sip = Logger(subsystem: subsystem, category: "SIP")
}
