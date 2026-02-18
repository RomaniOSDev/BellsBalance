//
//  HomeView.swift
//  BellsBalance
//

import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel: BellsBalanceViewModel
    @State private var showAddWater = false
    @State private var progressAppeared = false
    @State private var cardsAppeared = false
    
    private let quickAmounts = [200, 250, 300, 500]
    private let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "EEEE, MMM d"
        return f
    }()
    
    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Good morning"
        case 12..<17: return "Good afternoon"
        default: return "Good evening"
        }
    }
    
    var body: some View {
        ZStack {
            backgroundGradient
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 28) {
                    headerSection
                    heroProgressSection
                    statusBanner
                    quickActionsGrid
                    recentActivitySection
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 100)
            }
            
            floatingAddButton
        }
        .sheet(isPresented: $showAddWater) {
            AddWaterView(viewModel: viewModel) {
                showAddWater = false
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                progressAppeared = true
            }
            withAnimation(.easeOut(duration: 0.5).delay(0.2)) {
                cardsAppeared = true
            }
        }
    }
    
    private var backgroundGradient: some View {
        ZStack {
            Color.bellsBackground
                .ignoresSafeArea()
            
            LinearGradient(
                colors: [Color.bellsBackgroundLight.opacity(0.5), Color.clear],
                startPoint: .top,
                endPoint: .center
            )
            .ignoresSafeArea()
            
            Circle()
                .fill(RadialGradient.bellsGlow(color: viewModel.todayStatusColor, radius: 220))
                .frame(width: 440, height: 440)
                .offset(x: 80, y: -140)
                .blur(radius: 80)
            
            Circle()
                .fill(RadialGradient.bellsGlow(color: .bellsGreen, radius: 150))
                .frame(width: 300, height: 300)
                .offset(x: -100, y: 200)
                .blur(radius: 60)
                .opacity(0.4)
        }
        .ignoresSafeArea()
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(greeting)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.white.opacity(0.9))
            
            Text(dateFormatter.string(from: Date()))
                .font(.subheadline)
                .foregroundColor(.bellsGreen)
            
            HStack(spacing: 10) {
                HStack(spacing: 6) {
                    Image(systemName: "star.fill")
                        .font(.caption)
                        .foregroundColor(.bellsYellow)
                    Text("\(viewModel.points)")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(LinearGradient.bellsCard)
                        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.white.opacity(0.1), lineWidth: 1))
                        .shadow(color: .black.opacity(0.3), radius: 6, x: 0, y: 3)
                )
                
                Text("Level \(viewModel.level)")
                    .font(.caption)
                    .foregroundColor(.bellsGreen)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(LinearGradient.bellsCardGreen)
                            .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.bellsGreen.opacity(0.3), lineWidth: 1))
                            .shadow(color: Color.bellsGreen.opacity(0.2), radius: 6, x: 0, y: 3)
                    )
                
                Spacer()
                
                if !viewModel.isDailyChallengeCompleted() {
                    dailyChallengeChip
                }
            }
            .padding(.top, 4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var dailyChallengeChip: some View {
        let challenge = viewModel.todayDailyChallenge
        return Button {
            _ = viewModel.completeDailyChallenge()
        } label: {
            HStack(spacing: 6) {
                Image(systemName: challenge.icon)
                    .font(.caption2)
                Text(challenge.title)
                    .font(.caption2)
            }
            .foregroundColor(.bellsYellow)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.bellsYellow.opacity(0.15))
            .cornerRadius(20)
        }
    }
    
    private var heroProgressSection: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(viewModel.todayStatusColor.opacity(0.08))
                    .frame(width: 240, height: 240)
                    .blur(radius: 40)
                
                Circle()
                    .stroke(Color.white.opacity(0.06), lineWidth: 28)
                    .frame(width: 220, height: 220)
                
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [Color.white.opacity(0.1), Color.white.opacity(0.02)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 30
                    )
                    .frame(width: 220, height: 220)
                    .blur(radius: 2)
                
                Circle()
                    .trim(from: 0, to: progressAppeared ? min(viewModel.todayPercentage / 100, 1) : 0)
                    .stroke(
                        LinearGradient(
                            colors: [viewModel.todayStatusColor, viewModel.todayStatusColor.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 28, lineCap: .round)
                    )
                    .frame(width: 220, height: 220)
                    .rotationEffect(.degrees(-90))
                    .shadow(color: viewModel.todayStatusColor.opacity(0.6), radius: 16, x: 0, y: 0)
                    .shadow(color: viewModel.todayStatusColor.opacity(0.3), radius: 24, x: 0, y: 4)
                
                VStack(spacing: 4) {
                    Text("\(Int(viewModel.todayPercentage))%")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundColor(viewModel.todayStatusColor)
                    
                    Text("\(viewModel.todayTotal)")
                        .font(.title3)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                    
                    Text("of \(viewModel.profile.dailyGoal) ml")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                }
            }
            .padding(.vertical, 20)
        }
    }
    
    private var statusBanner: some View {
        HStack(spacing: 16) {
            Image(systemName: statusIcon)
                .font(.title)
                .foregroundColor(statusColor)
                .frame(width: 48, height: 48)
                .background(
                    Circle()
                        .fill(statusColor.opacity(0.25))
                        .overlay(Circle().stroke(statusColor.opacity(0.4), lineWidth: 1))
                        .shadow(color: statusColor.opacity(0.4), radius: 8, x: 0, y: 4)
                )
            
            VStack(alignment: .leading, spacing: 2) {
                Text(statusText)
                    .font(.headline)
                    .foregroundColor(.white)
                Text(viewModel.dailyTip())
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
                    .lineLimit(2)
            }
            
            Spacer()
        }
        .padding(20)
        .bellsCard(accent: statusColor)
        .opacity(cardsAppeared ? 1 : 0)
        .offset(y: cardsAppeared ? 0 : 20)
    }
    
    private var statusIcon: String {
        switch viewModel.todayLevel {
        case .critical: return "exclamationmark.triangle.fill"
        case .low: return "bell.fill"
        case .good: return "checkmark.seal.fill"
        case .excellent: return "star.fill"
        }
    }
    
    private var statusColor: Color {
        switch viewModel.todayLevel {
        case .critical: return .bellsRed
        case .low: return .bellsYellow
        case .good, .excellent: return .bellsGreen
        }
    }
    
    private var statusText: String {
        switch viewModel.todayLevel {
        case .critical: return "Time to hydrate!"
        case .low: return "Keep it going"
        case .good: return "Great pace"
        case .excellent: return "Goal achieved! 🎉"
        }
    }
    
    private var quickActionsGrid: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Quick add")
                .font(.headline)
                .foregroundColor(.white)
            
            HStack(spacing: 12) {
                ForEach(quickAmounts, id: \.self) { amount in
                    quickAddButton(amount: amount)
                }
                
                Button {
                    showAddWater = true
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "plus")
                            .font(.headline)
                        Text("Other")
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(.bellsYellow)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(LinearGradient.bellsCardYellow)
                            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.bellsYellow.opacity(0.5), lineWidth: 2))
                            .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .opacity(cardsAppeared ? 1 : 0)
        .offset(y: cardsAppeared ? 0 : 20)
    }
    
    private func quickAddButton(amount: Int) -> some View {
        let isPrimary = amount == 250 || amount == 500
        let gradient = isPrimary ? LinearGradient.bellsButtonGreen : LinearGradient.bellsButtonYellow
        let accent = isPrimary ? Color.bellsGreen : Color.bellsYellow
        return Button {
            viewModel.addEntry(amount: amount, note: nil, isReminder: false)
        } label: {
            VStack(spacing: 4) {
                Image(systemName: "drop.fill")
                    .font(.system(size: 18))
                Text("\(amount) ml")
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }
            .foregroundColor(.black)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(gradient)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                    )
                    .shadow(color: accent.opacity(0.5), radius: 10, x: 0, y: 5)
                    .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
            )
            .cornerRadius(16)
        }
        .buttonStyle(.plain)
    }
    
    private var recentActivitySection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Today's activity")
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
            }
            
            if viewModel.todayEntries.isEmpty {
                HStack(spacing: 12) {
                    Image(systemName: "drop")
                        .font(.title2)
                        .foregroundColor(.white.opacity(0.3))
                    Text("No entries yet. Tap + to add your first drink!")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.5))
                }
                .frame(maxWidth: .infinity)
                .padding(24)
                .bellsSmallCard()
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(viewModel.todayEntries.prefix(6)) { entry in
                            activityCard(entry)
                        }
                    }
                }
            }
        }
        .opacity(cardsAppeared ? 1 : 0)
        .offset(y: cardsAppeared ? 0 : 20)
    }
    
    private func activityCard(_ entry: WaterEntry) -> some View {
        HStack(spacing: 12) {
            Image(systemName: entry.drinkType.icon)
                .font(.title3)
                .foregroundColor(.bellsGreen)
                .frame(width: 40, height: 40)
                .background(
                    Circle()
                        .fill(LinearGradient.bellsCardGreen)
                        .overlay(Circle().stroke(Color.bellsGreen.opacity(0.3), lineWidth: 1))
                        .shadow(color: Color.bellsGreen.opacity(0.2), radius: 4, x: 0, y: 2)
                )
            
            VStack(alignment: .leading, spacing: 2) {
                Text("\(entry.amount) ml")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                Text(timeString(from: entry.date))
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.5))
            }
            
            if entry.isReminder {
                Image(systemName: "bell.fill")
                    .font(.caption2)
                    .foregroundColor(.bellsYellow)
            }
        }
        .padding(14)
        .frame(width: 140)
        .bellsSmallCard()
    }
    
    private var floatingAddButton: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button {
                    showAddWater = true
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundColor(.black)
                        .frame(width: 66, height: 66)
                        .background(
                            Circle()
                                .fill(LinearGradient.bellsButtonGreen)
                                .overlay(Circle().stroke(Color.white.opacity(0.4), lineWidth: 1))
                                .shadow(color: Color.bellsGreen.opacity(0.6), radius: 20, x: 0, y: 10)
                                .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
                        )
                }
                .padding(.trailing, 24)
                .padding(.bottom, 32)
            }
        }
        .allowsHitTesting(true)
    }
    
    private func timeString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
