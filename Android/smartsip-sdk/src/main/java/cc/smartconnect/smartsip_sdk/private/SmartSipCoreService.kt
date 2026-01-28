package cc.smartconnect.smartsip_sdk.private

import android.content.Intent
import android.content.pm.ServiceInfo
import android.os.Build
import org.linphone.core.tools.service.CoreService

/**
 * SmartSipCoreService.kt
 * smartsip-sdk
 *
 * Created by Franz Iacob on 23/01/2026.
 *
 * Internal foreground service that maintains the SIP stack persistence.
 * This ensures parity with iOS by keeping the call alive even if the app
 * is swiped away or backgrounded.
 */
class SmartSipCoreService : CoreService() {

    /**
     * Handles the service start command to promote the service to foreground.
     * Required for background microphone access on modern Android versions.
     */
    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val notification = NotificationHelper.createNotification(this)

        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                startForeground(
                    NotificationHelper.getNotificationId(),
                    notification,
                    ServiceInfo.FOREGROUND_SERVICE_TYPE_MICROPHONE or ServiceInfo.FOREGROUND_SERVICE_TYPE_PHONE_CALL
                )
            } else {
                startForeground(NotificationHelper.getNotificationId(), notification)
            }
        } catch (e: Exception) {
            Logger.sdk.error("❌ SmartSipCoreService: Failed to enter foreground: ${e.localizedMessage}")
        }

        return super.onStartCommand(intent, flags, startId)
    }

    /**
     * Triggered when the user swipes the app away from the recent tasks list.
     * We keep the service alive to ensure the SIP session is not terminated.
     */
    override fun onTaskRemoved(rootIntent: Intent?) {
        Logger.sdk.info("📱 App swiped away, but SmartSipCoreService remains active for the call session.")
    }

    /**
     * Clean up notification and hardware resources when the service is stopped.
     */
    override fun onDestroy() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            stopForeground(STOP_FOREGROUND_REMOVE)
        } else {
            @Suppress("DEPRECATION")
            stopForeground(true)
        }
        super.onDestroy()
    }
}