package cc.smartconnect.smartsipdemo.screens

import androidx.compose.animation.core.animateFloatAsState
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
import androidx.compose.ui.platform.LocalHapticFeedback
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import cc.smartconnect.smartsipdemo.CallViewModel
import cc.smartconnect.smartsipdemo.DTMFPlayer

@Composable
fun BlueInCallView(viewModel: CallViewModel, isNative: Boolean = false) {
    val callStatus by viewModel.callState.collectAsState()
    val isMuted by viewModel.isMuted.collectAsState()
    val isSpeakerOn by viewModel.isSpeakerOn.collectAsState()
    val destination by viewModel.selectedDestination.collectAsState()

    // Determine the theme color based on the flow type
    val themeColor = if (isNative) Color(0xFFD32F2F) else Color(0xFF2196F3)
    val lightThemeColor = if (isNative) Color(0x1AD32F2F) else Color(0x1A2196F3)
    val pressedThemeColor = if (isNative) Color(0x33D32F2F) else Color(0x332196F3)

    val grid = listOf(
        listOf("1", "2", "3"),
        listOf("4", "5", "6"),
        listOf("7", "8", "9"),
        listOf("*", "0", "#")
    )

    Scaffold(
        modifier = Modifier.fillMaxSize(),
        containerColor = Color.White,
        bottomBar = {
            Column(
                horizontalAlignment = Alignment.CenterHorizontally,
                modifier = Modifier
                    .fillMaxWidth()
                    .navigationBarsPadding()
                    .padding(bottom = 40.dp)
            ) {
                Row(
                    modifier = Modifier.padding(bottom = 30.dp),
                    horizontalArrangement = Arrangement.Center
                ) {
                    ControlToggle(
                        isActive = isMuted,
                        label = "Mute",
                        onIcon = "🔇",
                        offIcon = "🎙️",
                        themeColor = themeColor,
                        lightThemeColor = lightThemeColor,
                        onClick = { viewModel.toggleMute() }
                    )
                    Spacer(modifier = Modifier.width(50.dp))
                    ControlToggle(
                        isActive = isSpeakerOn,
                        label = "Speaker",
                        onIcon = "📢",
                        offIcon = "📱",
                        themeColor = themeColor,
                        lightThemeColor = lightThemeColor,
                        onClick = { viewModel.toggleSpeaker() }
                    )
                }

                Box(
                    contentAlignment = Alignment.Center,
                    modifier = Modifier
                        .size(85.dp)
                        .background(Color.Red, CircleShape)
                        .clickable { viewModel.endCall() }
                ) {
                    Text("📞", fontSize = 32.sp, color = Color.White)
                }
            }
        }
    ) { innerPadding ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(innerPadding)
                .statusBarsPadding(),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.Center
        ) {
            Column(
                horizontalAlignment = Alignment.CenterHorizontally,
                modifier = Modifier.padding(bottom = 40.dp)
            ) {
                Text(text = destination, fontSize = 36.sp, color = Color.Black)
                Text(
                    text = if (isNative) "SYSTEM MANAGED" else callStatus.value.uppercase(),
                    fontSize = 14.sp,
                    fontWeight = FontWeight.Bold,
                    letterSpacing = 2.sp,
                    color = themeColor,
                    modifier = Modifier.padding(top = 8.dp)
                )
            }

            Column(verticalArrangement = Arrangement.spacedBy(20.dp)) {
                grid.forEach { row ->
                    Row(horizontalArrangement = Arrangement.spacedBy(35.dp)) {
                        row.forEach { digit ->
                            DialerDigitCircle(
                                digit = digit,
                                themeColor = themeColor,
                                lightColor = lightThemeColor,
                                pressedColor = pressedThemeColor
                            ) { pressed ->
                                DTMFPlayer.playTone(pressed)
                                viewModel.sendDTMF(pressed)
                            }
                        }
                    }
                }
            }
        }
    }
}

@Composable
fun DialerDigitCircle(
    digit: String,
    themeColor: Color,
    lightColor: Color,
    pressedColor: Color,
    onClick: (String) -> Unit
) {
    val haptic = LocalHapticFeedback.current
    var isPressed by remember { mutableStateOf(false) }
    val scale by animateFloatAsState(if (isPressed) 0.9f else 1.0f, label = "Scale")

    Box(
        contentAlignment = Alignment.Center,
        modifier = Modifier
            .size(80.dp)
            .scale(scale)
            .background(if (isPressed) pressedColor else lightColor, CircleShape)
            .pointerInput(Unit) {
                detectTapGestures(
                    onPress = {
                        isPressed = true
                        haptic.performHapticFeedback(HapticFeedbackType.LongPress)
                        onClick(digit)
                        tryAwaitRelease()
                        isPressed = false
                    }
                )
            }
    ) {
        Text(text = digit, fontSize = 38.sp, fontWeight = FontWeight.Light, color = themeColor)
    }
}

@Composable
fun ControlToggle(
    isActive: Boolean,
    label: String,
    onIcon: String,
    offIcon: String,
    themeColor: Color,
    lightThemeColor: Color,
    onClick: () -> Unit
) {
    Column(horizontalAlignment = Alignment.CenterHorizontally) {
        Box(
            contentAlignment = Alignment.Center,
            modifier = Modifier
                .size(65.dp)
                .background(if (isActive) themeColor else lightThemeColor, CircleShape)
                .clickable { onClick() }
        ) {
            Text(
                text = if (isActive) onIcon else offIcon,
                fontSize = 24.sp,
                color = if (isActive) Color.White else themeColor
            )
        }
        Text(
            text = label,
            fontWeight = FontWeight.Bold,
            fontSize = 12.sp,
            color = themeColor,
            modifier = Modifier.padding(top = 4.dp)
        )
    }
}