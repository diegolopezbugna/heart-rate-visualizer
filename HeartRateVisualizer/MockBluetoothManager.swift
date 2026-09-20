//
//  MockBluetoothManager.swift
//  HeartRateVisualizer
//
//  Created by Diego López Bugna on 19/09/2026.
//

import Foundation

@Observable
class MockBluetoothManager: BluetoothManagerProtocol {
    // Bluetooth state
    var isScanning = false
    var isConnected = false
    var connectionStatus = "Not Connected"
    
    // Heart rate data
    var heartRate: Int = 0
    var sensorLocation: String = "Unknown"
    
    // Mock discovered devices
    var discoveredDevices: [MockPeripheral] = []
    
    // Timer for heart rate simulation
    private var heartRateTimer: Timer?
    private var scanTimer: Timer?
    
    init() {
        connectionStatus = "Bluetooth Ready (Simulator Mode)"
    }
    
    func startScanning() {
        discoveredDevices.removeAll()
        isScanning = true
        connectionStatus = "Scanning..."
        
        // Simulate discovering devices after 1 second
        scanTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { [weak self] _ in
            self?.simulateDeviceDiscovery()
        }
    }
    
    func stopScanning() {
        scanTimer?.invalidate()
        scanTimer = nil
        isScanning = false
        if !isConnected {
            connectionStatus = "Not Connected"
        }
    }
    
    func connect(to peripheral: MockPeripheral) {
        stopScanning()
        connectionStatus = "Connecting..."
        
        // Simulate connection delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            self?.isConnected = true
            self?.connectionStatus = "Connected to \(peripheral.name ?? "Device")"
            self?.sensorLocation = "Chest"
            self?.startHeartRateSimulation()
        }
    }
    
    func disconnect() {
        stopHeartRateSimulation()
        isConnected = false
        connectionStatus = "Disconnected"
        heartRate = 0
        sensorLocation = "Unknown"
    }
    
    // MARK: - Private Methods
    
    private func simulateDeviceDiscovery() {
        // Add some mock devices
        discoveredDevices = [
            MockPeripheral(name: "Cycplus H2", identifier: UUID(uuidString: "A1B2C3D4-E5F6-7890-ABCD-EF1234567890")!),
            MockPeripheral(name: "Heart Rate Monitor", identifier: UUID(uuidString: "B2C3D4E5-F6A7-8901-BCDE-F12345678901")!),
            MockPeripheral(name: "HR Sensor Pro", identifier: UUID(uuidString: "C3D4E5F6-A7B8-9012-CDEF-123456789012")!)
        ]
        isScanning = false
        connectionStatus = "Found \(discoveredDevices.count) devices"
    }
    
    private func startHeartRateSimulation() {
        // Start with a base heart rate around 100 BPM
        heartRate = 120
        
        // Update heart rate every second with realistic variation
        heartRateTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            // Simulate realistic heart rate variation
            let time = Date().timeIntervalSince1970
            let cycle = sin(time / 10.0) * 25.0  // Slow cycle
            let noise = Double.random(in: -3...3)  // Random variation
            let baseRate = 120.0
            
            self.heartRate = Int(baseRate + cycle + noise)
        }
    }
    
    private func stopHeartRateSimulation() {
        heartRateTimer?.invalidate()
        heartRateTimer = nil
    }
}

// MARK: - Mock Peripheral

struct MockPeripheral: Identifiable {
    let id: String
    let name: String?
    let identifier: UUID
    
    init(name: String, identifier: UUID) {
        self.id = identifier.uuidString
        self.name = name
        self.identifier = identifier
    }
}
