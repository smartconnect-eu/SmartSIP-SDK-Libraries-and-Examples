package cc.smartconnect.smartsip_sdk

/**
 * DTMFButton.kt
 * smartsip-sdk
 *
 * Created by Franz Iacob on 21/01/2026.
 *
 * Represents standard Dual-Tone Multi-Frequency (DTMF) keypad digits.
 * Used for navigating IVR menus or sending numeric signals during an active call.
 */
enum class DTMFButton(val rawValue: String) {
    ONE("1"),
    TWO("2"),
    THREE("3"),
    FOUR("4"),
    FIVE("5"),
    SIX("6"),
    SEVEN("7"),
    EIGHT("8"),
    NINE("9"),
    ZERO("0"),
    STAR("*"),
    POUND("#")
}