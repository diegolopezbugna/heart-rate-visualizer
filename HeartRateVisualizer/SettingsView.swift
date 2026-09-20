//
//  SettingsView.swift
//  HeartRateVisualizer
//
//  Created by Diego López Bugna on 19/09/2026.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var settings: HeartRateSettings
    
    @State private var ageInput: String = ""
    @State private var showValidation = false
    
    var body: some View {
        NavigationStack {
            Form {
                // Age Configuration Section
                Section {
                    HStack {
                        Text("Age")
                            .font(.headline)
                        
                        Spacer()
                        
                        TextField("Enter age", text: $ageInput)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 100)
                            .textFieldStyle(.roundedBorder)
                    }
                    
                    if showValidation && !isValidAge {
                        Text("Please enter a valid age (10-100)")
                            .font(.caption)
                            .foregroundStyle(.red)
                    }
                } header: {
                    Text("Personal Information")
                } footer: {
                    Text("Your age is used to calculate your maximum heart rate and target training zones.")
                }
                
                // Calculated Zones Section
                if settings.isConfigured {
                    Section {
                        HStack {
                            Text("Maximum Heart Rate")
                            Spacer()
                            Text("\(settings.maxHeartRate) BPM")
                                .foregroundStyle(.secondary)
                        }
                        
                        HStack {
                            Text("Target Zone (70%)")
                            Spacer()
                            Text("\(settings.targetZoneMin) BPM")
                                .foregroundStyle(.blue)
                        }
                        
                        HStack {
                            Text("Target Zone (80%)")
                            Spacer()
                            Text("\(settings.targetZoneMax) BPM")
                                .foregroundStyle(.red)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Your Target Zone")
                                .font(.headline)
                            
                            Text("\(settings.targetZoneMin) - \(settings.targetZoneMax) BPM")
                                .font(.title2)
                                .bold()
                                .foregroundStyle(.green)
                        }
                        .padding(.vertical, 4)
                        
                    } header: {
                        Text("Calculated Zones")
                    } footer: {
                        Text("Stay within your target zone for optimal training. The app will alert you if your heart rate goes below 70% or above 80%.")
                    }
                    
                    // Zone Explanation
                    Section {
                        ZoneInfoRow(
                            title: "Below Target (<70%)",
                            color: .blue,
                            icon: "arrow.down.circle.fill",
                            description: "Too low - increase intensity"
                        )
                        
                        ZoneInfoRow(
                            title: "Target Zone (70-80%)",
                            color: .green,
                            icon: "checkmark.circle.fill",
                            description: "Perfect training zone"
                        )
                        
                        ZoneInfoRow(
                            title: "Above Target (>80%)",
                            color: .red,
                            icon: "arrow.up.circle.fill",
                            description: "Too high - reduce intensity"
                        )
                    } header: {
                        Text("Zone Descriptions")
                    }
                }
                
                // Save Button
                Section {
                    Button(action: saveSettings) {
                        HStack {
                            Spacer()
                            Text("Save Configuration")
                                .fontWeight(.semibold)
                            Spacer()
                        }
                    }
                    .disabled(!isValidAge)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                if let age = settings.age {
                    ageInput = "\(age)"
                }
            }
        }
    }
    
    private var isValidAge: Bool {
        guard let age = Int(ageInput) else { return false }
        return age >= 10 && age <= 100
    }
    
    private func saveSettings() {
        showValidation = true
        
        guard isValidAge, let age = Int(ageInput) else {
            return
        }
        
        settings.age = age
        dismiss()
    }
}

// MARK: - Zone Info Row

struct ZoneInfoRow: View {
    let title: String
    let color: Color
    let icon: String
    let description: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                
                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    SettingsView(settings: HeartRateSettings())
}
