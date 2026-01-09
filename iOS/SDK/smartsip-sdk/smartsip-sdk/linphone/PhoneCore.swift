//
//  LinPhoneCore.swift
//  smartsip-sdk
//
//  Created by Franz Iacob on 09/01/2026.
//

internal import linphonesw
import os
import Foundation

public final class PhoneCore {
    
    private var mCore: Core!
    private var phoneCoreDelegate: CallDelegate?
    private var callInfo: CallInfo!

    public required init()
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
            var mCoreDelegate = CoreDelegateStub( onCallStateChanged: { (core: Core, call: Call, state: Call.State, message: String) in
                
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
                    self.phoneCoreDelegate?.callDidChangeState(CallState.from(linphoneState: state) ?? CallState.loggedOut)
                }
                
            })
            mCore.addDelegate(delegate: mCoreDelegate)
        }
        catch {
            Logger.sdk.error("❌ initializeDependencies linphonesw error: \(error.localizedDescription)")
        }
    }
    
    public func setDelegate(_ delegate: CallDelegate) {
        self.phoneCoreDelegate = delegate
    }
    
    public func makeCall(callInfo: CallInfo!) async
    {
        self.callInfo = callInfo;
        Logger.sdk.info("🚀 Initiating SIP Call...")
        Logger.sdk.info("SIP Server: \(callInfo.domain):\(callInfo.port)")
        Logger.sdk.info("SIP User: \(callInfo.username)")
        
        //login into the SIP server
        let callerName = callInfo.callerFullName ?? "Anonymous"
        let callerAddress : String = "sip:\(callerName)@\(callInfo.domain)"
        
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
            Logger.sdk.error("❌ createSession error: \(error.localizedDescription)")
        }
        //
        
        Logger.sdk.info("📞 Call in progress with SessionID: \(callInfo.sessionId)")
    }
    
    
    func outgoingCall() {
        do {
            // As for everything we need to get the SIP URI of the remote and convert it to an Address
            let callingAddress : String = "sip:queue@\(self.callInfo.domain)"
            let remoteAddress = try Factory.Instance.createAddress(addr: callingAddress)
            
            // We also need a CallParams object
            // Create call params expects a Call object for incoming calls, but for outgoing we must use null safely
            let params = try mCore.createCallParams(call: nil)
            let callerName = self.callInfo.callerFullName ?? "Anonymous"
            params.addCustomHeader(headerName: "X-SmartSip-session", headerValue: callerName)
            
            // Finally we start the call
            let _ = mCore.inviteAddressWithParams(addr: remoteAddress, params: params)
            // Call process can be followed in onCallStateChanged callback from core listener
        } catch { NSLog(error.localizedDescription) }
        
    }
    
    func terminateCall() {
        do {
            if (mCore.callsNb == 0) { return }
            
            // If the call state isn't paused, we can get it using core.currentCall
            let coreCall = (mCore.currentCall != nil) ? mCore.currentCall : mCore.calls[0]
            
            // Terminating a call is quite simple
            if let call = coreCall {
                try call.terminate()
            }
        } catch {
            Logger.sdk.error("❌ Terminate call failed with error: \(error.localizedDescription)")
        }
    }
    
    
}
