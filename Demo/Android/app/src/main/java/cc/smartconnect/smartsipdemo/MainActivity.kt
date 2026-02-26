package cc.smartconnect.smartsipdemo

import android.R
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.activity.result.contract.ActivityResultContracts
import androidx.activity.viewModels
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Modifier
import androidx.core.content.ContextCompat
import cc.smartconnect.smartsip_sdk.CallState
import cc.smartconnect.smartsip_sdk.SmartSipNotificationConfig
import cc.smartconnect.smartsip_sdk.SmartSipSDK
import cc.smartconnect.smartsipdemo.screens.DiscoveryScreen
import androidx.compose.foundation.layout.fillMaxSize

/**
 * Main entry point of the application.
 * Manages setup, permissions, and the discovery/dialing screen.
 * The active call UI is handled by [CallActivity] to allow independent navigation.
 */
class MainActivity : ComponentActivity() {

    private val viewModel: CallViewModel by viewModels()

    // Callback for runtime permission requests
    private val requestPermissionLauncher = registerForActivityResult(
        ActivityResultContracts.RequestMultiplePermissions()
    ) { permissions ->
        val allGranted = permissions.entries.all { it.value }
        if (allGranted) {
            viewModel.fetchDestinations()
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // 1. UI Setup
        enableEdgeToEdge()

        // 2. SDK Initialization
        // Branding used for the mandatory Background Service notification
        val notificationBranding = SmartSipNotificationConfig(
            title = "SmartSip VoIP",
            message = "Active call in progress...",
            iconResourceId = R.drawable.ic_menu_call
        )

        SmartSipSDK.initialize(
            context = applicationContext,
            token = "XXXX",
            flowId = "YYYYY",
            domain = "ZZZZ",
            notificationConfig = notificationBranding
        )

        SmartSipSDK.setSIPDebugMode(true)

        // 3. Permissions Check
        checkAndRequestPermissions()

        setContent {
            MaterialTheme {
                val callState by viewModel.callState.collectAsState()

                // Logic to handle Call UI transition
                // When the call starts, we launch the separate CallActivity.
                // This satisfies Joran's requirement for independent navigation.
                LaunchedEffect(callState) {
                    if (callState == CallState.DIALING || callState == CallState.RINGING || callState == CallState.CONNECTED) {
                        val intent = Intent(this@MainActivity, CallActivity::class.java).apply {
                            // FLAG_ACTIVITY_NEW_TASK is used because CallActivity is a separate stack
                            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                        }
                        startActivity(intent)
                    }
                }

                Surface(
                    modifier = Modifier.fillMaxSize(),
                    color = MaterialTheme.colorScheme.background
                ) {
                    // MainActivity strictly handles the app's internal navigation/setup
                    // Even if this screen resets or logs out, the CallActivity task remains.
                    DiscoveryScreen(viewModel = viewModel)
                }
            }
        }
    }

    /**
     * Verifies all necessary permissions (Microphone, Phone, Notifications).
     */
    private fun checkAndRequestPermissions() {
        val permissions = SmartSipSDK.requiredPermissions

        // missingPermissions is a List<String> because of the .filter call
        val missingPermissions = permissions.filter {
            ContextCompat.checkSelfPermission(this, it) != PackageManager.PERMISSION_GRANTED
        }

        if (missingPermissions.isNotEmpty()) {
            // Correct: Convert the LIST of missing items back into an ARRAY for the launcher
            requestPermissionLauncher.launch(missingPermissions.toTypedArray())
        } else {
            // If the list is empty, we have everything we need
            viewModel.fetchDestinations()
        }
    }
}