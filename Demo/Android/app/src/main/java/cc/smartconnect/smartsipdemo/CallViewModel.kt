package cc.smartconnect.smartsipdemo

import androidx.compose.runtime.mutableStateOf
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import cc.smartconnect.smartsip_sdk.*
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch

/**
 * CallViewModel handles the business logic for the SmartSip Demo.
 * It observes the SDK state and exposes it to the Compose UI via StateFlows.
 * * Created by Franz Iacob on 22/01/2026.
 */
class CallViewModel : ViewModel(), CallListener {

    // --- Observable UI State ---
    private val _useNativeUI = MutableStateFlow(false)
    val useNativeUI: StateFlow<Boolean> = _useNativeUI.asStateFlow()

    private val _callState = MutableStateFlow(CallState.LOGGED_OUT)
    val callState = _callState.asStateFlow()

    private val _destinations = MutableStateFlow<List<String>>(emptyList())
    val destinations = _destinations.asStateFlow()

    private val _isLoading = MutableStateFlow(false)
    val isLoading = _isLoading.asStateFlow()

    private val _isMuted = MutableStateFlow(false)
    val isMuted = _isMuted.asStateFlow()

    private val _isSpeakerOn = MutableStateFlow(false)
    val isSpeakerOn = _isSpeakerOn.asStateFlow()

    // --- Identity & Optional Client Data (iOS Parity) ---

    var userFullName = mutableStateOf("")
    var userPhoneNumber = mutableStateOf("")

    // List of dynamic key-value pairs for the API session creation
    private val _clientDataFields = MutableStateFlow<List<Pair<String, String>>>(emptyList())
    val clientDataFields = _clientDataFields.asStateFlow()

    private val _selectedDestination = MutableStateFlow("")
    val selectedDestination = _selectedDestination.asStateFlow()

    init {
        SmartSipSDK.setDelegate(this)
        fetchDestinations()
    }

    // --- Client Data Management ---

    fun addClientDataField() {
        _clientDataFields.value = _clientDataFields.value + ("" to "")
    }

    fun removeClientDataField(index: Int) {
        val currentList = _clientDataFields.value.toMutableList()
        if (index in currentList.indices) {
            currentList.removeAt(index)
            _clientDataFields.value = currentList
        }
    }

    fun updateClientDataKey(index: Int, key: String) {
        val currentList = _clientDataFields.value.toMutableList()
        if (index in currentList.indices) {
            currentList[index] = key to currentList[index].second
            _clientDataFields.value = currentList
        }
    }

    fun updateClientDataValue(index: Int, value: String) {
        val currentList = _clientDataFields.value.toMutableList()
        if (index in currentList.indices) {
            currentList[index] = currentList[index].first to value
            _clientDataFields.value = currentList
        }
    }

    // --- SDK Callbacks (CallListener) ---

    override fun callDidChangeState(state: CallState) {
        _callState.value = state
        if (state == CallState.LOGGED_OUT || state == CallState.FAILED) {
            _isMuted.value = false
            _isSpeakerOn.value = false
        }
    }

    override fun callDidFail(withError: String) {
        _callState.value = CallState.FAILED
    }

    // --- UI Actions ---

    fun updateSelectedDestination(name: String) {
        _selectedDestination.value = name
    }

    fun fetchDestinations() {
        viewModelScope.launch {
            _isLoading.value = true
            try {
                _destinations.value = SmartSipSDK.getCallDestinations()
            } catch (e: Exception) {
                _destinations.value = emptyList()
            } finally {
                _isLoading.value = false
            }
        }
    }

    fun toggleUIPreference(isNative: Boolean) {
        _useNativeUI.value = isNative
    }

    /**
     * Initiates the call, converting dynamic fields into the clientData map.
     */
    fun makeTestCall(destination: String) {
        viewModelScope.launch {
            _selectedDestination.value = destination

            // Convert List<Pair> to Map for the SDK
            val customData = _clientDataFields.value
                .filter { it.first.isNotBlank() }
                .associate { it.first to it.second }
                .toMutableMap()

            // Add default platform metadata
            customData["platform"] = "Android"
            customData["app_version"] = "1.0.0"

            SmartSipSDK.makeCall(
                destinationQueue = destination,
                callerFullName = userFullName.value.ifBlank { "Android User" },
                callerPhoneNumber = userPhoneNumber.value.ifBlank { null },
                clientData = customData,
                useNativeDialer = _useNativeUI.value
            )
        }
    }

    fun toggleMute() {
        val newState = !_isMuted.value
        _isMuted.value = newState
        SmartSipSDK.setMicrophoneMuted(newState)
    }

    fun toggleSpeaker() {
        val newState = !_isSpeakerOn.value
        _isSpeakerOn.value = newState
        SmartSipSDK.setSpeakerOn(newState)
    }

    fun endCall() {
        SmartSipSDK.hangUp()
    }

    fun sendDTMF(digit: String) {
        DTMFButton.values().find { it.rawValue == digit }?.let {
            SmartSipSDK.sendDTMF(it)
        }
    }
}