package cc.smartconnect.smartsip_sdk.private

import android.content.Context
import android.media.AudioDeviceInfo
import android.media.AudioManager
import android.os.Build
import android.os.Handler
import android.os.Looper

/**
 * SmartSipAudioManager.kt
 * smartsip-sdk
 *
 * Created by Franz Iacob on 22/01/2026.
 * * Manages hardware audio routing, focus, and device selection.
 * Bridges the gap between SIP signaling and the physical device speakers/mic
 * using modern Android AudioCommunication APIs.
 */
internal class SmartSipAudioManager(private val context: Context) {

    private val audioManager = context.getSystemService(Context.AUDIO_SERVICE) as AudioManager

    companion object {
        @Volatile
        private var instance: SmartSipAudioManager? = null

        /**
         * Returns the singleton instance of the audio manager.
         */
        fun getInstance(context: Context): SmartSipAudioManager {
            return instance ?: synchronized(this) {
                instance ?: SmartSipAudioManager(context).also { instance = it }
            }
        }
    }

    // --- Public Internal API ---

    /**
     * Toggles between the Loudspeaker and the Earpiece.
     * Required for Android 31+ (API S) as legacy 'isSpeakerphoneOn' is deprecated.
     */
    fun setSpeakerOn(isSpeakerOn: Boolean) {
        // Ensure the mode is correct, or the OS may ignore routing changes.
        if (audioManager.mode != AudioManager.MODE_IN_COMMUNICATION) {
            audioManager.mode = AudioManager.MODE_IN_COMMUNICATION
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            val devices = audioManager.availableCommunicationDevices

            if (isSpeakerOn) {
                // Search specifically for the built-in loudspeaker hardware.
                val speaker = devices.find { it.type == AudioDeviceInfo.TYPE_BUILTIN_SPEAKER }
                if (speaker != null) {
                    val result = audioManager.setCommunicationDevice(speaker)
                    Logger.sdk.info("🔊 AudioRouting: Speaker enabled (Success: $result)")
                } else {
                    Logger.sdk.error("❌ AudioRouting: Built-in speaker device not found.")
                }
            } else {
                // Clearing the communication device returns routing to the Earpiece or connected Bluetooth.
                audioManager.clearCommunicationDevice()
                Logger.sdk.info("🔊 AudioRouting: Communication device cleared (Reset to default).")
            }
        } else {
            // Legacy support for older Android versions.
            @Suppress("DEPRECATION")
            audioManager.isSpeakerphoneOn = isSpeakerOn
        }
    }

    /**
     * Prepares the system for a VoIP call session.
     * Sets the communication mode and applies a delay for hardware stabilization.
     */
    fun configureForCall() {
        // MODE_IN_COMMUNICATION prioritizes voice call audio processing at the OS level.
        audioManager.mode = AudioManager.MODE_IN_COMMUNICATION

        // Brief delay for the hardware bridge to initialize before forcing initial routing.
        Handler(Looper.getMainLooper()).postDelayed({
            setSpeakerOn(false)
        }, 300)
    }

    /**
     * Mutes or unmutes the microphone at the system level.
     */
    fun setMicrophoneMuted(muted: Boolean) {
        audioManager.isMicrophoneMute = muted
        Logger.sdk.debug("🎙️ Microphone: ${if (muted) "Muted" else "Unmuted"}")
    }

    /**
     * Resets the system audio state to normal when a call ends.
     */
    fun teardown() {
        Logger.sdk.info("🔊 AudioRouting: Teardown initiated.")
        audioManager.mode = AudioManager.MODE_NORMAL

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            audioManager.clearCommunicationDevice()
        } else {
            @Suppress("DEPRECATION")
            audioManager.isSpeakerphoneOn = false
        }
    }
}