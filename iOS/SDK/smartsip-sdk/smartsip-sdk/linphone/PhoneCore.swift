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
        Logger.sdk.info("🚀 Initiating SIP Call...")
        Logger.sdk.info("SIP Server: \(callInfo.server):\(callInfo.port)")
        Logger.sdk.info("SIP User: \(callInfo.username)")
        
        // TODO: Integrate your SIP library here

        
        Logger.sdk.info("📞 Call in progress with SessionID: \(callInfo.sessionId)")
    }
    
    
}
