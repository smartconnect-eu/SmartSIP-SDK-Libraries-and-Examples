package cc.smartconnect.smartsip_sdk.private

import android.telecom.Connection
import android.telecom.ConnectionRequest
import android.telecom.ConnectionService
import android.telecom.PhoneAccountHandle
import android.telecom.TelecomManager

/**
 * SmartSipConnectionService.kt
 * smartsip-sdk
 *
 * Created by Franz Iacob on 23/01/2026.
 * * A system-bound service that manages the lifecycle of SIP calls within
 * the Android Telecom framework.
 */
class SmartSipConnectionService : ConnectionService() {

    /**
     * Triggered by the TelecomManager when an outgoing call is initiated.
     * This bridges our SIP logic into the system-level call stack.
     */
    override fun onCreateOutgoingConnection(
        connectionManagerPhoneAccount: PhoneAccountHandle?,
        request: ConnectionRequest?
    ): Connection {
        val connection = SmartSipConnection()

        // 1. Setup metadata: Display the destination address on the system UI
        connection.setAddress(request?.address, TelecomManager.PRESENTATION_ALLOWED)

        // 2. Define Capabilities: Enables specific interaction buttons on the native UI/Bluetooth
        connection.connectionCapabilities =
            Connection.CAPABILITY_MUTE or
                    Connection.CAPABILITY_SUPPORT_HOLD or
                    Connection.CAPABILITY_HOLD

        // 3. Audio management: Indicates this is a VoIP session to optimize audio routing
        connection.audioModeIsVoip = true

        // 4. Lifecycle state: Transition from setup to live
        connection.setInitializing()

        // Notify the system that the call is now active and the session is live
        connection.setActive()

        // Return the bridged connection to the Android Telecom Manager
        return connection
    }

    /**
     * Triggered if the system denies the call request.
     * Common reasons include active Emergency calls or strict Do Not Disturb settings.
     */
    override fun onCreateOutgoingConnectionFailed(
        connectionManagerPhoneAccount: PhoneAccountHandle?,
        request: ConnectionRequest?
    ) {
        super.onCreateOutgoingConnectionFailed(connectionManagerPhoneAccount, request)
        Logger.sdk.error("❌ Native Dialer: System denied outgoing connection request.")

        // Ensure the SIP stack is notified that the attempt failed
        SmartSipSDKInternal.getSharedInstance().hangUp()
    }
}