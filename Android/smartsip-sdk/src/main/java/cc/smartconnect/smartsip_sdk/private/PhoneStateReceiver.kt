package cc.smartconnect.smartsip_sdk.private

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.telephony.TelephonyManager
import cc.smartconnect.smartsip_sdk.SmartSipSDK

internal class PhoneStateReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context?, intent: Intent?) {
        if (intent?.action == TelephonyManager.ACTION_PHONE_STATE_CHANGED) {
            val state = intent.getStringExtra(TelephonyManager.EXTRA_STATE)
            if (state == TelephonyManager.EXTRA_STATE_OFFHOOK) {
                // Fallback hangup if the Callback API failed us
                SmartSipSDK.hangUp()
            }
        }
    }
}