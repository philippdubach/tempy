//
//  DisplayModeManager.swift
//  Tempy
//

import SwiftUI

@MainActor
class DisplayModeManager: ObservableObject {
    @Published var displayMode: DisplayMode {
        didSet {
            UserDefaults.standard.set(displayMode.rawValue, forKey: "displayMode")
        }
    }
    
    init() {
        if let rawValue = UserDefaults.standard.string(forKey: "displayMode"),
           let mode = DisplayMode(rawValue: rawValue) {
            self.displayMode = mode
        } else {
            self.displayMode = .outsideOnly
            UserDefaults.standard.set(DisplayMode.outsideOnly.rawValue, forKey: "displayMode")
        }
    }
}

