import Foundation

public protocol CallDelegate: AnyObject {
    func callDidChangeState(_ state: CallState)
    func callDidFail(withError error: String)
}

public enum CallState: String {
    case loginInProgress, loggedIn, loggedOut, dialing, ringing, connected, held, disconnected, failed
}

public enum DTMFButton: String {
    case zero = "0", one = "1", two = "2", three = "3", four = "4"
    case five = "5", six = "6", seven = "7", eight = "8", nine = "9"
    case star = "*", pound = "#"
}

public final class SmartSipSDK {
    public static let sdkVersion = "0.0.43"
    public static func setDelegate(_ delegate: CallDelegate) {}
    public typealias CallDestination = String
    public static func initialize(token: String, flowId: String, domain: String) {}
    @discardableResult
    public static func getCallDestinations() async -> [CallDestination] { return [] }
    public static func makeCall(clientData: [String: Any]? = nil, destinationQueue: String? = nil, callerPhoneNumber: String? = nil, callerFullName: String? = nil, otherRoutingData: [String: Any]? = nil) async {}
    public static func hangUp() {}
    public static func sendDTMF(_ button: DTMFButton) {}
    public static func setMicrophoneMuted(_ muted: Bool) {}
    public static func setSpeakerOn(_ isSpeakerOn: Bool) {}
    public static func setSIPDebugMode(enabled: Bool) {}
}
