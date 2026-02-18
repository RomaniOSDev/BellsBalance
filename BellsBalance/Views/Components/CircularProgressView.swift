//
//  CircularProgressView.swift
//  BellsBalance
//

import SwiftUI

struct CircularProgressView: View {
    let progress: Double
    let progressColor: Color
    let lineWidth: CGFloat
    
    init(progress: Double, progressColor: Color, lineWidth: CGFloat = 25) {
        self.progress = progress
        self.progressColor = progressColor
        self.lineWidth = lineWidth
    }
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.white.opacity(0.08), lineWidth: lineWidth)
            
            Circle()
                .stroke(
                    LinearGradient(
                        colors: [Color.white.opacity(0.12), Color.white.opacity(0.04)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: lineWidth + 2
                )
                .blur(radius: 2)
            
                Circle()
                    .trim(from: 0, to: min(progress / 100, 1))
                    .stroke(
                        LinearGradient(
                            colors: [progressColor, progressColor.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.5), value: progress)
                .shadow(color: progressColor.opacity(0.6), radius: 8, x: 0, y: 0)
        }
    }
}
