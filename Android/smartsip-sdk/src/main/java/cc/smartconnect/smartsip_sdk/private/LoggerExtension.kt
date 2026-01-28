package cc.smartconnect.smartsip_sdk.private

import android.util.Log

/**
 * LoggerExtension.kt
 * smartsip-sdk
 *
 * Created by Franz Iacob on 21/01/2026.
 */

object Logger {
    private const val SUBSYSTEM = "cc.smartconnect.smartsip_sdk"

    // static let sdk = Logger(subsystem: subsystem, category: "SDK")
    val sdk = AndroidLogger("$SUBSYSTEM.SDK")

    // static let sip = Logger(subsystem: subsystem, category: "SIP")
    val sip = AndroidLogger("$SUBSYSTEM.SIP")
}

/**
 * A wrapper class to provide a similar syntax to Apple's Logger (e.g., .debug, .error)
 */
class AndroidLogger(private val tag: String) {
    fun debug(message: String) = Log.d(tag, message)
    fun info(message: String) = Log.i(tag, message)
    fun error(message: String) = Log.e(tag, message)
    fun error(message: String, throwable: Throwable) = Log.e(tag, message, throwable)
}