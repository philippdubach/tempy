//
//  ContentView.swift
//  Tempy
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var temperatureService: TemperatureService
    @EnvironmentObject var displayModeManager: DisplayModeManager
    
    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 16) {
                if temperatureService.isLoading {
                    VStack(spacing: 12) {
                        ProgressView()
                            .scaleEffect(0.8)
                        Text("Loading temperatures...")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                } else if let error = temperatureService.errorMessage {
                    VStack(spacing: 12) {
                        Image(systemName: "exclamationmark.triangle")
                            .foregroundStyle(.orange)
                            .font(.title2)
                        Text("Error")
                            .font(.headline)
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        Button("Retry") {
                            temperatureService.fetchTemperature()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                } else if let data = temperatureService.temperatureData {
                    VStack(spacing: 16) {
                        if displayModeManager.displayMode == .outsideOnly {
                            TemperatureDisplay(
                                label: "Outside",
                                value: data.outside,
                                icon: "sun.max"
                            )
                        } else {
                            TemperatureDisplay(
                                label: "Inside",
                                value: data.inside,
                                icon: "house"
                            )
                        }
                        
                        if let lastUpdate = temperatureService.lastUpdateTime {
                            Text("Updated: \(lastUpdate, style: .relative)")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        
                        Picker("", selection: $displayModeManager.displayMode) {
                            ForEach(DisplayMode.allCases, id: \.self) { mode in
                                Text(mode.displayName).tag(mode)
                            }
                        }
                        .pickerStyle(.segmented)
                        .controlSize(.small)
                        .padding(.top, 4)
                        
                        Button(action: {
                            temperatureService.fetchTemperature()
                        }) {
                            HStack {
                                Image(systemName: "arrow.clockwise")
                                Text("Refresh")
                            }
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                    }
                    .padding(.vertical, 8)
                } else {
                    VStack(spacing: 12) {
                        Text("No data available")
                            .foregroundColor(.secondary)
                        Button("Refresh") {
                            temperatureService.fetchTemperature()
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                }
            }
            .padding(20)
            .frame(maxWidth: .infinity)
            
            Divider()
            
            Button(action: {
                NSApplication.shared.terminate(nil)
            }) {
                HStack {
                    Image(systemName: "power")
                        .font(.caption)
                    Text("Quit Tempy")
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .foregroundColor(.primary)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
        }
        .frame(width: 280)
    }
}

struct TemperatureDisplay: View {
    let label: String
    let value: Double
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.tint)
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(String(format: "%.1f°C", value))
                .font(.title2)
                .fontWeight(.semibold)
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(TemperatureService())
        .environmentObject(DisplayModeManager())
}
