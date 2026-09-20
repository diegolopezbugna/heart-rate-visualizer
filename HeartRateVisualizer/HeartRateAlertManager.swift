//
//  HeartRateAlertManager.swift
//  HeartRateVisualizer
//
//  Created by Diego López Bugna on 19/09/2026.
//

import Foundation
import AVFoundation
#if canImport(UIKit)
import UIKit
#endif

@Observable
class HeartRateAlertManager {
    private var audioPlayer: AVAudioPlayer?
    private var lastZone: HeartRateZone = .normal
    private var isPlayingAlert = false
    
    // Check heart rate and play alert if needed
    func checkAndAlert(heartRate: Int, settings: HeartRateSettings, isConnected: Bool) {
        guard isConnected, settings.isConfigured, heartRate > 0 else {
            stopAlert()
            return
        }
        
        let currentZone = settings.checkHeartRate(heartRate)
        
        // Only play alert if zone changed or if we're still out of target
        if currentZone != lastZone {
            lastZone = currentZone
            
            switch currentZone {
            case .belowTarget:
                playBelowTargetAlert()
            case .aboveTarget:
                playAboveTargetAlert()
            case .inTarget:
                stopAlert()
            case .normal:
                stopAlert()
            }
        }
    }
    
    private func playBelowTargetAlert() {
        // Play a low-pitched beep for below target
        playSystemSound(id: 1054) // Low beep
        scheduleRepeatingAlert()
    }
    
    private func playAboveTargetAlert() {
        // Play a high-pitched beep for above target
        playSystemSound(id: 1016) // High beep
        scheduleRepeatingAlert()
    }
    
    private func playSystemSound(id: SystemSoundID) {
        AudioServicesPlaySystemSound(id)
        isPlayingAlert = true
    }
    
    private func scheduleRepeatingAlert() {
        // Repeat alert every 5 seconds while out of zone
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) { [weak self] in
            guard let self = self else { return }
            
            if self.lastZone == .belowTarget {
                self.playSystemSound(id: 1054)
                self.scheduleRepeatingAlert()
            } else if self.lastZone == .aboveTarget {
                self.playSystemSound(id: 1016)
                self.scheduleRepeatingAlert()
            }
        }
    }
    
    func stopAlert() {
        isPlayingAlert = false
        audioPlayer?.stop()
        audioPlayer = nil
    }
    
    // Alternative: Use haptic feedback
    func playHapticFeedback(for zone: HeartRateZone) {
        #if !targetEnvironment(simulator)
        let generator = UINotificationFeedbackGenerator()
        
        switch zone {
        case .belowTarget:
            generator.notificationOccurred(.warning)
        case .aboveTarget:
            generator.notificationOccurred(.error)
        case .inTarget:
            generator.notificationOccurred(.success)
        case .normal:
            break
        }
        #endif
    }
}
