package cc.smartconnect.smartsip_sdk

import android.content.Context
import cc.smartconnect.smartsip_sdk.private.SmartSipSDKInternal
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext

/**
 * SmartSipSDK.kt
 * smartsip-sdk
 *
 * Created by Franz Iacob on 21/01/2026.
 *
 * The public entry point for the SmartSip SDK.
 * This object provides a clean Facade API for application developers,
 * delegating all internal logic to the [SmartSipSDKInternal] controller.
 */
object SmartSipSDK {

    /**
     * The current version of the SmartSip SDK.
     * Matches iOS parity for version tracking and logging.
     */
    const val sdkVersion = "0.0.1"

    /**
     * Returns an array of manifest permissions required for the SDK to function.
     * Use this to facilitate runtime permission requests in your Activity or Fragment.
     */
    val requiredPermissions: Array<String>
        get() = SmartSipSDKInternal.permissionsToRequest

    /**
     * Initializes the SDK with the required credentials and configuration.
     * This must be called before any other SDK methods.
     * * @param context The application context.
     * @param token The authentication token for the SmartSip API.
     * @param flowId The specific flow identifier for routing.
     * @param domain The server domain for the API and SIP proxy.
     * @param notificationConfig Optional branding for the mandatory background notification.
     */
    fun initialize(
        context: Context,
        token: String,
        flowId: String,
        domain: String,
        notificationConfig: SmartSipNotificationConfig? = null
    ) {
        SmartSipSDKInternal.initialize(context, token, flowId, domain, notificationConfig)
    }

    /**
     * Sets the listener to receive call state updates and error notifications.
     */
    fun setDelegate(listener: CallListener) {
        SmartSipSDKInternal.getSharedInstance().setDelegate(listener)
    }

    /**
     * Fetches the list of available call queues/destinations from the SmartSip API.
     */
    suspend fun getCallDestinations(): List<String> = withContext(Dispatchers.IO) {
        SmartSipSDKInternal.getSharedInstance().getCallDestinations()
    }

    /**
     * Initiates a SIP call session.
     * * @param clientData Custom metadata to be associated with the session.
     * @param destinationQueue The specific queue name to route the call to.
     * @param callerPhoneNumber The display number for the caller (ANI).
     * @param callerFullName The display name for the caller.
     * @param otherRoutingData Additional routing parameters for the SIP proxy.
     * @param useNativeDialer If true, integrates the call with the Android Telecom stack.
     */
    suspend fun makeCall(
        clientData: Map<String, Any>? = null,
        destinationQueue: String? = null,
        callerPhoneNumber: String? = null,
        callerFullName: String? = null,
        otherRoutingData: Map<String, Any>? = null,
        useNativeDialer: Boolean = false
    ) = withContext(Dispatchers.IO) {
        SmartSipSDKInternal.getSharedInstance().makeCall(
            clientData,
            destinationQueue,
            callerPhoneNumber,
            callerFullName,
            otherRoutingData,
            useNativeDialer
        )
    }

    /**
     * Terminates the active call and releases associated hardware resources.
     */
    fun hangUp() {
        SmartSipSDKInternal.getSharedInstance().hangUp()
    }

    // --- Audio & Media Controls ---

    /**
     * Toggles the microphone mute state.
     */
    fun setMicrophoneMuted(muted: Boolean) {
        SmartSipSDKInternal.getSharedInstance().setMicrophoneMuted(muted)
    }

    /**
     * Toggles the audio output between the Earpiece and the Speakerphone.
     */
    fun setSpeakerOn(enabled: Boolean) {
        SmartSipSDKInternal.getSharedInstance().setSpeakerOn(enabled)
    }

    /**
     * Sends a DTMF tone during an active call.
     */
    fun sendDTMF(tone: DTMFButton) {
        SmartSipSDKInternal.getSharedInstance().sendDTMF(tone)
    }

    // --- Debugging ---

    /**
     * Enables or disables detailed SIP stack logging.
     */
    fun setSIPDebugMode(enabled: Boolean) {
        SmartSipSDKInternal.getSharedInstance().setSIPDebugMode(enabled)
    }
}