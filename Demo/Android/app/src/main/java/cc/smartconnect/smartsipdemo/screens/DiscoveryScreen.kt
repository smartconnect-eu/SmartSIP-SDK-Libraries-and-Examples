package cc.smartconnect.smartsipdemo.screens

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Add
import androidx.compose.material.icons.filled.Delete
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import cc.smartconnect.smartsip_sdk.CallState
import cc.smartconnect.smartsipdemo.CallViewModel

/**
 * DiscoveryScreen.kt
 * smartsip-sdk
 *
 * Created by Franz Iacob on 23/01/2026.
 * * Provides the main entry point for the user to configure their identity,
 * select a destination queue, and provide optional client metadata.
 */
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun DiscoveryScreen(viewModel: CallViewModel) {
    val destinations by viewModel.destinations.collectAsState()
    val isLoading by viewModel.isLoading.collectAsState()
    val selectedDestination by viewModel.selectedDestination.collectAsState()
    val callState by viewModel.callState.collectAsState()
    val useNativeUI by viewModel.useNativeUI.collectAsState()

    // New: State for managing dynamic client data fields
    val clientDataFields by viewModel.clientDataFields.collectAsState()

    var expanded by remember { mutableStateOf(false) }

    // Active Call Banner for Native UI mode
    if (useNativeUI && callState == CallState.CONNECTED) {
        Card(
            colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.primaryContainer),
            modifier = Modifier.fillMaxWidth().padding(horizontal = 24.dp, vertical = 8.dp)
        ) {
            Row(
                modifier = Modifier.padding(12.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                Text("📞 Call Active (System Dialer)", style = MaterialTheme.typography.bodyMedium)
                Spacer(Modifier.weight(1f))
                TextButton(onClick = { viewModel.endCall() }) {
                    Text("End Call", color = MaterialTheme.colorScheme.error)
                }
            }
        }
    }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .statusBarsPadding()
            .navigationBarsPadding()
            .padding(24.dp)
            .verticalScroll(rememberScrollState())
    ) {
        // --- Section: User Identity ---
        Text("User Identity", style = MaterialTheme.typography.titleLarge)
        Spacer(modifier = Modifier.height(16.dp))

        OutlinedTextField(
            value = viewModel.userFullName.value,
            onValueChange = { viewModel.userFullName.value = it },
            label = { Text("Full Name") },
            modifier = Modifier.fillMaxWidth()
        )

        Spacer(modifier = Modifier.height(12.dp))

        OutlinedTextField(
            value = viewModel.userPhoneNumber.value,
            onValueChange = { viewModel.userPhoneNumber.value = it },
            label = { Text("Phone Number") },
            modifier = Modifier.fillMaxWidth()
        )

        // --- Section: Dialer Mode ---
        Spacer(modifier = Modifier.height(24.dp))
        HorizontalDivider()
        Row(
            modifier = Modifier.fillMaxWidth().padding(vertical = 12.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Column(modifier = Modifier.weight(1f)) {
                Text("Almost Native Dialer", style = MaterialTheme.typography.bodyLarge)
                Text(
                    "Integrate with system call interface",
                    style = MaterialTheme.typography.bodySmall,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
            }
            Switch(
                checked = useNativeUI,
                onCheckedChange = { viewModel.toggleUIPreference(it) }
            )
        }
        HorizontalDivider()

        // --- Section: Optional Client Data (iOS Parity) ---
        Spacer(modifier = Modifier.height(24.dp))
        Row(verticalAlignment = Alignment.CenterVertically) {
            Text("Client Data", style = MaterialTheme.typography.titleLarge)
            Spacer(modifier = Modifier.weight(1f))
            IconButton(onClick = { viewModel.addClientDataField() }) {
                Icon(Icons.Default.Add, contentDescription = "Add Field")
            }
        }

        clientDataFields.forEachIndexed { index, pair ->
            Row(
                modifier = Modifier.fillMaxWidth().padding(vertical = 4.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                OutlinedTextField(
                    value = pair.first,
                    onValueChange = { viewModel.updateClientDataKey(index, it) },
                    label = { Text("Key") },
                    modifier = Modifier.weight(1f)
                )
                Spacer(modifier = Modifier.width(8.dp))
                OutlinedTextField(
                    value = pair.second,
                    onValueChange = { viewModel.updateClientDataValue(index, it) },
                    label = { Text("Value") },
                    modifier = Modifier.weight(1f)
                )
                IconButton(onClick = { viewModel.removeClientDataField(index) }) {
                    Icon(Icons.Default.Delete, contentDescription = "Remove", tint = MaterialTheme.colorScheme.error)
                }
            }
        }

        // --- Section: Destination ---
        Spacer(modifier = Modifier.height(32.dp))
        Text("Destination", style = MaterialTheme.typography.titleLarge)
        Spacer(modifier = Modifier.height(16.dp))

        ExposedDropdownMenuBox(
            expanded = expanded,
            onExpandedChange = { expanded = !expanded }
        ) {
            OutlinedTextField(
                value = selectedDestination.ifEmpty { "Select Target Queue" },
                onValueChange = {},
                readOnly = true,
                label = { Text("Queues") },
                trailingIcon = { ExposedDropdownMenuDefaults.TrailingIcon(expanded) },
                modifier = Modifier.menuAnchor().fillMaxWidth()
            )

            ExposedDropdownMenu(
                expanded = expanded,
                onDismissRequest = { expanded = false }
            ) {
                destinations.forEach { name ->
                    DropdownMenuItem(
                        text = { Text(name) },
                        onClick = {
                            viewModel.updateSelectedDestination(name)
                            expanded = false
                        }
                    )
                }
            }
        }

        Spacer(modifier = Modifier.height(48.dp))

        // --- Action Button ---
        Button(
            onClick = { viewModel.makeTestCall(selectedDestination) },
            enabled = selectedDestination.isNotEmpty() && !isLoading,
            modifier = Modifier.fillMaxWidth().height(56.dp)
        ) {
            Text(if (isLoading) "Establishing Session..." else "Initiate Call")
        }

        Spacer(modifier = Modifier.height(24.dp))
    }
}