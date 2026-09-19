//
//  ContentView.swift
//  HeartRateVisualizer
//
//  Created by Diego López Bugna on 19/09/2026.
//

import SwiftUI
import CoreBluetooth

struct ContentView: View {
    @State private var bluetoothManager = BluetoothManager()
    @State private var showDeviceList = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                // Heart Rate Display
                VStack(spacing: 10) {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 80))
                        .foregroundStyle(.red)
                        .symbolEffect(.pulse, value: bluetoothManager.heartRate)
                    
                    Text("\(bluetoothManager.heartRate)")
                        .font(.system(size: 80, weight: .bold, design: .rounded))
                        .contentTransition(.numericText())
                    
                    Text("BPM")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                }
                .padding()
                
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
            .sheet(isPresented: $showDeviceList) {
                DeviceListView(bluetoothManager: bluetoothManager, isPresented: $showDeviceList)
            }
        }
    }
}

struct DeviceListView: View {
    var bluetoothManager: BluetoothManager
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

#Preview {
    ContentView()
}
