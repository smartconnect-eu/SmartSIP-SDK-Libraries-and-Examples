package cc.smartconnect.smartsip_sdk.private

/**
 * CallInfo.kt
 * smartsip-sdk
 *
 * Created by Franz Iacob on 21/01/2026.
 * * Internal data class representing the essential parameters for a SIP session.
 */
internal data class CallInfo(
    val sessionId: String,
    val domain: String,
    val port: Int,
    val username: String,
    val password: String,
    val destination: String?,

    // Mutable as it may be updated during the call setup lifecycle
    var callerFullName: String?
)