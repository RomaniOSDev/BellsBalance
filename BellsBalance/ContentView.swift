//
//  ContentView.swift
//  BellsBalance
//

import SwiftUI
import UIKit

struct ContentView: View {
    @StateObject private var viewModel = BellsBalanceViewModel()
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    
    var body: some View {
        Group {
            if hasCompletedOnboarding {
                mainTabView
            } else {
                OnboardingView {
                    hasCompletedOnboarding = true
                }
            }
        }
        .onAppear {
            if hasCompletedOnboarding {
                configureTabBarAppearance()
            }
        }
    }
    
    private var mainTabView: some View {
        TabView {
            HomeView(viewModel: viewModel)
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            
            BalanceView(viewModel: viewModel)
                .tabItem {
                    Label("Balance", systemImage: "drop.fill")
                }
            
            NavigationStack {
                StatisticsView(viewModel: viewModel)
            }
            .tabItem {
                Label("Statistics", systemImage: "chart.bar.fill")
            }
            
            RemindersView(viewModel: viewModel)
                .tabItem {
                    Label("Bells", systemImage: "bell.fill")
                }
            
            NavigationStack {
                ProfileView(viewModel: viewModel)
            }
            .tabItem {
                Label("Profile", systemImage: "person.fill")
            }
        }
        .tint(.bellsGreen)
        .onAppear {
            configureTabBarAppearance()
        }
    }
    
    private func configureTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(Color.bellsBackground)
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}

#Preview {
    ContentView()
}
