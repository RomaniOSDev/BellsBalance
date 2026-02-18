//
//  StatisticsView.swift
//  BellsBalance
//

import SwiftUI

struct StatisticsView: View {
    @ObservedObject var viewModel: BellsBalanceViewModel
    @State private var selectedDate: Date = Date()
    
    private let weekdays = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    
    var body: some View {
        ZStack {
            backgroundGradient
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Text("Statistics")
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(.bellsYellow)
                    
                    kpiCards
                    weeklyChart
                    analyticsSection
                    miniCalendar
                    achievements
                }
                .padding()
            }
        }
        .navigationDestination(for: Date.self) { date in
            DayDetailView(viewModel: viewModel, date: date)
        }
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
                .fill(RadialGradient.bellsGlow(color: .bellsYellow, radius: 160))
                .frame(width: 320, height: 320)
                .offset(x: 100, y: -80)
                .blur(radius: 70)
        }
        .ignoresSafeArea()
    }
    
    private var kpiCards: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                kpiCard(
                    title: "Average volume",
                    value: "\(viewModel.averageDailyVolume()) ml",
                    accentColor: .bellsGreen
                )
                
                kpiCard(
                    title: "Best streak (days)",
                    value: "\(viewModel.streakDays())",
                    accentColor: .bellsYellow
                )
                
                kpiCard(
                    title: "Monthly total",
                    value: "\(viewModel.monthlyTotal() / 1000)L",
                    accentColor: .bellsGreen
                )
            }
            .padding(.horizontal, 4)
        }
    }
    
    private func kpiCard(title: String, value: String, accentColor: Color) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(value)
                .font(.title2)
                .bold()
                .foregroundColor(.white)
            
            Text(title)
                .font(.caption)
                .foregroundColor(accentColor)
        }
        .frame(width: 140)
        .padding()
        .bellsCard(accent: accentColor)
    }
    
    private var weeklyChart: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Weekly overview")
                .font(.headline)
                .foregroundColor(.white)
            
            HStack(alignment: .bottom, spacing: 12) {
                ForEach(Array(viewModel.weeklyTotals().enumerated()), id: \.offset) { index, total in
                    VStack(spacing: 8) {
                        let maxVal = max(1, viewModel.weeklyTotals().max() ?? 1)
                        let height = total > 0 ? CGFloat(total) / CGFloat(maxVal) * 120 : 4
                        let color = barColor(for: total)
                        
                        RoundedRectangle(cornerRadius: 6)
                            .fill(
                                LinearGradient(
                                    colors: [color, color.opacity(0.7)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(height: max(height, 4))
                            .shadow(color: color.opacity(0.4), radius: 4, x: 0, y: 2)
                            .frame(maxWidth: .infinity)
                        
                        Text(weekdays[safe: index] ?? "")
                            .font(.caption2)
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .frame(height: 160)
        }
        .padding()
        .bellsElevatedCard()
    }
    
    private func barColor(for total: Int) -> Color {
        let percentage = profile.dailyGoal > 0 ? Double(total) / Double(viewModel.profile.dailyGoal) * 100 : 0
        if percentage >= 100 { return .bellsGreen }
        else if percentage >= 50 { return .bellsYellow }
        else if total > 0 { return .bellsRed }
        return .gray.opacity(0.3)
    }
    
    private var profile: UserProfile {
        viewModel.profile
    }
    
    private var analyticsSection: some View {
        NavigationLink {
            AnalyticsView(viewModel: viewModel)
        } label: {
            HStack {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .foregroundColor(.bellsGreen)
                Text("Analytics")
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            .padding()
            .bellsCard()
        }
    }
    
    private var miniCalendar: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Calendar")
                .font(.headline)
                .foregroundColor(.white)
            
            CalendarMiniView(viewModel: viewModel, selectedDate: $selectedDate)
        }
    }
    
    private var achievements: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Achievements")
                .font(.headline)
                .foregroundColor(.white)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(Achievement.all) { achievement in
                    achievementCard(
                        title: achievement.title,
                        icon: achievement.icon,
                        color: achievement.color == "green" ? .bellsGreen : .bellsYellow,
                        isUnlocked: viewModel.isAchievementUnlocked(achievement.id)
                    )
                }
            }
        }
    }
    
    private func achievementCard(title: String, icon: String, color: Color, isUnlocked: Bool) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(isUnlocked ? color : .gray)
                .frame(width: 36, height: 36)
                .background(
                    Circle()
                        .fill(isUnlocked ? color.opacity(0.2) : Color.white.opacity(0.05))
                        .overlay(Circle().stroke(isUnlocked ? color.opacity(0.4) : Color.white.opacity(0.1), lineWidth: 1))
                        .shadow(color: isUnlocked ? color.opacity(0.2) : .clear, radius: 4, x: 0, y: 2)
                )
            
            Text(title)
                .font(.caption)
                .foregroundColor(isUnlocked ? .white : .gray)
            
            Spacer()
        }
        .padding()
        .bellsSmallCard()
    }
    
}

private extension Array {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
