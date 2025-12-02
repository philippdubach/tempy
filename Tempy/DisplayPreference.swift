//
//  DisplayPreference.swift
//  Tempy
//

import Foundation

enum DisplayMode: String, CaseIterable {
    case insideOnly = "insideOnly"
    case outsideOnly = "outsideOnly"
    
    var displayName: String {
        switch self {
        case .insideOnly:
            return "Inside Only"
        case .outsideOnly:
            return "Outside Only"
        }
    }
}

