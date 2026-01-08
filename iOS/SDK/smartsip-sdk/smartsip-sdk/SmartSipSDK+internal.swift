//
//  SmartSipSDK+internal.swift
//  smartsip-sdk
//
//  Created by Franz Iacob on 08/01/2026.
//

import Foundation
import os

extension SmartSipSDK {
    
    // MARK: - Internal Network Logic
    internal func performGetCallDestinations() async -> [CallDestination] {
        guard let flowId = self.flowId, let domain = self.domain, let token = self.token else {
            Logger.sdk.error("❌ Failed to get destinations: Configuration missing.")
            return []
        }

        var components = URLComponents()
        components.scheme = "https"
        components.host = domain
        components.path = "/smartsip-api/api/option/read/\(flowId)/option.SA.queues"
        components.queryItems = [URLQueryItem(name: "token", value: token)]

        guard let url = components.url else { return [] }

        do {
            let (data, response) = try await URLSession.shared.data(for: URLRequest(url: url))
            guard (response as? HTTPURLResponse)?.statusCode == 200 else {
                Logger.sdk.error("❌ Destinations request failed with status: \((response as? HTTPURLResponse)?.statusCode ?? 0)")
                return []
            }
            return try JSONDecoder().decode([CallDestination].self, from: data)
        } catch {
            Logger.sdk.error("❌ getCallDestinations network error: \(error.localizedDescription)")
            return []
        }
    }

    internal func performCreateSession(
        clientData: [String: Any]?,
        destination: String?,
        phoneNumber: String?,
        userFullName: String?,
        otherRoutingData: [String: Any]?
    ) async -> SessionResult? {
        
        guard let flowId = self.flowId, let domain = self.domain, let token = self.token else {
            Logger.sdk.error("❌ Cannot create session: SDK not initialized.")
            return nil
        }

        // Build Routing Data Dictionary
        var routingData: [String: Any] = [:]
        if let requested = destination { routingData["webphone-requested"] = requested }
        if let ani = phoneNumber { routingData["webphone-ani"] = ani }
        if let name = userFullName { routingData["webphone-name"] = name }
        
        // Merge extra routing data if provided
        if let extra = otherRoutingData {
            routingData.merge(extra) { (current, _) in current }
        }

        // Final Request Body
        var body: [String: Any] = ["routing-data": routingData]
        if let cData = clientData {
            body["client-data"] = cData
        }

        var components = URLComponents()
        components.scheme = "https"
        components.host = domain
        components.path = "/smartsip-api/api/session/create/\(flowId)"
        components.queryItems = [URLQueryItem(name: "token", value: token)]

        guard let url = components.url else { return nil }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: .sortedKeys)
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard (response as? HTTPURLResponse)?.statusCode == 200 else {
                Logger.sdk.error("❌ Create session failed with status: \((response as? HTTPURLResponse)?.statusCode ?? 0)")
                return nil
            }

            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                return extractSessionResult(from: json)
            }
        } catch {
            Logger.sdk.error("❌ createSession error: \(error.localizedDescription)")
        }
        return nil
    }

    // MARK: - Result Extraction
    private func extractSessionResult(from json: [String: Any]) -> SessionResult? {
        guard let sessionId = json["sessionId"] as? String,
              let connectionRoot = json["connection"] as? [String: Any],
              let innerConnection = connectionRoot["connection"] as? [String: Any],
              let sip = innerConnection["sip"] as? [String: Any],
              let server = sip["server"] as? String,
              let username = sip["username"] as? String,
              let password = sip["password"] as? String else {
            Logger.sdk.error("❌ Validation Error: Response missing required SIP fields.")
            return nil
        }
        
        let port: Int
        if let portInt = sip["port"] as? Int {
            port = portInt
        } else if let portStr = sip["port"] as? String, let convertedInt = Int(portStr) {
            port = convertedInt
        } else {
            Logger.sdk.error("❌ Validation Error: Port is malformed.")
            return nil
        }
    
        return SessionResult(
            sessionId: sessionId,
            server: server,
            port: port,
            username: username,
            password: password
        )
    }
    
    // MARK: - Internal SIP Logic
    /// Performs the actual SIP registration and call initiation.
    internal func performSIPCall(with session: SessionResult) async {
        Logger.sdk.info("🚀 Initiating SIP Call...")
        Logger.sdk.info("SIP Server: \(session.server):\(session.port)")
        Logger.sdk.info("SIP User: \(session.username)")
        
        // TODO: Integrate your SIP library here

        
        Logger.sdk.info("📞 Call in progress with SessionID: \(session.sessionId)")
    }
}
