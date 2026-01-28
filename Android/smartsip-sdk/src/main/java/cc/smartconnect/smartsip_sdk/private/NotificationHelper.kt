package cc.smartconnect.smartsip_sdk.private

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import androidx.core.app.NotificationCompat

/**
 * NotificationHelper.kt
 * smartsip-sdk
 *
 * Created by Franz Iacob on 23/01/2026.
 */
internal object NotificationHelper {
    private const val CHANNEL_ID = "smartsip_voip_channel"
    private const val NOTIFICATION_ID = 1001

    // Action string for the intent
    const val ACTION_HANGUP = "cc.smartconnect.smartsip_sdk.ACTION_HANGUP"

    fun createNotification(context: Context): Notification {
        val manager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        val config = SmartSipSDKInternal.getSharedInstance().notificationConfig

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "SmartSip Calls",
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "Active call notification"
                setShowBadge(false)
            }
            manager.createNotificationChannel(channel)
        }

        // --- ADDED: Hang Up Action ---
        val hangupIntent = Intent(context, SmartSipCoreService::class.java).apply {
            action = ACTION_HANGUP
        }

        val hangupPendingIntent = PendingIntent.getService(
            context,
            0,
            hangupIntent,
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
        )

        return NotificationCompat.Builder(context, CHANNEL_ID)
            .setContentTitle(config?.title ?: "SmartSip")
            .setContentText(config?.message ?: "Call in progress...")
            .setSmallIcon(config?.iconResourceId ?: android.R.drawable.ic_menu_call)
            .setOngoing(true)
            .setCategory(NotificationCompat.CATEGORY_CALL)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .setForegroundServiceBehavior(NotificationCompat.FOREGROUND_SERVICE_IMMEDIATE)
            // Add the button to the notification
            .addAction(
                android.R.drawable.ic_menu_close_clear_cancel,
                "Hang Up",
                hangupPendingIntent
            )
            .build()
    }

    fun getNotificationId() = NOTIFICATION_ID
}