//
//  HydrationLevel.swift
//  BellsBalance
//

import SwiftUI

enum HydrationLevel {
    case critical   // red
    case low        // yellow
    case good       // green
    case excellent  // green (100%+)
    
    static func from(percentage: Double) -> HydrationLevel {
        if percentage < 30 {
            return .critical
        } else if percentage < 70 {
            return .low
        } else if percentage < 100 {
            return .good
        } else {
            return .excellent
        }
    }
}
