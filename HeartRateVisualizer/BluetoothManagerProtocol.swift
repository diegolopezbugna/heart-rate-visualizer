//
//  BluetoothManagerProtocol.swift
//  HeartRateVisualizer
//
//  Created by Diego López Bugna on 19/09/2026.
//

import Foundation

protocol BluetoothManagerProtocol: AnyObject, Observable {
    var isScanning: Bool { get set }
    var isConnected: Bool { get set }
    var connectionStatus: String { get set }
    var heartRate: Int { get set }
    var sensorLocation: String { get set }
    
    func startScanning()
    func stopScanning()
    func disconnect()
}
