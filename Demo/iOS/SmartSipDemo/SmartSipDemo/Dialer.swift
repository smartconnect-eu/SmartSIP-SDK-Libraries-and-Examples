import SwiftUI
import smartsip_sdk

struct BlueInCallView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: CallViewModel
    let grid = [["1", "2", "3"], ["4", "5", "6"], ["7", "8", "9"], ["*", "0", "#"]]

    var body: some View {
        VStack(spacing: 30) {
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
            VStack(spacing: 20) {
                ForEach(grid, id: \.self) { row in
                    HStack(spacing: 35) {
                        ForEach(row, id: \.self) { digit in
                            DialerDigitCircle(digit: digit)
                        }
                    }
                }
            }

            Spacer()

            // In-Call Controls (Mute & Speaker)
            HStack(spacing: 50) {
                ControlToggle(
                    isActive: viewModel.isMuted,
                    onIcon: "mic.slash.fill",
                    offIcon: "mic.fill",
                    label: "Mute",
                    action: { viewModel.toggleMute() }
                )

                ControlToggle(
                    isActive: viewModel.isSpeakerOn,
                    onIcon: "speaker.wave.3.fill",
                    offIcon: "speaker.fill",
                    label: "Speaker",
                    action: { viewModel.toggleSpeaker() }
                )
            }
            .padding(.bottom, 10)

            // Action Button (Hang Up)
            Button(action: {
                if viewModel.isCallActive {
                    viewModel.endTestCall()
                } else {
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

struct ControlToggle: View {
    let isActive: Bool
    let onIcon: String
    let offIcon: String
    let label: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(isActive ? Color.blue : Color.blue.opacity(0.1))
                        .frame(width: 65, height: 65)
                    Image(systemName: isActive ? onIcon : offIcon)
                        .font(.title3)
                        .foregroundColor(isActive ? .white : .blue)
                }
                Text(label)
                    .font(.caption2.bold())
                    .foregroundColor(.blue)
            }
        }
    }
}

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
