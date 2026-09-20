//
//  HeartRateSettings.swift
//  HeartRateVisualizer
//
//  Created by Diego López Bugna on 19/09/2026.
//

import Foundation

@Observable
class HeartRateSettings {
    // User configuration
    var age: Int? {
        didSet {
            UserDefaults.standard.set(age, forKey: "userAge")
            calculateZones()
        }
    }
    
    // Calculated zones
    private(set) var maxHeartRate: Int = 0
    private(set) var targetZoneMin: Int = 0  // 70%
    private(set) var targetZoneMax: Int = 0  // 80%
    
    // Alert state
    private(set) var currentZone: HeartRateZone = .normal
    
    init() {
        // Load saved age
        let savedAge = UserDefaults.standard.integer(forKey: "userAge")
        if savedAge > 0 {
            self.age = savedAge
            calculateZones()
        }
    }
    
    // Calculate heart rate zones based on age
    private func calculateZones() {
        guard let age = age, age > 0 else {
            maxHeartRate = 0
            targetZoneMin = 0
            targetZoneMax = 0
            return
        }
        
        // Formula: 220 - age = max heart rate
        maxHeartRate = 220 - age
        
        // Target zone: 70% - 80% of max
        targetZoneMin = Int(Double(maxHeartRate) * 0.70)
        targetZoneMax = Int(Double(maxHeartRate) * 0.80)
    }
    
    // Check current heart rate and return zone
    func checkHeartRate(_ heartRate: Int) -> HeartRateZone {
        guard age != nil, heartRate > 0 else {
            return .normal
        }
        
        if heartRate < targetZoneMin {
            currentZone = .belowTarget
        } else if heartRate > targetZoneMax {
            currentZone = .aboveTarget
        } else {
            currentZone = .inTarget
        }
        
        return currentZone
    }
    
    // Get zone description
    func getZoneDescription(for heartRate: Int) -> String {
        let zone = checkHeartRate(heartRate)
        
        switch zone {
        case .belowTarget:
            return "Below Target Zone"
        case .inTarget:
            return "In Target Zone"
        case .aboveTarget:
            return "Above Target Zone"
        case .normal:
            return "Not Configured"
        }
    }
    
    // Get percentage of max heart rate
    func getPercentageOfMax(for heartRate: Int) -> Int {
        guard maxHeartRate > 0 else { return 0 }
        return Int((Double(heartRate) / Double(maxHeartRate)) * 100)
    }
    
    var isConfigured: Bool {
        return age != nil && age! > 0
    }
}

// MARK: - Heart Rate Zone Enum

enum HeartRateZone {
    case belowTarget  // < 70%
    case inTarget     // 70% - 80%
    case aboveTarget  // > 80%
    case normal       // Not configured or no reading
    
    var color: String {
        switch self {
        case .belowTarget: return "blue"
        case .inTarget: return "green"
        case .aboveTarget: return "red"
        case .normal: return "gray"
        }
    }
    
    var icon: String {
        switch self {
        case .belowTarget: return "arrow.down.circle.fill"
        case .inTarget: return "checkmark.circle.fill"
        case .aboveTarget: return "arrow.up.circle.fill"
        case .normal: return "circle"
        }
    }
}
