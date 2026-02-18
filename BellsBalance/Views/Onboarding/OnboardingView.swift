//
//  OnboardingView.swift
//  BellsBalance
//

import SwiftUI

struct OnboardingView: View {
    var onComplete: () -> Void
    
    @State private var currentPage = 0
    
    private let pages: [(icon: String, title: String, description: String)] = [
        ("drop.fill", "Track Hydration", "Log your water intake and stay on top of your daily hydration goal with simple taps."),
        ("bell.fill", "Smart Reminders", "Set custom reminders to drink water throughout the day. Your body will thank you."),
        ("chart.bar.fill", "See Progress", "View your stats, streaks, and achievements. Stay motivated and build healthy habits.")
    ]
    
    var body: some View {
        ZStack {
            Color.bellsBackground
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        onboardingPage(
                            icon: pages[index].icon,
                            title: pages[index].title,
                            description: pages[index].description
                        )
                        .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                
                pageIndicator
                
                actionButton
            }
        }
    }
    
    private func onboardingPage(icon: String, title: String, description: String) -> some View {
        VStack(spacing: 32) {
            Spacer()
            
            Image(systemName: icon)
                .font(.system(size: 80))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.bellsGreen, Color.bellsYellow],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: Color.bellsGreen.opacity(0.5), radius: 20, x: 0, y: 10)
            
            VStack(spacing: 16) {
                Text(title)
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.bellsYellow)
                    .multilineTextAlignment(.center)
                
                Text(description)
                    .font(.body)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }
            
            Spacer()
        }
    }
    
    private var pageIndicator: some View {
        HStack(spacing: 8) {
            ForEach(0..<pages.count, id: \.self) { index in
                Circle()
                    .fill(currentPage == index ? Color.bellsGreen : Color.white.opacity(0.3))
                    .frame(width: 8, height: 8)
                    .scaleEffect(currentPage == index ? 1.2 : 1)
                    .animation(.easeInOut(duration: 0.2), value: currentPage)
            }
        }
        .padding(.vertical, 24)
    }
    
    private var actionButton: some View {
        Button {
            if currentPage < pages.count - 1 {
                withAnimation {
                    currentPage += 1
                }
            } else {
                onComplete()
            }
        } label: {
            Text(currentPage < pages.count - 1 ? "Next" : "Get Started")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .bellsPrimaryButton(green: true)
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 48)
    }
}
