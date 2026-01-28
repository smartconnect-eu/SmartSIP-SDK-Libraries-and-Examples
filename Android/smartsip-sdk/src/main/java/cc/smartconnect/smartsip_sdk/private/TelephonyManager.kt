package cc.smartconnect.smartsip_sdk.private

import android.Manifest
import android.content.Context
import android.content.pm.PackageManager
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.telephony.TelephonyCallback
import android.telephony.TelephonyManager
import androidx.core.content.ContextCompat
import cc.smartconnect.smartsip_sdk.SmartSipSDK

/**
 * InterruptionHandler.kt
 * smartsip-sdk
 *
 * Monitors native call states for all Android versions.
 * Specifically optimized for Android 16 to prevent event suppression.
 */
internal class InterruptionHandler(private val context: Context) {

    private val appContext = context.applicationContext
    private var telephonyManager: TelephonyManager? = null
    private var isRegistered = false
    private val mainHandler = Handler(Looper.getMainLooper())

    // --- 1. Strong Reference for API 31+ (Android 16 Safe) ---
    private val telephonyCallback = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
        object : TelephonyCallback(), TelephonyCallback.CallStateListener {
            override fun onCallStateChanged(state: Int) {
                // Heartbeat log to confirm the pipe is alive
                println("📡 SmartSip [TELEPHONY]: State change received -> ${getStateName(state)}")
                handleStateChange(state)
            }
        }
    } else null

    // --- 2. Strong Reference for Legacy API ---
    @Suppress("DEPRECATION")
    private val phoneStateListener = if (Build.VERSION.SDK_INT < Build.VERSION_CODES.S) {
        object : android.telephony.PhoneStateListener() {
            override fun onCallStateChanged(state: Int, phoneNumber: String?) {
                println("📡 SmartSip [LEGACY]: State change received -> ${getStateName(state)}")
                handleStateChange(state)
            }
        }
    } else null

    /**
     * Registers the listener.
     * @param serviceContext The Context of the running Foreground Service.
     * Using the Service Context is critical on Android 16.
     */
    fun startMonitoring(serviceContext: Context) {
        // Fetch manager from the service context specifically
        telephonyManager = serviceContext.getSystemService(Context.TELEPHONY_SERVICE) as? TelephonyManager

        if (isRegistered) {
            stopMonitoring()
        }

        val hasPermission = ContextCompat.checkSelfPermission(
            appContext,
            Manifest.permission.READ_PHONE_STATE
        ) == PackageManager.PERMISSION_GRANTED

        if (!hasPermission) {
            println("⚠️ SmartSip: READ_PHONE_STATE missing. Monitoring aborted.")
            return
        }

        // DELAYED REGISTRATION: Android 16 requires a gap after startForeground
        // to propagate the "phoneCall" capability to the telephony stack.
        mainHandler.postDelayed({
            try {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                    telephonyCallback?.let {
                        telephonyManager?.registerTelephonyCallback(serviceContext.mainExecutor, it)
                    }
                } else {
                    @Suppress("DEPRECATION")
                    telephonyManager?.listen(phoneStateListener, android.telephony.PhoneStateListener.LISTEN_CALL_STATE)
                }
                isRegistered = true
                println("✅ SmartSip: Interruption monitor successfully bound to Service.")
            } catch (e: Exception) {
                println("❌ SmartSip: Monitor registration failed: ${e.message}")
            }
        }, 2500) // 2.5 second safety delay
    }

    /**
     * Unregisters listeners.
     */
    fun stopMonitoring() {
        if (!isRegistered) return

        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                telephonyCallback?.let { telephonyManager?.unregisterTelephonyCallback(it) }
            } else {
                @Suppress("DEPRECATION")
                telephonyManager?.listen(phoneStateListener, android.telephony.PhoneStateListener.LISTEN_NONE)
            }
            isRegistered = false
            mainHandler.removeCallbacksAndMessages(null)
        } catch (e: Exception) {
            // Log locally
        }
    }

    private fun handleStateChange(state: Int) {
        when (state) {
            TelephonyManager.CALL_STATE_OFFHOOK -> {
                println("🛑 SmartSip: Native call picked up. Hanging up VoIP.")
                SmartSipSDK.hangUp()
            }
            TelephonyManager.CALL_STATE_RINGING -> {
                println("🔔 SmartSip: Native call ringing. Keeping VoIP session.")
            }
            TelephonyManager.CALL_STATE_IDLE -> {
                println("😴 SmartSip: System IDLE.")
            }
        }
    }

    private fun getStateName(state: Int) = when (state) {
        TelephonyManager.CALL_STATE_IDLE -> "IDLE (0)"
        TelephonyManager.CALL_STATE_RINGING -> "RINGING (1)"
        TelephonyManager.CALL_STATE_OFFHOOK -> "OFFHOOK (2)"
        else -> "UNKNOWN ($state)"
    }
}