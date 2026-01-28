package cc.smartconnect.smartsip_sdk.private

import cc.smartconnect.smartsip_sdk.CallState
import org.linphone.core.Call
import org.linphone.core.RegistrationState

/**
 * CallState+Linphone.kt
 * smartsip-sdk
 * * Created by Franz Iacob on 21/01/2026.
 * * Extension factory methods to map Linphone-specific states to the SDK's
 * universal CallState representation.
 */

/**
 * Maps Linphone Call.State to SmartSip CallState.
 */
fun CallState.Companion.from(linphoneState: Call.State?): CallState? {
    return when (linphoneState) {
        Call.State.OutgoingInit,
        Call.State.OutgoingProgress -> CallState.DIALING

        Call.State.OutgoingRinging,
        Call.State.IncomingReceived -> CallState.RINGING

        Call.State.Connected,
        Call.State.StreamsRunning -> CallState.CONNECTED

        Call.State.Pausing,
        Call.State.Paused,
        Call.State.PausedByRemote -> CallState.HELD

        Call.State.End,
        Call.State.Released -> CallState.DISCONNECTED

        Call.State.Error -> CallState.FAILED

        else -> null
    }
}

/**
 * Maps Linphone RegistrationState to SmartSip CallState.
 */
fun CallState.Companion.from(registrationState: RegistrationState?): CallState? {
    return when (registrationState) {
        RegistrationState.Ok -> CallState.LOGGED_IN

        RegistrationState.Progress,
        RegistrationState.Refreshing -> CallState.LOGIN_IN_PROGRESS

        RegistrationState.Cleared,
        RegistrationState.None -> CallState.LOGGED_OUT

        RegistrationState.Failed -> CallState.FAILED

        else -> null
    }
}