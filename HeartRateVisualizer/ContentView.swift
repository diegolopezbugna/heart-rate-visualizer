//
//  ContentView.swift
//  HeartRateVisualizer
//
//  Created by Diego López Bugna on 19/09/2026.
//

import SwiftUI
import AVFoundation
import CoreBluetooth

struct ContentView: View {
    // Automatically use mock manager in simulator, real manager on device
    #if targetEnvironment(simulator)
    @State private var bluetoothManager = MockBluetoothManager()
    #else
    @State private var bluetoothManager = BluetoothManager()
    #endif
    
    @State private var showDeviceList = false
    @State private var showSettings = false
    
    // Heart rate settings and alerts
    @State private var settings = HeartRateSettings()
    @State private var alertManager = HeartRateAlertManager()
    
    private var useMock: Bool {
        #if targetEnvironment(simulator)
        return true
        #else
        return false
        #endif
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                // Simulator Badge
                if useMock {
                    Label("Simulator Mode", systemImage: "app.dashed")
                        .font(.caption)
                        .foregroundStyle(.orange)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(.orange.opacity(0.2))
                        .clipShape(Capsule())
                }
                
                // Heart Rate Display
                VStack(spacing: 10) {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 80))
                        .foregroundStyle(heartRateColor)
                        .symbolEffect(.pulse, value: bluetoothManager.heartRate)
                    
                    Text("\(bluetoothManager.heartRate)")
                        .font(.system(size: 80, weight: .bold, design: .rounded))
                        .contentTransition(.numericText())
                    
                    Text("BPM")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                    
                    // Zone indicator
                    if settings.isConfigured && bluetoothManager.isConnected && bluetoothManager.heartRate > 0 {
                        ZoneIndicatorView(
                            heartRate: bluetoothManager.heartRate,
                            settings: settings
                        )
                        .transition(.scale.combined(with: .opacity))
                    }
                }
                .padding()
                .animation(.easeInOut, value: bluetoothManager.heartRate)
                
                // Connection Status
                VStack(spacing: 5) {
                    HStack {
                        Circle()
                            .fill(bluetoothManager.isConnected ? .green : .gray)
                            .frame(width: 10, height: 10)
                        
                        Text(bluetoothManager.connectionStatus)
                            .font(.headline)
                    }
                    
                    if bluetoothManager.isConnected {
                        Text("Sensor Location: \(bluetoothManager.sensorLocation)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                
                Spacer()
                
                // Action Buttons
                VStack(spacing: 15) {
                    if !bluetoothManager.isConnected {
                        Button(action: {
                            showDeviceList = true
                            bluetoothManager.startScanning()
                        }) {
                            HStack {
                                Image(systemName: "antenna.radiowaves.left.and.right")
                                Text("Scan for Devices")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(.blue)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    } else {
                        Button(action: {
                            bluetoothManager.disconnect()
                        }) {
                            HStack {
                                Image(systemName: "xmark.circle")
                                Text("Disconnect")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(.red)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                }
                .padding(.horizontal)
            }
            .padding()
            .navigationTitle("Heart Rate Monitor")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        showSettings = true
                    }) {
                        Image(systemName: "gearshape")
                    }
                }
            }
            .sheet(isPresented: $showDeviceList) {
                DeviceListView(bluetoothManager: bluetoothManager, isPresented: $showDeviceList)
            }
            .sheet(isPresented: $showSettings) {
                SettingsView(settings: settings)
            }
            .onChange(of: bluetoothManager.heartRate) { oldValue, newValue in
                // Check heart rate and play alerts if needed
                alertManager.checkAndAlert(
                    heartRate: newValue,
                    settings: settings,
                    isConnected: bluetoothManager.isConnected
                )
            }
            .onChange(of: bluetoothManager.isConnected) { oldValue, newValue in
                print("isConnected: \(newValue)")
                UIApplication.shared.isIdleTimerDisabled = newValue
            }
        }
    }
    
    // Computed property for heart rate color based on zone
    private var heartRateColor: Color {
        guard settings.isConfigured, bluetoothManager.isConnected, bluetoothManager.heartRate > 0 else {
            return .red
        }
        
        let zone = settings.checkHeartRate(bluetoothManager.heartRate)
        switch zone {
        case .belowTarget: return .blue
        case .inTarget: return .green
        case .aboveTarget: return .red
        case .normal: return .gray
        }
    }
}

// MARK: - Zone Indicator View

struct ZoneIndicatorView: View {
    let heartRate: Int
    let settings: HeartRateSettings
    
    var body: some View {
        let zone = settings.checkHeartRate(heartRate)
        let percentage = settings.getPercentageOfMax(for: heartRate)
        
        VStack(spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: zone.icon)
                    .foregroundStyle(zoneColor)
                
                Text(settings.getZoneDescription(for: heartRate))
                    .font(.headline)
                    .foregroundStyle(zoneColor)
            }
            
            Text("\(percentage)% of max")
                .font(.caption)
                .foregroundStyle(.secondary)
            
            // Visual bar indicator
            ZStack(alignment: .leading) {
                // Background
                RoundedRectangle(cornerRadius: 4)
                    .fill(.gray.opacity(0.2))
                    .frame(height: 8)
                
                // Target zone (70-80%)
                GeometryReader { geometry in
                    let width = geometry.size.width
                    let targetStart = width * 0.7
                    let targetWidth = width * 0.1
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(.green.opacity(0.3))
                        .frame(width: targetWidth, height: 8)
                        .offset(x: targetStart)
                }
                
                // Current position
                GeometryReader { geometry in
                    let width = geometry.size.width
                    let position = min(max(CGFloat(percentage) / 100.0, 0), 1.0) * width
                    
                    Circle()
                        .fill(zoneColor)
                        .frame(width: 16, height: 16)
                        .offset(x: position - 8, y: -4)
                }
            }
            .frame(height: 16)
            .padding(.horizontal)
            
            HStack {
                Text("0%")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                Text("70%")
                    .font(.caption2)
                    .foregroundStyle(.green)
                
                Text("80%")
                    .font(.caption2)
                    .foregroundStyle(.green)
                
                Spacer()
                
                Text("100%")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal)
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    private var zoneColor: Color {
        let zone = settings.checkHeartRate(heartRate)
        switch zone {
        case .belowTarget: return .blue
        case .inTarget: return .green
        case .aboveTarget: return .red
        case .normal: return .gray
        }
    }
}

struct DeviceListView: View {
    #if targetEnvironment(simulator)
    var bluetoothManager: MockBluetoothManager
    #else
    var bluetoothManager: BluetoothManager
    #endif
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationStack {
            List {
                if bluetoothManager.discoveredDevices.isEmpty {
                    ContentUnavailableView(
                        "No Devices Found",
                        systemImage: "antenna.radiowaves.left.and.right.slash",
                        description: Text("Make sure your Cycplus H2 sensor is powered on and in pairing mode.")
                    )
                } else {
                    ForEach(bluetoothManager.discoveredDevices, id: \.identifier) { device in
                        Button(action: {
                            bluetoothManager.connect(to: device)
                            isPresented = false
                        }) {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(device.name ?? "Unknown Device")
                                        .font(.headline)
                                    Text(device.identifier.uuidString)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Select Device")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        bluetoothManager.stopScanning()
                        isPresented = false
                    }
                }
                
                ToolbarItem(placement: .primaryAction) {
                    if bluetoothManager.isScanning {
                        ProgressView()
                    }
                }
            }
            .onDisappear {
                bluetoothManager.stopScanning()
            }
        }
    }
}

#Preview("Simulator Mode") {
    ContentView()
}
