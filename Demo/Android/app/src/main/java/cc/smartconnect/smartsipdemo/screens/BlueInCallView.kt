package cc.smartconnect.smartsipdemo.screens

import android.app.Activity
import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.core.animateDpAsState
import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.gestures.detectTapGestures
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.scale
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.hapticfeedback.HapticFeedbackType
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.platform.LocalHapticFeedback
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import cc.smartconnect.smartsip_sdk.CallState
import cc.smartconnect.smartsipdemo.CallViewModel
import cc.smartconnect.smartsipdemo.DTMFPlayer

@Composable
fun BlueInCallView(
    viewModel: CallViewModel,
    isNative: Boolean = false,
    onMinimize: () -> Unit = {}
) {
    val context = LocalContext.current
    val callStatus by viewModel.callState.collectAsState()
    val isMuted by viewModel.isMuted.collectAsState()
    val isSpeakerOn by viewModel.isSpeakerOn.collectAsState()
    val destination by viewModel.selectedDestination.collectAsState()
    val isPipMode by viewModel.isPipMode.collectAsState()

    LaunchedEffect(callStatus) {
        if (callStatus == CallState.DISCONNECTED) {
            (context as? Activity)?.finish()
        }
    }

    // Dynamic sizes for the "Shrink" effect
    val hangUpSize by animateDpAsState(targetValue = if (isPipMode) 45.dp else 80.dp)
    val themeColor = if (isNative) Color(0xFFD32F2F) else Color(0xFF2196F3)
    val lightThemeColor = if (isNative) Color(0x1AD32F2F) else Color(0x1A2196F3)
    val pressedThemeColor = if (isNative) Color(0x33D32F2F) else Color(0x332196F3)

    Scaffold(
        modifier = Modifier.fillMaxSize(),
        containerColor = Color.White,
        topBar = {
            if (!isPipMode) {
                Box(modifier = Modifier.fillMaxWidth().statusBarsPadding().padding(16.dp)) {
                    Text(
                        text = "↙️",
                        fontSize = 24.sp,
                        modifier = Modifier.align(Alignment.TopEnd).clickable { onMinimize() }
                    )
                }
            }
        },
        bottomBar = {
            // Simplified footer for PiP
            Column(
                horizontalAlignment = Alignment.CenterHorizontally,
                modifier = Modifier
                    .fillMaxWidth()
                    .navigationBarsPadding()
                    .padding(bottom = if (isPipMode) 4.dp else 30.dp)
            ) {
                if (!isPipMode) {
                    Row(
                        modifier = Modifier.padding(bottom = 20.dp),
                        horizontalArrangement = Arrangement.Center
                    ) {
                        ControlToggle(isMuted, "Mute", "🔇", "🎙️", themeColor, lightThemeColor) { viewModel.toggleMute() }
                        Spacer(modifier = Modifier.width(40.dp))
                        ControlToggle(isSpeakerOn, "Speaker", "📢", "📱", themeColor, lightThemeColor) { viewModel.toggleSpeaker() }
                    }
                }

                // Call End Button - Scaled down for PiP
                Box(
                    contentAlignment = Alignment.Center,
                    modifier = Modifier
                        .size(hangUpSize)
                        .background(Color.Red, CircleShape)
                        .clickable { viewModel.endCall() }
                ) {
                    Text("📞", fontSize = if (isPipMode) 18.sp else 28.sp, color = Color.White)
                }
            }
        }
    ) { innerPadding ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(innerPadding)
                .padding(horizontal = if (isPipMode) 4.dp else 16.dp),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.Center
        ) {
            // HEADER: Always visible, but smaller in PiP
            Column(horizontalAlignment = Alignment.CenterHorizontally) {
                Text(
                    text = destination.ifEmpty { "Active Call" },
                    fontSize = if (isPipMode) 16.sp else 32.sp,
                    fontWeight = FontWeight.Bold,
                    color = Color.Black
                )
                Text(
                    text = callStatus.value.uppercase(),
                    fontSize = if (isPipMode) 9.sp else 12.sp,
                    color = themeColor,
                    letterSpacing = 1.sp
                )
            }

            // DIALER: Strictly hidden in PiP
            AnimatedVisibility(
                visible = !isPipMode,
                enter = fadeIn(),
                exit = fadeOut()
            ) {
                Column(
                    modifier = Modifier.padding(top = 30.dp),
                    verticalArrangement = Arrangement.spacedBy(15.dp)
                ) {
                    val grid = listOf(listOf("1","2","3"), listOf("4","5","6"), listOf("7","8","9"), listOf("*","0","#"))
                    grid.forEach { row ->
                        Row(horizontalArrangement = Arrangement.spacedBy(25.dp)) {
                            row.forEach { digit ->
                                DialerDigitCircle(digit, themeColor, lightThemeColor, pressedThemeColor) {
                                    DTMFPlayer.playTone(it)
                                    viewModel.sendDTMF(it)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

@Composable
fun DialerDigitCircle(digit: String, themeColor: Color, lightColor: Color, pressedColor: Color, onClick: (String) -> Unit) {
    val haptic = LocalHapticFeedback.current
    var isPressed by remember { mutableStateOf(false) }
    val scale by animateFloatAsState(if (isPressed) 0.85f else 1f)

    Box(
        contentAlignment = Alignment.Center,
        modifier = Modifier
            .size(72.dp)
            .scale(scale)
            .background(if (isPressed) pressedColor else lightColor, CircleShape)
            .pointerInput(Unit) {
                detectTapGestures(onPress = {
                    isPressed = true
                    haptic.performHapticFeedback(HapticFeedbackType.LongPress)
                    onClick(digit)
                    tryAwaitRelease()
                    isPressed = false
                })
            }
    ) {
        Text(text = digit, fontSize = 32.sp, color = themeColor)
    }
}

@Composable
fun ControlToggle(isActive: Boolean, label: String, onIcon: String, offIcon: String, themeColor: Color, lightThemeColor: Color, onClick: () -> Unit) {
    Column(horizontalAlignment = Alignment.CenterHorizontally) {
        Box(
            contentAlignment = Alignment.Center,
            modifier = Modifier
                .size(55.dp)
                .background(if (isActive) themeColor else lightThemeColor, CircleShape)
                .clickable { onClick() }
        ) {
            Text(text = if (isActive) onIcon else offIcon, fontSize = 20.sp, color = if (isActive) Color.White else themeColor)
        }
        Text(text = label, fontSize = 11.sp, color = themeColor, modifier = Modifier.padding(top = 2.dp))
    }
}