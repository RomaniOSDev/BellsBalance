//
//  Color+Bells.swift
//  BellsBalance
//

import SwiftUI

extension Color {
    static let bellsBackground = Color(red: 0.13, green: 0.14, blue: 0.15) // #212425
    static let bellsGreen = Color(red: 0.44, green: 0.86, blue: 0.29)     // #70DC49
    static let bellsRed = Color(red: 0.73, green: 0.04, blue: 0.09)       // #BA0A17
    static let bellsYellow = Color(red: 0.99, green: 0.94, blue: 0.57)    // #FCEF92
    
    static let bellsBackgroundLight = Color(red: 0.18, green: 0.19, blue: 0.2)
    static let bellsGreenDark = Color(red: 0.32, green: 0.7, blue: 0.22)
    static let bellsYellowDark = Color(red: 0.85, green: 0.8, blue: 0.4)
}

// MARK: - Gradient Presets
extension LinearGradient {
    static let bellsCard = LinearGradient(
        colors: [Color.white.opacity(0.08), Color.white.opacity(0.03)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    static let bellsCardGreen = LinearGradient(
        colors: [Color.bellsGreen.opacity(0.25), Color.bellsGreen.opacity(0.05)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    static let bellsCardYellow = LinearGradient(
        colors: [Color.bellsYellow.opacity(0.2), Color.bellsYellow.opacity(0.04)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    static let bellsCardRed = LinearGradient(
        colors: [Color.bellsRed.opacity(0.2), Color.bellsRed.opacity(0.04)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    static let bellsButtonGreen = LinearGradient(
        colors: [Color.bellsGreen, Color.bellsGreenDark],
        startPoint: .top,
        endPoint: .bottom
    )
    static let bellsButtonYellow = LinearGradient(
        colors: [Color.bellsYellow, Color.bellsYellowDark],
        startPoint: .top,
        endPoint: .bottom
    )
}

extension RadialGradient {
    static func bellsGlow(color: Color, radius: CGFloat = 200) -> RadialGradient {
        RadialGradient(
            colors: [color.opacity(0.2), color.opacity(0.05), Color.clear],
            center: .center,
            startRadius: 0,
            endRadius: radius
        )
    }
}
