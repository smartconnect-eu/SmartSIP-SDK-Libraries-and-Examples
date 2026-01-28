package cc.smartconnect.smartsip_sdk.private

import android.telecom.CallAudioState
import android.telecom.Connection
import android.telecom.DisconnectCause
import cc.smartconnect.smartsip_sdk.DTMFButton

/**
 * SmartSipConnection.kt
 * smartsip-sdk
 *
 * Created by Franz Iacob on 23/01/2026.
 * * Represents a single active call session in the Android Telecom stack.
 * Bridging native system events (Mute, DTMF, Disconnect) to the SmartSip SIP engine.
 */
class SmartSipConnection : Connection() {

    /**
     * Triggered when the user presses a key on the NATIVE system keypad.
     * Bridged to the Linphone SIP stack to ensure remote IVR compatibility.
     */
    override fun onPlayDtmfTone(digit: Char) {
        super.onPlayDtmfTone(digit)
        Logger.sdk.info("📞 Native Dialer: DTMF '$digit' captured.")

        // Map the Char to our SDK enum and transmit via SIP signaling
        val tone = DTMFButton.values().find { it.rawValue == digit.toString() }
        tone?.let {
            SmartSipSDKInternal.getSharedInstance().sendDTMF(it)
        }
    }

    /**
     * Handles Mute and Speaker toggles originating from the native Android system UI.
     * Keeps hardware states and the SIP stack synchronized.
     */
    override fun onCallAudioStateChanged(state: CallAudioState?) {
        super.onCallAudioStateChanged(state)
        state?.let {
            Logger.sdk.info("🎙️ Native Dialer: Audio state change (Muted: ${it.isMuted})")

            // Synchronize the mute state with the Linphone Core
            SmartSipSDKInternal.getSharedInstance().setMicrophoneMuted(it.isMuted)

            // Note: In Self-Managed flows, the Telecom Manager handles routing
            // (Speaker/Earpiece) automatically based on user interaction in the system UI.
        }
    }

    /**
     * Responds to hang-up requests initiated via the system UI or hardware buttons.
     */
    override fun onDisconnect() {
        Logger.sdk.info("📞 Native Dialer: Hang up requested via system UI.")

        // Terminate the underlying SIP session
        SmartSipSDKInternal.getSharedInstance().hangUp()

        setDisconnected(DisconnectCause(DisconnectCause.LOCAL))
        destroy()
    }

    /**
     * Handles system-level call abortion (e.g., if a high-priority emergency call occurs).
     */
    override fun onAbort() {
        super.onAbort()
        Logger.sdk.info("📞 Native Dialer: Call aborted by system.")

        setDisconnected(DisconnectCause(DisconnectCause.CANCELED))
        destroy()
    }
}