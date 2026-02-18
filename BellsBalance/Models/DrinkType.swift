//
//  DrinkType.swift
//  BellsBalance
//

import SwiftUI

enum DrinkType: String, Codable, CaseIterable, Identifiable {
    case water
    case tea
    case coffee
    case juice
    case other
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .water: return "Water"
        case .tea: return "Tea"
        case .coffee: return "Coffee"
        case .juice: return "Juice"
        case .other: return "Other"
        }
    }
    
    /// Hydration coefficient: 1.0 = full hydration, lower = less effective
    var hydrationCoefficient: Double {
        switch self {
        case .water: return 1.0
        case .tea: return 0.9
        case .coffee: return 0.8
        case .juice: return 0.85
        case .other: return 0.7
        }
    }
    
    var icon: String {
        switch self {
        case .water: return "drop.fill"
        case .tea: return "cup.and.saucer.fill"
        case .coffee: return "cup.and.saucer.fill"
        case .juice: return "wineglass.fill"
        case .other: return "drop.fill"
        }
    }
}
