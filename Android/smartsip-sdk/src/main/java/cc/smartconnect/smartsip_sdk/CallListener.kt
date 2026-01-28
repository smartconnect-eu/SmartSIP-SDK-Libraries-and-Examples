package cc.smartconnect.smartsip_sdk

/**
 * CallListener.kt
 * smartsip-sdk
 *
 * Created by Franz Iacob on 21/01/2026.
 *
 * Public interface for monitoring call lifecycle events and registration states.
 * Implement this listener in your ViewModel or Activity to update the UI accordingly.
 */
interface CallListener {

    /**
     * Triggered whenever the call or registration status changes.
     * @param state The new [CallState] mapped from the underlying SIP engine.
     */
    fun callDidChangeState(state: CallState)

    /**
     * Triggered when a critical error occurs during signaling or registration.
     * @param withError A descriptive string identifying the failure cause.
     */
    fun callDidFail(withError: String)
}