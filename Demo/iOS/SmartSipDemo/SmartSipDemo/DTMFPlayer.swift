//
//  DTMFPlayer.swift
//  SmartSipDemo
//
//  Created by Franz Iacob on 17/01/2026.
//

import Foundation
import AudioToolbox

/// A dedicated utility for the Demo App to play DTMF audio feedback.
class DTMFPlayer {
    static let shared = DTMFPlayer()
    
    private init() {}

    /// Plays the high-fidelity system DTMF tone for a specific digit.
    /// - Parameter digit: A string ("0"-"9", "*", or "#")
    func playTone(for digit: String) {
        // SystemSoundIDs 1200-1211 are the native iOS DTMF tones
        let toneMap: [String: SystemSoundID] = [
            "1": 1200, "2": 1201, "3": 1202,
            "4": 1203, "5": 1204, "6": 1205,
            "7": 1206, "8": 1207, "9": 1208,
            "0": 1209, "*": 1210, "#": 1211
        ]
        
        if let soundID = toneMap[digit] {
            AudioServicesPlaySystemSound(soundID)
        }
    }
}
