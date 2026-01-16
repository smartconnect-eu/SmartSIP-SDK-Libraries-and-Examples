//
//  Dialer.swift
//  SmartSipDemo
//
//  Created by Franz Iacob on 16/01/2026.
//

import SwiftUI
struct BlueInCallView: View {
    @Environment(\.dismiss) var dismiss // Alternative way to dismiss
    @ObservedObject var viewModel: CallViewModel
    let grid = [["1", "2", "3"], ["4", "5", "6"], ["7", "8", "9"], ["*", "0", "#"]]

    var body: some View {
        VStack(spacing: 40) {
            // Header
            VStack(spacing: 12) {
                Text(viewModel.selectedDestination)
                    .font(.system(size: 36, weight: .regular))
                
                Text(viewModel.callStatus.uppercased())
                    .font(.caption.bold())
                    .tracking(2)
                    .foregroundStyle(.blue)
            }
            .padding(.top, 80)

            Spacer()

            // Keypad Grid
            VStack(spacing: 25) {
                ForEach(grid, id: \.self) { row in
                    HStack(spacing: 35) {
                        ForEach(row, id: \.self) { digit in
                            DialerDigitCircle(digit: digit)
                        }
                    }
                }
            }

            Spacer()

            // Action Button
            Button(action: {
                if viewModel.isCallActive {
                    viewModel.endTestCall() // This will now dismiss the view
                } else {
                    // This handles the case if the user presses the green button
                    // from within the dialer (if you decide to keep it there)
                    viewModel.startTestCall()
                }
            }) {
                ZStack {
                    Circle()
                        .fill(viewModel.isCallActive ? Color.red : Color.green)
                        .frame(width: 85, height: 85)
                    Image(systemName: viewModel.isCallActive ? "phone.down.fill" : "phone.fill")
                        .font(.title)
                        .foregroundColor(.white)
                }
            }
            .padding(.bottom, 60)
        }
        .preferredColorScheme(.light)
        .ignoresSafeArea()
    }
}

// Subview for the individual digits
struct DialerDigitCircle: View {
    let digit: String
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.blue.opacity(0.1))
                .frame(width: 80, height: 80)
            
            Text(digit)
                .font(.system(size: 38, weight: .light))
                .foregroundColor(.blue)
        }
    }
}
