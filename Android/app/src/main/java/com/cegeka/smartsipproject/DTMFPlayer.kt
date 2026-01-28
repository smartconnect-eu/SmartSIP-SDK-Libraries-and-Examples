package com.cegeka.smartsipproject

import android.media.AudioManager
import android.media.ToneGenerator

/**
 * Plays audible DTMF tones through the system audio stream.
 */
object DTMFPlayer {
    // Volume set to 80% on the DTMF stream
    private val toneGenerator = ToneGenerator(AudioManager.STREAM_DTMF, 80)

    fun playTone(digit: String) {
        val tone = when (digit) {
            "1" -> ToneGenerator.TONE_DTMF_1
            "2" -> ToneGenerator.TONE_DTMF_2
            "3" -> ToneGenerator.TONE_DTMF_3
            "4" -> ToneGenerator.TONE_DTMF_4
            "5" -> ToneGenerator.TONE_DTMF_5
            "6" -> ToneGenerator.TONE_DTMF_6
            "7" -> ToneGenerator.TONE_DTMF_7
            "8" -> ToneGenerator.TONE_DTMF_8
            "9" -> ToneGenerator.TONE_DTMF_9
            "0" -> ToneGenerator.TONE_DTMF_0
            "*" -> ToneGenerator.TONE_DTMF_S
            "#" -> ToneGenerator.TONE_DTMF_P
            else -> null
        }

        tone?.let {
            toneGenerator.startTone(it, 120) // Play for 120ms
        }
    }
}