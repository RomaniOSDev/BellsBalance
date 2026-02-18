//
//  View+Design.swift
//  BellsBalance
//

import SwiftUI

extension View {
    /// Card with gradient, shadow, and rounded corners
    func bellsCard(accent: Color? = nil) -> some View {
        self
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(accent != nil ? LinearGradient(
                        colors: [accent!.opacity(0.2), accent!.opacity(0.04)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ) : LinearGradient.bellsCard)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.4), radius: 12, x: 0, y: 6)
            .shadow(color: (accent ?? .white).opacity(0.1), radius: 8, x: 0, y: 2)
    }
    
    /// Elevated card with strong depth
    func bellsElevatedCard() -> some View {
        self
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(LinearGradient.bellsCard)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        LinearGradient(
                            colors: [Color.white.opacity(0.12), Color.white.opacity(0.03)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(color: Color.black.opacity(0.5), radius: 20, x: 0, y: 10)
            .shadow(color: Color.black.opacity(0.3), radius: 6, x: 0, y: 2)
    }
    
    /// Small card for list items
    func bellsSmallCard() -> some View {
        self
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(LinearGradient.bellsCard)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color.white.opacity(0.06), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.3), radius: 8, x: 0, y: 4)
    }
    
    /// Primary button with gradient
    func bellsPrimaryButton(green: Bool = true) -> some View {
        self
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(green ? LinearGradient.bellsButtonGreen : LinearGradient.bellsButtonYellow)
            )
            .shadow(color: (green ? Color.bellsGreen : Color.bellsYellow).opacity(0.5), radius: 12, x: 0, y: 6)
            .shadow(color: Color.black.opacity(0.3), radius: 4, x: 0, y: 2)
    }
    
    /// Screen background with gradient
    func bellsScreenBackground(accent: Color? = nil) -> some View {
        self
            .background(
                ZStack {
                    Color.bellsBackground
                    if let accent = accent {
                        RadialGradient.bellsGlow(color: accent, radius: 300)
                            .ignoresSafeArea()
                    }
                }
                .ignoresSafeArea()
            )
    }
}
