package cc.smartconnect.smartsipdemo

import android.app.PictureInPictureParams
import android.content.res.Configuration
import android.os.Build
import android.os.Bundle
import android.util.Rational
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.viewModels
import cc.smartconnect.smartsipdemo.screens.BlueInCallView

class CallActivity : ComponentActivity() {
    private val viewModel: CallViewModel by viewModels()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            // We pass a new parameter to handle the 'Minimize' action
            BlueInCallView(
                viewModel = viewModel,
                isNative = false,
                onMinimize = { enterPipMode() }
            )
        }
    }

    private fun enterPipMode() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            // A 9:16 ratio is typical for a minimized mobile call window
            val params = PictureInPictureParams.Builder()
                .setAspectRatio(Rational(9, 16))
                .build()
            enterPictureInPictureMode(params)
        }
    }

    // This ensures the UI adjusts when it becomes a small "Quarter-screen" overlay
    override fun onPictureInPictureModeChanged(
        isInPictureInPictureMode: Boolean,
        newConfig: Configuration
    ) {
        super.onPictureInPictureModeChanged(isInPictureInPictureMode, newConfig)
        // You can update a state in ViewModel here to hide the dialpad in Pip mode
        viewModel.setPipMode(isInPictureInPictureMode)
    }
}