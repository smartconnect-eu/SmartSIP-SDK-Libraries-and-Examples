package cc.smartconnect.smartsip_sdk

/**
 * CallState.kt
 * smartsip-sdk
 *
 * Created by Franz Iacob on 21/01/2026.
 *
 * Represents the high-level states of the SIP session and individual calls.
 * Used to drive UI transitions between dialing, active, and idle states.
 */
enum class CallState(val value: String) {

    // --- Registration (Login) States ---

    /** The SDK is authenticating with the SIP proxy. */
    LOGIN_IN_PROGRESS("loginInProgress"),

    /** The SDK has successfully authenticated with the SIP proxy. */
    LOGGED_IN("loggedIn"),

    /** The SDK is not connected to the server or has been explicitly logged out. */
    LOGGED_OUT("loggedOut"),


    // --- Call Lifecycle States ---

    /** The call is being prepared or waiting for the network response. */
    DIALING("dialing"),

    /** The remote party is being alerted (ringing). */
    RINGING("ringing"),

    /** The call is active and media streams are established. */
    CONNECTED("connected"),

    /** The call is currently on hold (either locally or by the remote party). */
    HELD("held"),

    /** The call has ended and resources are being released. */
    DISCONNECTED("disconnected"),

    /** The call failed due to a network error, server rejection, or timeout. */
    FAILED("failed");

    companion object {
        /**
         * Support for factory mapping from underlying SIP stack states.
         * Implementation details located in the private package extension.
         */
    }
}