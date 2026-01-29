package cc.smartconnect.smartsipdemo

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.ui.Modifier

import android.R
import android.content.pm.PackageManager
import androidx.activity.result.contract.ActivityResultContracts
import androidx.activity.viewModels
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.core.content.ContextCompat
import cc.smartconnect.smartsip_sdk.CallState
import cc.smartconnect.smartsip_sdk.SmartSipNotificationConfig
import cc.smartconnect.smartsip_sdk.SmartSipSDK
import cc.smartconnect.smartsipdemo.screens.*

/**
 * Main entry point of the application.
 * Handles permissions, SDK initialization, and screen navigation.
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

        // 1. Allow the app to draw behind system bars
        enableEdgeToEdge()

        // 2. Initialize the SmartSip SDK with custom notification branding
        // This branding is used by the background service to maintain the call session.
        val notificationBranding = SmartSipNotificationConfig(
            title = "SmartSip VoIP",
            message = "Active call in progress...",
            iconResourceId = R.drawable.ic_menu_call // Replace with your R.drawable.custom_icon
        )

        SmartSipSDK.initialize(
            context = applicationContext,
            token = "xxxxx",
            flowId = "yyyyy",
            domain = "zzzz",
            notificationConfig = notificationBranding
        )

        // Enable/Disable detailed logging for the SIP stack
        SmartSipSDK.setSIPDebugMode(true)

        // 3. Check for required permissions (Microphone, Phone, Notifications)
        checkAndRequestPermissions()

        setContent {
            MaterialTheme {
                val callState by viewModel.callState.collectAsState()
                val isNativeFlowActive by viewModel.useNativeUI.collectAsState()

                Surface(
                    modifier = Modifier.fillMaxSize(),
                    color = MaterialTheme.colorScheme.background
                ) {
                    // Logic to switch between Discovery and Active Call UI based on SDK state
                    when (callState) {
                        CallState.CONNECTED,
                        CallState.DIALING,
                        CallState.RINGING -> {
                            // Navigate to the Call View.
                            // The UI color/style adapts based on the useNativeUI preference.
                            BlueInCallView(
                                viewModel = viewModel,
                                isNative = isNativeFlowActive
                            )
                        }
                        else -> {
                            // Idle, Disconnected, or Failed states show the setup screen
                            DiscoveryScreen(viewModel = viewModel)
                        }
                    }
                }
            }
        }
    }

    /**
     * Helper to verify all necessary permissions are granted.
     */
    private fun checkAndRequestPermissions() {
        val permissions = SmartSipSDK.requiredPermissions

        val missingPermissions = permissions.filter {
            ContextCompat.checkSelfPermission(this, it) != PackageManager.PERMISSION_GRANTED
        }

        if (missingPermissions.isNotEmpty()) {
            requestPermissionLauncher.launch(permissions)
        } else {
            // If already granted, refresh the queues immediately
            viewModel.fetchDestinations()
        }
    }
}