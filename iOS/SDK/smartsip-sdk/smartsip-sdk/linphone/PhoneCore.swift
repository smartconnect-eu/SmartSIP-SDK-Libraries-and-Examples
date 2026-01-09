//
//  LinPhoneCore.swift
//  smartsip-sdk
//
//  Created by Franz Iacob on 09/01/2026.
//

internal import linphonesw
import os
import Foundation

internal final class PhoneCore {
    
    private var mCore: Core!
    private var phoneCoreDelegate: CallDelegate?
    private var callInfo: CallInfo!

    internal required init()
    {
        do
        {
            mCore = try Factory.Instance.createCore(configPath: "", factoryConfigPath: "", systemContext: nil)
            //disable video
            mCore.videoCaptureEnabled = false
            mCore.videoDisplayEnabled = false
            mCore.videoActivationPolicy!.automaticallyAccept = false
            //force encryption to Secure RTP
            try mCore.setMediaencryption(newValue: .SRTP)
            
            //feed the state to the core listening for changes, if any
            let mCoreDelegate = CoreDelegateStub( onCallStateChanged: { (core: Core, call: Call, state: Call.State, message: String) in
                
                if( state == .Error )
                {
                    self.phoneCoreDelegate?.callDidFail(withError: message);
                }
                else
                {
                    self.phoneCoreDelegate?.callDidChangeState(CallState.from(linphoneState: state) ?? CallState.disconnected)
                }
                
            }, onAccountRegistrationStateChanged: { (core: Core, account: Account, state: RegistrationState, message: String) in
                
                if( state == .Failed )
                {
                    self.phoneCoreDelegate?.callDidFail(withError: message)
                }
                else
                {
                    if ( state == .Ok )
                    {
                        Logger.sdk.info("✅ Registered Successfully. Auto-starting the call...")
                        // This is where we trigger the call immediately after login
                        self.makeOutgoingCall()
                    }
                    self.phoneCoreDelegate?.callDidChangeState(CallState.from(linphoneState: state) ?? CallState.loggedOut)
                }
                
            })
            mCore.addDelegate(delegate: mCoreDelegate)
        }
        catch {
            Logger.sdk.error("❌ initializeDependencies linphonesw error: \(error.localizedDescription)")
        }
    }
    
    internal func setDelegate(_ delegate: CallDelegate) {
        self.phoneCoreDelegate = delegate
    }
    
    internal func makeCall(callInfo: CallInfo!) async
    {
        self.callInfo = callInfo;
        Logger.sdk.info("🚀 Initiating SIP Call...")
        Logger.sdk.info("SIP Server: \(callInfo.domain):\(callInfo.port)")
        Logger.sdk.info("SIP User: \(callInfo.username)")
        
        //login into the SIP server
        let callerAddress : String = "sip:\(callInfo.sessionId)@\(callInfo.domain)"
        
        do
        {
            // Configure the SIP Authentication credentials using the session results
            // We use the username, password, and domain (realm) provided by the middleware
            let authInfo = try Factory.Instance.createAuthInfo(
                username: callInfo.username,
                userid: "",
                passwd: callInfo.password,
                ha1: "",
                realm: "",
                domain: callInfo.domain
            )

            // Initialize account parameters to define the user identity and registration behavior
            let accountParams = try mCore.createAccountParams()

            // Create and set the 'From' identity address (e.g., sip:username@domain)
            let identity = try Factory.Instance.createAddress(addr: callerAddress)
            try accountParams.setIdentityaddress(newValue: identity)

            // Configure the Remote Proxy/Server address for the SIP connection
            // We use SIPS (Secure SIP) over TLS via port 443 as required by the infrastructure
            let address = try Factory.Instance.createAddress(addr: "sips:\(callInfo.domain)")
            try address.setTransport(newValue: TransportType.Tls)
            try address.setPort(newValue: callInfo.port)
            try accountParams.setServeraddress(newValue: address)

            // Enable registration so the client sends a REGISTER request to the proxy
            accountParams.registerEnabled = true

            // Instantiate the account with the defined parameters
            let account = try mCore.createAccount(params: accountParams)

            // Add authentication info to the Core cache and register the account
            // Setting the account as 'default' ensures outgoing calls use this identity
            mCore.addAuthInfo(info: authInfo)
            try mCore.addAccount(account: account)
            mCore.defaultAccount = account
            
            // Starts the SIP stack main loop and begins processing background network tasks.
            // This initiates the actual registration process and prepares the SDK to handle
            // signaling, media streams, and events.
            try mCore.start()
        }
        catch
        {
            Logger.sdk.error("❌ login into SIP server error: \(error.localizedDescription)")
        }
        Logger.sdk.info("🔐 Login in progress with SessionID: \(callInfo.sessionId)")
    }
    
    
    internal func makeOutgoingCall() {
        do {
            Logger.sdk.info("📞 Calling Queue: [SessionID: \(self.callInfo.sessionId)]")
            
            // Construct the SIP URI for the destination
            let remoteAddress = try Factory.Instance.createAddress(addr: "sip:queue@\(self.callInfo.domain)")
            
            // Configure call parameters
            // Passing 'nil' to createCallParams signifies a new outgoing call session
            let params = try mCore.createCallParams(call: nil)
            
            // Attach custom headers for server-side tracking (e.g., SmartSip routing)
            params.addCustomHeader(headerName: "X-SmartSip-session", headerValue: self.callInfo.sessionId)
            
            // Initiate the INVITE request
            _ = mCore.inviteAddressWithParams(addr: remoteAddress, params: params)
            
            // Note: Monitor 'onCallStateChanged' in the CoreListener to track progress
        } catch {
            Logger.sdk.error("❌ Outgoing call failed: \(error.localizedDescription)")
        }
    }
    

    internal func terminateCallAndLogout() {
        do {
            // Hang up the call if it exists
            if mCore.callsNb > 0 {
                let call = mCore.currentCall ?? mCore.calls.first
                try call?.terminate()
                Logger.sdk.info("📞 Call terminated by user.")
            }
            
            // Unregister and clear to ensure no "ghost" registrations remain
            // This sends a REGISTER with expires=0 to the server
            mCore.clearAccounts()
            mCore.clearAllAuthInfo()
            
            Logger.sdk.info("🚪 Session closed and logged out.")
            
            // Update UI to initial state
            self.phoneCoreDelegate?.callDidChangeState(.loggedOut)
            
        } catch {
            Logger.sdk.error("❌ Error during teardown: \(error.localizedDescription)")
        }
    }
    
    /// Configures the verbosity of the underlying SIP stack logs.
    /// - Parameter enabled: If true, the SDK will output detailed debug information.
    ///   If false, only critical errors will be logged.
    internal func setDebugMode(enabled: Bool) {
        // Set the global SIP log level.
        // .Debug provides full trace; .Error restricts output to failures only.
        LoggingService.Instance.logLevel = enabled ? .Debug : .Error
    }
    
    
}
