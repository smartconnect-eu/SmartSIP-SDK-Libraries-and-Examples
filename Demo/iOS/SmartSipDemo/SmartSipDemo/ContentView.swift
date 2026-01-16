//
//  ContentView.swift
//  SmartSipDemo
//
//  Created by Franz Iacob on 09/01/2026.
//

import SwiftUI

import SwiftUI
struct ContentView: View {
    @StateObject private var viewModel = CallViewModel()

    var body: some View {
        ScrollView { // Added ScrollView in case keyboard covers fields
            VStack(spacing: 25) {
                // Header
                VStack {
                    Image(systemName: "phone.circle.fill")
                        .resizable()
                        .frame(width: 70, height: 70)
                        .foregroundStyle(viewModel.isCallActive ? .green : .blue)
                    
                    Text("SmartSip SDK Tester")
                        .font(.headline)
                }
                
                // --- New User Info Fields ---
                VStack(spacing: 15) {
                    VStack(alignment: .leading) {
                        Text("Caller Name").font(.caption).foregroundStyle(.secondary)
                        TextField("Enter Full Name", text: $viewModel.userFullName)
                            .textFieldStyle(.roundedBorder)
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Caller Phone Number").font(.caption).foregroundStyle(.secondary)
                        TextField("Enter Phone Number", text: $viewModel.userPhoneNumber)
                            .textFieldStyle(.roundedBorder)
                            .keyboardType(.phonePad)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.05))
                .cornerRadius(10)
                .disabled(viewModel.isCallActive)
                // ----------------------------
                
                //extra data
                VStack(alignment: .leading, spacing: 15) {
                    Text("Extra Client Data (JSON Dictionary)")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    // Using an Axis: .vertical TextField (iOS 16+)
                    // This allows the box to expand as the user types
                    TextField("e.g. {\"custom_id\": 123}", text: $viewModel.clientDataString, axis: .vertical)
                        .lineLimit(3...6) // Sets a minimum and maximum height
                        .font(.system(.body, design: .monospaced)) // Monospaced looks better for JSON
                        .padding(10)
                        .background(Color.black.opacity(0.05))
                        .cornerRadius(8)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                    
                    if let error = viewModel.jsonErrorMessage {
                        Text(error)
                            .font(.caption2)
                            .foregroundStyle(.red)
                    }
                }
                .padding()
                .background(Color.blue.opacity(0.05))
                .cornerRadius(10)
                .disabled(viewModel.isCallActive)

                // Destination Selector
                VStack(alignment: .leading, spacing: 8) {
                    Text("Select Destination")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Picker("Destination", selection: $viewModel.selectedDestination) {
                        if viewModel.destinations.isEmpty {
                            Text("Loading destinations...").tag("")
                        } else {
                            ForEach(viewModel.destinations, id: \.self) { dest in
                                Text(dest).tag(dest)
                            }
                        }
                    }
                    .pickerStyle(.menu)
                    .frame(maxWidth: .infinity)
                    .padding(5)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                    .disabled(viewModel.isCallActive)
                }
                
                // Status Label
                VStack(alignment: .leading, spacing: 8) {
                    Text("Connection Status")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Text(viewModel.callStatus)
                        .font(.system(.body, design: .monospaced))
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.black.opacity(0.05))
                        .cornerRadius(8)
                }
                
                // Action Button
                if !viewModel.isCallActive {
                    Button(action: { viewModel.startTestCall() }) {
                        Label("Start Call", systemImage: "phone.fill")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(viewModel.selectedDestination.isEmpty ? Color.gray : Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                    .disabled(viewModel.selectedDestination.isEmpty)
                } else {
                    Button(action: { viewModel.endTestCall() }) {
                        Label("End Call", systemImage: "phone.down.fill")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                }
                
                Spacer()
            }
            .padding(30)
        }
    }
}

#Preview {
    ContentView()
}
