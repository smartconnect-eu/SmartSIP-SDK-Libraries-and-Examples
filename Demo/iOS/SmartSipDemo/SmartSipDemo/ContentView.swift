//
//  ContentView.swift
//  SmartSipDemo
//
//  Created by Franz Iacob on 09/01/2026.
//
import SwiftUI
import smartsip_sdk

struct ContentView: View {
    @StateObject private var viewModel = CallViewModel()

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 1. Flow Switcher at the top
                Picker("Call Flow", selection: $viewModel.activeFlow) {
                    Text("Native (CallKit)").tag(CallFlow.callKit)
                    Text("Custom (Blue)").tag(CallFlow.customUI)
                }
                .pickerStyle(.segmented)
                .padding()
                .background(Color(.systemBackground))
                
                Divider()

                // 2. Main Configuration Form
                Form {
                    Section(header: Text("User Identity")) {
                        TextField("Full Name", text: $viewModel.userFullName)
                            .textContentType(.name)
                        TextField("Phone Number", text: $viewModel.userPhoneNumber)
                            .keyboardType(.phonePad)
                    }
                    
                    Section(header: Text("Destination")) {
                        Picker("Select Target", selection: $viewModel.selectedDestination) {
                            if viewModel.destinations.isEmpty {
                                Text("Loading targets...").tag("")
                            } else {
                                ForEach(viewModel.destinations, id: \.self) { dest in
                                    Text(dest).tag(dest)
                                }
                            }
                        }
                    }

                    Section(header: Text("Extra Client Data (JSON)")) {
                        TextField("e.g. {\"custom_id\": 123}", text: $viewModel.clientDataString, axis: .vertical)
                            .lineLimit(3...6)
                            .font(.system(.body, design: .monospaced))
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                        
                        if let error = viewModel.jsonErrorMessage {
                            Text(error)
                                .font(.caption2)
                                .foregroundStyle(.red)
                        }
                    }

                    Section {
                        Button(action: {
                            viewModel.startTestCall()
                        }) {
                            HStack {
                                Spacer()
                                Label(viewModel.isCallActive ? "Call Active" : "Initiate Call",
                                      systemImage: viewModel.isCallActive ? "phone.fill" : "phone.arrow.up.right")
                                    .bold()
                                Spacer()
                            }
                        }
                        .disabled(viewModel.selectedDestination.isEmpty || viewModel.isCallActive)
                        .foregroundColor(viewModel.selectedDestination.isEmpty ? .gray : .blue)
                    }
                }
            }
            .navigationTitle("SmartSip SDK")
            .navigationBarTitleDisplayMode(.inline)
            
            // 3. The Custom Blue Dialer Overlay
            .fullScreenCover(isPresented: $viewModel.showCustomUI) {
                BlueInCallView(viewModel: viewModel)
            }
        }
    }
}

#Preview {
    ContentView()
}
