//
//  TempyApp.swift
//  Tempy
//

import SwiftUI

@main
struct TempyApp: App {
    @StateObject private var temperatureService = TemperatureService()
    @StateObject private var displayModeManager = DisplayModeManager()
    
    var body: some Scene {
        MenuBarExtra {
            ContentView()
                .environmentObject(temperatureService)
                .environmentObject(displayModeManager)
        } label: {
            MenuBarLabelView()
                .environmentObject(temperatureService)
                .environmentObject(displayModeManager)
        }
        .menuBarExtraStyle(.window)
    }
}

struct MenuBarLabelView: View {
    @EnvironmentObject var temperatureService: TemperatureService
    @EnvironmentObject var displayModeManager: DisplayModeManager
    
    var body: some View {
        Group {
            if let data = temperatureService.temperatureData {
                switch displayModeManager.displayMode {
                case .outsideOnly:
                    HStack(spacing: 1) {
                        Image(systemName: "sun.max")
                            .font(.system(size: 9))
                        Text(String(format: "%.1f°C", data.outside))
                            .font(.system(size: 10))
                    }
                case .insideOnly:
                    HStack(spacing: 1) {
                        Image(systemName: "house")
                            .font(.system(size: 9))
                        Text(String(format: "%.1f°C", data.inside))
                            .font(.system(size: 10))
                    }
                }
            } else if temperatureService.isLoading {
                Text("Loading...")
                    .font(.system(size: 10))
            } else {
                Text("---")
                    .font(.system(size: 10))
            }
        }
    }
}
