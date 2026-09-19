//
//  BluetoothManager.swift
//  HeartRateVisualizer
//
//  Created by Diego López Bugna on 19/09/2026.
//

import Foundation
import CoreBluetooth

@Observable
class BluetoothManager: NSObject {
    // Bluetooth state
    var isScanning = false
    var isConnected = false
    var connectionStatus = "Not Connected"
    
    // Heart rate data
    var heartRate: Int = 0
    var sensorLocation: String = "Unknown"
    
    // Discovered devices
    var discoveredDevices: [CBPeripheral] = []
    
    // CoreBluetooth properties
    private var centralManager: CBCentralManager!
    private var heartRatePeripheral: CBPeripheral?
    
    // Bluetooth UUIDs for Heart Rate Service (standard)
    private let heartRateServiceUUID = CBUUID(string: "180D")
    private let heartRateMeasurementCharacteristicUUID = CBUUID(string: "2A37")
    private let bodySensorLocationCharacteristicUUID = CBUUID(string: "2A38")
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func startScanning() {
        guard centralManager.state == .poweredOn else {
            connectionStatus = "Bluetooth not available"
            return
        }
        
        discoveredDevices.removeAll()
        isScanning = true
        connectionStatus = "Scanning..."
        
        // Scan for devices with Heart Rate Service
        centralManager.scanForPeripherals(
            withServices: [heartRateServiceUUID],
            options: [CBCentralManagerScanOptionAllowDuplicatesKey: false]
        )
    }
    
    func stopScanning() {
        centralManager.stopScan()
        isScanning = false
        if !isConnected {
            connectionStatus = "Not Connected"
        }
    }
    
    func connect(to peripheral: CBPeripheral) {
        stopScanning()
        heartRatePeripheral = peripheral
        connectionStatus = "Connecting..."
        centralManager.connect(peripheral, options: nil)
    }
    
    func disconnect() {
        guard let peripheral = heartRatePeripheral else { return }
        centralManager.cancelPeripheralConnection(peripheral)
    }
}

// MARK: - CBCentralManagerDelegate
extension BluetoothManager: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            connectionStatus = "Bluetooth Ready"
        case .poweredOff:
            connectionStatus = "Bluetooth is Off"
        case .unauthorized:
            connectionStatus = "Bluetooth Unauthorized"
        case .unsupported:
            connectionStatus = "Bluetooth Not Supported"
        default:
            connectionStatus = "Bluetooth Unavailable"
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
        // Check if this is a Cycplus device or any heart rate device
        let deviceName = peripheral.name ?? "Unknown Device"
        print("Discovered: \(deviceName)")
        
        // Add to discovered devices if not already there
        if !discoveredDevices.contains(where: { $0.identifier == peripheral.identifier }) {
            discoveredDevices.append(peripheral)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        isConnected = true
        connectionStatus = "Connected to \(peripheral.name ?? "Device")"
        
        peripheral.delegate = self
        peripheral.discoverServices([heartRateServiceUUID])
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        isConnected = false
        connectionStatus = "Disconnected"
        heartRate = 0
        sensorLocation = "Unknown"
        heartRatePeripheral = nil
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        isConnected = false
        connectionStatus = "Connection Failed"
        heartRatePeripheral = nil
    }
}

// MARK: - CBPeripheralDelegate
extension BluetoothManager: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        
        for service in services {
            if service.uuid == heartRateServiceUUID {
                peripheral.discoverCharacteristics(
                    [heartRateMeasurementCharacteristicUUID, bodySensorLocationCharacteristicUUID],
                    for: service
                )
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else { return }
        
        for characteristic in characteristics {
            switch characteristic.uuid {
            case heartRateMeasurementCharacteristicUUID:
                // Subscribe to heart rate notifications
                peripheral.setNotifyValue(true, for: characteristic)
                
            case bodySensorLocationCharacteristicUUID:
                // Read sensor location
                peripheral.readValue(for: characteristic)
                
            default:
                break
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        switch characteristic.uuid {
        case heartRateMeasurementCharacteristicUUID:
            if let heartRateValue = parseHeartRate(from: characteristic) {
                self.heartRate = heartRateValue
            }
            
        case bodySensorLocationCharacteristicUUID:
            if let location = parseSensorLocation(from: characteristic) {
                self.sensorLocation = location
            }
            
        default:
            break
        }
    }
    
    // Parse heart rate from characteristic data
    private func parseHeartRate(from characteristic: CBCharacteristic) -> Int? {
        guard let data = characteristic.value else { return nil }
        guard data.count > 0 else { return nil }
        
        let bytes = [UInt8](data)
        let flags = bytes[0]
        
        // Check if heart rate is in UINT8 or UINT16 format
        let is16Bit = (flags & 0x01) == 0x01
        
        if is16Bit && data.count >= 3 {
            // 16-bit format
            let value = Int(bytes[1]) | (Int(bytes[2]) << 8)
            return value
        } else if data.count >= 2 {
            // 8-bit format
            return Int(bytes[1])
        }
        
        return nil
    }
    
    // Parse sensor location
    private func parseSensorLocation(from characteristic: CBCharacteristic) -> String? {
        guard let data = characteristic.value else { return nil }
        guard data.count > 0 else { return nil }
        
        let byte = [UInt8](data)[0]
        
        switch byte {
        case 0: return "Other"
        case 1: return "Chest"
        case 2: return "Wrist"
        case 3: return "Finger"
        case 4: return "Hand"
        case 5: return "Ear Lobe"
        case 6: return "Foot"
        default: return "Unknown"
        }
    }
}
