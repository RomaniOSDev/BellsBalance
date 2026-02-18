//
//  SettingsView.swift
//  BellsBalance
//

import SwiftUI
import StoreKit

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    
    private let privacyURL = "https://www.termsfeed.com/live/4a591f64-61fa-41ae-bf1b-c13ca2d8f7b8"
    private let termsURL = "https://www.termsfeed.com/live/f65dadb8-f796-4e8f-a4ac-b16778369f8c"
    
    var body: some View {
        ZStack {
            backgroundGradient
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Text("Settings")
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(.bellsYellow)
                    
                    settingsSection
                }
                .padding()
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var backgroundGradient: some View {
        ZStack {
            Color.bellsBackground.ignoresSafeArea()
            LinearGradient(
                colors: [Color.bellsBackgroundLight.opacity(0.4), Color.clear],
                startPoint: .top,
                endPoint: .center
            )
            .ignoresSafeArea()
            Circle()
                .fill(RadialGradient.bellsGlow(color: .bellsGreen, radius: 140))
                .frame(width: 280, height: 280)
                .offset(x: 80, y: 150)
                .blur(radius: 60)
        }
        .ignoresSafeArea()
    }
    
    private var settingsSection: some View {
        VStack(spacing: 12) {
            settingsRow(
                icon: "star.fill",
                title: "Rate us",
                color: .bellsYellow
            ) {
                rateApp()
            }
            
            settingsRow(
                icon: "lock.shield.fill",
                title: "Privacy Policy",
                color: .bellsGreen
            ) {
                openURL(privacyURL)
            }
            
            settingsRow(
                icon: "doc.text.fill",
                title: "Terms of Use",
                color: .bellsGreen
            ) {
                openURL(termsURL)
            }
        }
    }
    
    private func settingsRow(
        icon: String,
        title: String,
        color: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
                    .frame(width: 40, height: 40)
                    .background(
                        Circle()
                            .fill(color.opacity(0.2))
                            .overlay(Circle().stroke(color.opacity(0.3), lineWidth: 1))
                            .shadow(color: color.opacity(0.2), radius: 4, x: 0, y: 2)
                    )
                
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.5))
            }
            .padding()
            .bellsCard()
        }
        .buttonStyle(.plain)
    }
    
    private func openURL(_ urlString: String) {
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }
    
    private func rateApp() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: windowScene)
        }
    }
}
