//
//  ContentView.swift
//  SmartSipTest
//
//  Created by Franz Iacob on 09/01/2026.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = CallViewModel()

    var body: some View {
        VStack(spacing: 30) {
            // Header
            VStack {
                Image(systemName: "phone.circle.fill")
                    .resizable()
                    .frame(width: 80, height: 80)
                    .foregroundStyle(viewModel.isCallActive ? .green : .blue)
                
                Text("SmartSip SDK Tester")
                    .font(.headline)
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
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
            }
            
            // Action Button
            if !viewModel.isCallActive {
                Button(action: { viewModel.startTestCall() }) {
                    Label("Start Test Call", systemImage: "phone.fill")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
            } else {
                Button(action: { viewModel.endTestCall() }) {
                    Label("End Call", systemImage: "phone.down.fill")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
            }
            
            Spacer()
        }
        .padding(40)
    }
}

#Preview {
    ContentView()
}
