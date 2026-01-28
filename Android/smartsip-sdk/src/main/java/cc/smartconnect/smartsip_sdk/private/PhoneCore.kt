package cc.smartconnect.smartsip_sdk.private

import android.content.Context
import cc.smartconnect.smartsip_sdk.CallListener
import cc.smartconnect.smartsip_sdk.CallState
import cc.smartconnect.smartsip_sdk.DTMFButton
import org.linphone.core.*

/**
 * PhoneCore.kt
 * smartsip-sdk
 *
 * Created by Franz Iacob on 21/01/2026.
 * * The central engine responsible for managing the Linphone Core lifecycle,
 * SIP registration, and call signaling.
 */
internal class PhoneCore(private val context: Context) {

    private lateinit var mCore: Core
    private var phoneCoreDelegate: CallListener? = null
    private var callInfo: CallInfo? = null

    init {
        try {
            // Initialize Linphone Core with the Android Application Context
            mCore = Factory.instance().createCore(null, null, context)

            // Video Configuration: Explicitly disabled for voice-only optimization
            mCore.isVideoCaptureEnabled = false
            mCore.isVideoDisplayEnabled = false

            mCore.config.apply {
                setBool("video", "enabled", false)
                setBool("video", "capture", false)
                setBool("video", "display", false)
            }

            // Security: Force Media Encryption to Secure RTP (SRTP)
            mCore.setMediaEncryption(MediaEncryption.SRTP)
            //disable the verification CN of the TLS
            mCore.verifyServerCn(false);

            // Setup Core Listener to handle signaling events
            val coreListener = object : CoreListenerStub() {
                override fun onCallStateChanged(core: Core, call: Call, state: Call.State?, message: String) {
                    if (state == Call.State.Error) {
                        phoneCoreDelegate?.callDidFail(message)
                    } else {
                        val mappedState = CallState.from(state) ?: CallState.DISCONNECTED
                        phoneCoreDelegate?.callDidChangeState(mappedState)
                    }
                }

                override fun onAccountRegistrationStateChanged(
                    core: Core,
                    account: Account,
                    state: RegistrationState?,
                    message: String
                ) {
                    when (state) {
                        RegistrationState.Failed -> {
                            phoneCoreDelegate?.callDidFail(message)
                        }
                        RegistrationState.Ok -> {
                            Logger.sdk.info("✅ Registered Successfully. Auto-starting the call...")
                            // Trigger outgoing call immediately upon successful registration
                            makeOutgoingCall()
                        }
                        else -> {
                            val mappedState = CallState.from(state) ?: CallState.LOGGED_OUT
                            phoneCoreDelegate?.callDidChangeState(mappedState)
                        }
                    }
                }
            }

            mCore.addListener(coreListener)

        } catch (e: Exception) {
            Logger.sdk.error("❌ initializeDependencies linphone error: ${e.localizedMessage}")
        }
    }

    // --- Internal API ---

    internal fun setDelegate(delegate: CallListener) {
        this.phoneCoreDelegate = delegate
    }

    internal suspend fun makeCall(callInfo: CallInfo) {
        this.callInfo = callInfo

        Logger.sdk.info("🚀 Initiating SIP Call...")
        Logger.sdk.info("SIP Server: ${callInfo.domain}:${callInfo.port}")
        Logger.sdk.info("SIP User: ${callInfo.username}")

        val callerAddress = "sip:${callInfo.sessionId}@${callInfo.domain}"

        try {
            // Authentication Setup
            val authInfo = Factory.instance().createAuthInfo(
                callInfo.username,
                "",
                callInfo.password,
                "",
                "",
                callInfo.domain
            )

            // Account Configuration
            val accountParams = mCore.createAccountParams()
            val identity = Factory.instance().createAddress(callerAddress)
            accountParams.identityAddress = identity

            val address = Factory.instance().createAddress("sips:${callInfo.domain}")
            address?.transport = TransportType.Tls
            address?.port = callInfo.port
            accountParams.serverAddress = address
            accountParams.isRegisterEnabled = true

            val account = mCore.createAccount(accountParams)

            mCore.addAuthInfo(authInfo)
            mCore.addAccount(account)
            mCore.defaultAccount = account

            // Start the Core engine
            mCore.start()

        } catch (e: Exception) {
            Logger.sdk.error("❌ login into SIP server error: ${e.localizedMessage}")
        }
        Logger.sdk.info("🔐 Login in progress with SessionID: ${callInfo.sessionId}")
    }

    internal fun makeOutgoingCall() {
        val info = callInfo ?: return
        try {
            Logger.sdk.info("📞 Calling Queue: [SessionID: ${info.sessionId}]")

            val destination = info.destination ?: "queue"
            val remoteAddress = Factory.instance().createAddress("sip:$destination@${info.domain}")

            val params: CallParams? = mCore.createCallParams(null)

            // Inject custom session tracking header
            params?.addCustomHeader("X-SmartSip-session", info.sessionId)

            if (params != null && remoteAddress != null) {
                mCore.inviteAddressWithParams(remoteAddress, params)
            } else {
                Logger.sdk.error("❌ Call initialization failed: Invalid params or address")
            }

        } catch (e: Exception) {
            Logger.sdk.error("❌ Outgoing call failed: ${e.localizedMessage}")
        }
    }

    internal fun terminateCallAndLogout() {
        try {
            val currentCall = mCore.currentCall

            if (currentCall != null) {
                Logger.sdk.info("📞 SIP: Terminating active call session (State: ${currentCall.state})")
                currentCall.terminate()
            } else {
                Logger.sdk.info("📞 SIP: No active call to terminate, stopping all calls.")
                mCore.terminateAllCalls()
            }

            mCore.clearAccounts()
            mCore.clearAllAuthInfo()

            Logger.sdk.info("🚪 Session closed and logged out.")
            this.phoneCoreDelegate?.callDidChangeState(CallState.LOGGED_OUT)

        } catch (e: Exception) {
            Logger.sdk.error("❌ Error during teardown: ${e.localizedMessage}")
        }
    }

    // --- Media Management ---

    fun setSpeakerOn(isSpeakerOn: Boolean) {
        val devices = mCore.audioDevices
        val targetType = if (isSpeakerOn) AudioDevice.Type.Speaker else AudioDevice.Type.Earpiece
        val targetDevice = devices.find { it.type == targetType }

        if (targetDevice != null) {
            // Apply routing to both the engine and the active session
            mCore.outputAudioDevice = targetDevice
            mCore.currentCall?.outputAudioDevice = targetDevice
            Logger.sdk.info("🔊 Audio Routing: Switched to ${targetDevice.deviceName}")
        } else {
            Logger.sdk.error("❌ Audio Routing: Could not find device of type $targetType")
        }
    }

    fun setMicrophoneMuted(muted: Boolean) {
        val currentCall = mCore.currentCall
        if (currentCall != null) {
            currentCall.microphoneMuted = muted
            Logger.sdk.info("🎙️ Microphone ${if (muted) "Muted" else "Unmuted"} for active call.")
        } else {
            // Fallback: update core preference if no call is present
            mCore.isMicEnabled = !muted
        }
    }

    internal fun sendDTMF(tone: DTMFButton) {
        val currentCall = mCore.currentCall ?: run {
            Logger.sdk.error("DTMF: No active call found.")
            return
        }

        val toneChar = tone.rawValue.firstOrNull() ?: return

        try {
            currentCall.sendDtmf(toneChar)
            Logger.sdk.debug("DTMF: Tone '$toneChar' successfully sent.")
        } catch (e: Exception) {
            Logger.sdk.error("DTMF: Failed to send '$toneChar': ${e.localizedMessage}")
        }
    }

    internal fun setNetworkReachable(reachable: Boolean) {
        mCore.isNetworkReachable = reachable
    }

    /**
     * Toggles the SIP Hold state by sending a Re-INVITE to the proxy.
     * @param hold If true, sends a=sendonly; if false, sends a=sendrecv.
     */

    internal class PhoneCore(private val context: Context) {
        private lateinit var mCore: Core
        // ... existing init logic ...

        /**
         * Toggles the SIP Hold state and HARD silences the hardware.
         * @param hold If true, sends SIP Re-INVITE and kills the local audio path.
         */
        fun setCallOnHold(hold: Boolean) {
            val currentCall = mCore.currentCall ?: return

            if (hold) {
                Logger.sdk.info("📞 SIP: Executing Hard Hold (Signaling + Device Detach)")

                // 1. Signaling: Sends Re-INVITE with a=sendonly
                currentCall.pause()

                // 2. Local Media: Disable the microphone capture
                mCore.isMicEnabled = false

                // 3. Hardware Isolation: Disconnect the audio device from the engine.
                // This is the only way to guarantee the speaker stops on some Android builds.
                mCore.outputAudioDevice = null
            } else {
                Logger.sdk.info("📞 SIP: Resuming (Signaling + Device Attach)")

                // 1. Re-attach Hardware: Find the default speaker/earpiece
                val defaultDevice = mCore.audioDevices.firstOrNull {
                    it.type == AudioDevice.Type.Earpiece || it.type == AudioDevice.Type.Speaker
                }
                mCore.outputAudioDevice = defaultDevice

                // 2. Enable Media Capture
                mCore.isMicEnabled = true

                // 3. Signaling: Resume the session
                currentCall.resume()
            }
        }
    }

    internal fun setDebugMode(enabled: Boolean) {
        Factory.instance().setDebugMode(enabled, "SmartSipSDK")
    }
}