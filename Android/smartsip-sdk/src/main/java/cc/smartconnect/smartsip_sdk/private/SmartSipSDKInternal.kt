package cc.smartconnect.smartsip_sdk.private

import android.annotation.SuppressLint
import android.content.ComponentName
import android.content.Context
import android.Manifest
import android.net.wifi.WifiManager
import android.os.Build
import android.telecom.PhoneAccount
import android.telecom.PhoneAccountHandle
import android.telecom.TelecomManager
import cc.smartconnect.smartsip_sdk.*
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import kotlinx.serialization.json.Json
import org.json.JSONObject
import java.net.HttpURLConnection
import java.net.URL

/**
 * SmartSipSDKInternal.kt
 * smartsip-sdk
 *
 * Created by Franz Iacob on 22/01/2026.
 *
 * Internal controller for the SmartSip SDK.
 * Coordinates network session establishment, SIP signaling via PhoneCore,
 * and hardware audio routing via SmartSipAudioManager.
 */
internal class SmartSipSDKInternal private constructor(context: Context) {

    private val appContext = context.applicationContext
    private var sipCore: PhoneCore = PhoneCore(appContext)
    private val audioManager = SmartSipAudioManager.getInstance(appContext)

    private var token: String? = null
    private var flowId: String? = null
    private var domain: String? = null

    // Internal reference for the notification branding provided by the host app
    internal var notificationConfig: SmartSipNotificationConfig? = null

    private var currentConnection: SmartSipConnection? = null
    private var wifiLock: WifiManager.WifiLock? = null

    companion object {
        @SuppressLint("StaticFieldLeak")
        @Volatile
        private var sharedInstance: SmartSipSDKInternal? = null

        /**
         * List of permissions required for full SDK functionality.
         */
        internal val permissionsToRequest = mutableListOf(
            Manifest.permission.RECORD_AUDIO,
            Manifest.permission.MODIFY_AUDIO_SETTINGS
        ).apply {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                add(Manifest.permission.POST_NOTIFICATIONS)
            }
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
                add(Manifest.permission.FOREGROUND_SERVICE_MICROPHONE)
            }
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                add(Manifest.permission.MANAGE_OWN_CALLS)
            }
        }.toTypedArray()


        fun initialize(
            context: Context,
            token: String?,
            flowId: String?,
            domain: String?,
            notificationConfig: SmartSipNotificationConfig?
        ): SmartSipSDKInternal {
            val instance = sharedInstance ?: synchronized(this) {
                sharedInstance ?: SmartSipSDKInternal(context).also { sharedInstance = it }
            }

            instance.apply {
                this.token = token
                this.flowId = flowId
                this.domain = domain
                this.notificationConfig = notificationConfig
                registerPhoneAccount(context)
            }
            //monitor for native call interruptions
            InterruptionHandler(context.applicationContext).startMonitoring(context)

            return instance
        }

        fun getSharedInstance(): SmartSipSDKInternal {
            return sharedInstance ?: throw IllegalStateException("SmartSipSDK not initialized")
        }
    }

    // --- API / Network Actions ---

    /**
     * Fetches available call queues from the backend.
     */
    suspend fun getCallDestinations(): List<String> = withContext(Dispatchers.IO) {
        val currentFlowId = flowId ?: return@withContext emptyList()
        val currentDomain = domain ?: return@withContext emptyList()
        val currentToken = token ?: return@withContext emptyList()

        val urlString = "https://$currentDomain/smartsip-api/api/option/read/$currentFlowId/option.SA.queues?token=$currentToken"

        try {
            val url = URL(urlString)
            val connection = (url.openConnection() as HttpURLConnection).apply {
                requestMethod = "GET"
                setRequestProperty("Accept", "application/json")
            }

            if (connection.responseCode == 200) {
                val jsonString = connection.inputStream.bufferedReader().use { it.readText() }
                return@withContext Json.decodeFromString<List<String>>(jsonString)
            } else {
                Logger.sdk.error("❌ Destinations request failed: ${connection.responseCode}")
                return@withContext emptyList()
            }
        } catch (e: Exception) {
            Logger.sdk.error("❌ getCallDestinations network error: ${e.localizedMessage}")
            return@withContext emptyList()
        }
    }

    // --- Call Lifecycle ---

    /**
     * Orchestrates the call start: REST session creation -> Hardware Setup -> SIP Invite.
     */
    suspend fun makeCall(
        clientData: Map<String, Any>? = null,
        destinationQueue: String? = null,
        callerPhoneNumber: String? = null,
        callerFullName: String? = null,
        otherRoutingData: Map<String, Any>? = null,
        useNativeDialer: Boolean = false
    ) {
        val callInfo = performCreateSession(
            clientData,
            destinationQueue,
            callerPhoneNumber,
            callerFullName,
            otherRoutingData
        )

        if (callInfo != null) {
            callInfo.callerFullName = callerFullName

            startNetworkLock()
            audioManager.configureForCall()

            if (useNativeDialer) {
                placeNativeCall(callInfo)
            }
            sipCore.makeCall(callInfo)
        }
    }

    /**
     * Step 1: Request a new SIP session from the SmartSip REST API.
     */
    private suspend fun performCreateSession(
        clientData: Map<String, Any>?,
        destinationQueue: String?,
        callerPhoneNumber: String?,
        callerFullName: String?,
        otherRoutingData: Map<String, Any>?
    ): CallInfo? = withContext(Dispatchers.IO) {
        val currentFlowId = flowId ?: return@withContext null
        val currentDomain = domain ?: return@withContext null
        val currentToken = token ?: return@withContext null

        try {
            val routingData = JSONObject().apply {
                destinationQueue?.let { put("webphone-requested", it) }
                callerPhoneNumber?.let { put("webphone-ani", it) }
                callerFullName?.let { put("webphone-name", it) }
                otherRoutingData?.forEach { (key, value) -> put(key, value) }
            }

            val body = JSONObject().apply {
                put("routing-data", routingData)
                clientData?.let { put("client-data", JSONObject(it)) }
            }

            val url = URL("https://$currentDomain/smartsip-api/api/session/create/$currentFlowId/sips?token=$currentToken")
            val connection = (url.openConnection() as HttpURLConnection).apply {
                requestMethod = "POST"
                setRequestProperty("Content-Type", "application/json")
                setRequestProperty("Authorization", "Bearer $currentToken")
                doOutput = true
            }

            connection.outputStream.use { os -> os.write(body.toString().toByteArray()) }

            if (connection.responseCode == 200) {
                val responseString = connection.inputStream.bufferedReader().use { it.readText() }
                return@withContext extractSessionResult(JSONObject(responseString))
            }
        } catch (e: Exception) {
            Logger.sdk.error("❌ createSession error: ${e.localizedMessage}")
        }
        return@withContext null
    }

    /**
     * Parses the REST response into a SIP-ready [CallInfo] object.
     */
    private fun extractSessionResult(json: JSONObject): CallInfo? {
        return try {
            val sessionId = json.getString("sessionId")
            val sip = json.getJSONObject("connection")
                .getJSONObject("connection")
                .getJSONObject("sip")

            val port = when (val portVal = sip.get("port")) {
                is Int -> portVal
                is String -> portVal.toIntOrNull() ?: 0
                else -> 0
            }

            CallInfo(
                sessionId = sessionId,
                domain = sip.getString("server"),
                port = port,
                username = sip.getString("username"),
                password = sip.getString("password"),
                destination = sip.getString("destination"),
                callerFullName = null
            )
        } catch (e: Exception) {
            Logger.sdk.error("❌ extractSessionResult parsing error: ${e.localizedMessage}")
            null
        }
    }

    /**
     * Registers the app with the Android Telecom system.
     */
    private fun registerPhoneAccount(context: Context) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
        try {
            val telecomManager = context.getSystemService(Context.TELECOM_SERVICE) as TelecomManager
            val componentName = ComponentName(context.packageName, SmartSipConnectionService::class.java.name)
            val phoneAccountHandle = PhoneAccountHandle(componentName, "SmartSipAccount")
            val phoneAccount = PhoneAccount.builder(phoneAccountHandle, "SmartSip")
                .setCapabilities(PhoneAccount.CAPABILITY_SELF_MANAGED)
                .build()
            telecomManager.registerPhoneAccount(phoneAccount)
        } catch (e: Exception) {
            Logger.sdk.error("Telecom registration failed: ${e.localizedMessage}")
        }
    }

    /**
     * Bridges the call to the native Android System dialer.
     */
    private fun placeNativeCall(callInfo: CallInfo) {
        val telecomManager = appContext.getSystemService(Context.TELECOM_SERVICE) as TelecomManager
        val componentName = ComponentName(appContext, SmartSipConnectionService::class.java)
        val handle = PhoneAccountHandle(componentName, "SmartSipAccount")
        val extras = android.os.Bundle().apply {
            putParcelable(TelecomManager.EXTRA_PHONE_ACCOUNT_HANDLE, handle)
            putBoolean("android.telecom.extra.START_WITH_SPEAKERPHONE", false)
        }
        val uri = android.net.Uri.fromParts("tel", callInfo.destination, null)
        try {
            telecomManager.placeCall(uri, extras)
        } catch (e: SecurityException) {
            Logger.sdk.error("Telecom: placeCall denied. Ensure MANAGE_OWN_CALLS is granted.")
        }
    }

    /**
     * Terminates the active session and releases resources.
     */
    fun hangUp() {
        releaseNetworkLock()
        sipCore.terminateCallAndLogout()
        audioManager.teardown()
        currentConnection?.let {
            it.setDisconnected(android.telecom.DisconnectCause(android.telecom.DisconnectCause.LOCAL))
            it.destroy()
            setActiveConnection(null)
        }
    }

    /**
     * Puts the current call on hold or resumes it via SIP signaling.
     */
    fun setCallOnHold(onHold: Boolean) {
        //sipCore.setCallOnHold(onHold)
        //Ensure Audio Manager doesn't fight for focus during native call
        if (onHold) {
            // Explicitly force the Android OS out of "Communication Mode"
            val am = appContext.getSystemService(Context.AUDIO_SERVICE) as android.media.AudioManager
            am.mode = android.media.AudioManager.MODE_NORMAL
            am.isSpeakerphoneOn = false

            audioManager.teardown()
        } else {
            audioManager.configureForCall()
            // audioManager.configureForCall should set mode to MODE_IN_COMMUNICATION
        }
    }

    // --- Hardware Control & Networking ---

    private fun startNetworkLock() {
        if (wifiLock == null) {
            val wm = appContext.getSystemService(Context.WIFI_SERVICE) as WifiManager
            wifiLock = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                wm.createWifiLock(WifiManager.WIFI_MODE_FULL_LOW_LATENCY, "SmartSipWifiLock")
            } else {
                @Suppress("DEPRECATION")
                wm.createWifiLock(WifiManager.WIFI_MODE_FULL_HIGH_PERF, "SmartSipWifiLock")
            }
        }
        wifiLock?.let { if (!it.isHeld) { it.acquire(); sipCore.setNetworkReachable(true) } }
    }

    private fun releaseNetworkLock() { wifiLock?.let { if (it.isHeld) it.release() } }
    fun setActiveConnection(connection: SmartSipConnection?) { this.currentConnection = connection }
    fun isMicrophoneMuted(): Boolean { return true }

    fun setMicrophoneMuted(muted: Boolean) { audioManager.setMicrophoneMuted(muted); sipCore.setMicrophoneMuted(muted) }
    fun setSpeakerOn(enabled: Boolean) { sipCore.setSpeakerOn(enabled) }
    fun sendDTMF(tone: DTMFButton) { sipCore.sendDTMF(tone) }
    fun setSIPDebugMode(enabled: Boolean) { sipCore.setDebugMode(enabled) }
    fun setDelegate(listener: CallListener) { sipCore.setDelegate(listener) }
}