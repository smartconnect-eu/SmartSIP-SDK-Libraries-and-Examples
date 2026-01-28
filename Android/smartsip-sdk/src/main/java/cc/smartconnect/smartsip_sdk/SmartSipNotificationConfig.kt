package cc.smartconnect.smartsip_sdk

import androidx.annotation.DrawableRes

/**
 * SmartSipNotificationConfig.kt
 * smartsip-sdk
 *
 * Created by Franz Iacob on 23/01/2026.
 *
 * Defines the branding for the mandatory foreground service notification.
 * This ensures the SDK remains agnostic while the host application provides
 * its own UI style for the persistent background call notification.
 */
data class SmartSipNotificationConfig(
    /**
     * The main title displayed in the notification (e.g., "Company Name").
     * This is usually the boldest text at the top of the notification.
     */
    val title: String,

    /**
     * The subtext description displayed in the notification (e.g., "Active call in progress...").
     * Provides additional context to the user about the ongoing session.
     */
    val message: String,

    /**
     * The resource ID for the small icon displayed in the status bar (e.g., R.drawable.ic_call).
     * This should be a monochromatic (white) icon with transparency for modern Android versions.
     */
    @DrawableRes val iconResourceId: Int
)