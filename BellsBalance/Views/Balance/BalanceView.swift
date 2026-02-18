//
//  BalanceView.swift
//  BellsBalance
//

import SwiftUI

struct BalanceView: View {
    @ObservedObject var viewModel: BellsBalanceViewModel
    @State private var showAddWater = false
    
    private let quickAmounts = [200, 250, 300, 500]
    private let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .long
        return f
    }()
    
    var body: some View {
        ZStack {
            backgroundGradient
            
            ScrollView {
                VStack(spacing: 24) {
                    gamificationBadge
                    headerSection
                    progressSection
                    statusCard
                    dailyTip
                    quickAddButtons
                    lastEntriesSection
                }
                .padding()
            }
            
            addButtonOverlay
        }
        .sheet(isPresented: $showAddWater) {
            AddWaterView(viewModel: viewModel) {
                showAddWater = false
            }
        }
    }
    
    private var backgroundGradient: some View {
        ZStack {
            Color.bellsBackground.ignoresSafeArea()
            LinearGradient(
                colors: [Color.bellsBackgroundLight.opacity(0.5), Color.clear],
                startPoint: .top,
                endPoint: .center
            )
            .ignoresSafeArea()
            Circle()
                .fill(RadialGradient.bellsGlow(color: viewModel.todayStatusColor, radius: 180))
                .frame(width: 360, height: 360)
                .offset(x: -80, y: -100)
                .blur(radius: 60)
        }
        .ignoresSafeArea()
    }
    
    private var gamificationBadge: some View {
        HStack(spacing: 12) {
            HStack(spacing: 4) {
                Image(systemName: "star.fill")
                    .foregroundColor(.bellsYellow)
                Text("\(viewModel.points)")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.white.opacity(0.1))
            .cornerRadius(20)
            
            Text("Level \(viewModel.level)")
                .font(.caption)
                .foregroundColor(.bellsGreen)
            
            Spacer()
            
            if !viewModel.isDailyChallengeCompleted() {
                dailyChallengeButton
            }
        }
    }
    
    private var dailyChallengeButton: some View {
        let challenge = viewModel.todayDailyChallenge
        return Button {
            _ = viewModel.completeDailyChallenge()
        } label: {
            HStack(spacing: 6) {
                Image(systemName: challenge.icon)
                    .font(.caption)
                Text(challenge.title)
                    .font(.caption2)
            }
            .foregroundColor(.bellsYellow)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color.white.opacity(0.1))
            .cornerRadius(12)
        }
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Bells Balance")
                .font(.largeTitle)
                .bold()
                .foregroundColor(.bellsYellow)
            
            Text(dateFormatter.string(from: Date()))
                .font(.subheadline)
                .foregroundColor(.bellsGreen)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var progressSection: some View {
        VStack(spacing: 16) {
            ZStack {
                CircularProgressView(
                    progress: viewModel.todayPercentage,
                    progressColor: viewModel.todayStatusColor
                )
                .frame(width: 200, height: 200)
                
                VStack(spacing: 4) {
                    Text("\(Int(viewModel.todayPercentage))%")
                        .font(.system(size: 42, weight: .bold))
                        .foregroundColor(viewModel.todayStatusColor)
                    
                    Text("\(viewModel.todayTotal) / \(viewModel.profile.dailyGoal) ml")
                        .font(.subheadline)
                        .foregroundColor(.white)
                }
            }
        }
        .padding()
    }
    
    private var statusCard: some View {
        HStack(spacing: 12) {
            Image(systemName: statusIcon)
                .font(.title2)
                .foregroundColor(statusColor)
                .frame(width: 40, height: 40)
                .background(
                    Circle()
                        .fill(statusColor.opacity(0.2))
                        .overlay(Circle().stroke(statusColor.opacity(0.4), lineWidth: 1))
                        .shadow(color: statusColor.opacity(0.3), radius: 6, x: 0, y: 3)
                )
            
            Text(statusText)
                .font(.subheadline)
                .foregroundColor(.white)
            
            Spacer()
        }
        .padding()
        .bellsCard(accent: statusColor)
    }
    
    private var dailyTip: some View {
        HStack(spacing: 8) {
            Image(systemName: "lightbulb.fill")
                .foregroundColor(.bellsYellow)
                .shadow(color: Color.bellsYellow.opacity(0.3), radius: 4, x: 0, y: 0)
            Text(viewModel.dailyTip())
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .bellsSmallCard()
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
        case .critical: return "Critical level! Drink water"
        case .low: return "Keep drinking"
        case .good: return "Great pace!"
        case .excellent: return "Goal achieved! 🎉"
        }
    }
    
    private var quickAddButtons: some View {
        VStack(alignment: .leading, spacing: 12) {
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
                    Text("Other")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.bellsYellow)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.bellsYellow, lineWidth: 2)
                        )
                }
            }
        }
    }
    
    private func quickAddButton(amount: Int) -> some View {
        let isPrimary = amount == 200 || amount == 500
        let gradient = isPrimary ? LinearGradient.bellsButtonGreen : LinearGradient.bellsButtonYellow
        let accent = isPrimary ? Color.bellsGreen : Color.bellsYellow
        return Button {
            viewModel.addEntry(amount: amount, note: nil, isReminder: false)
        } label: {
            Text("\(amount) ml")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.black)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(gradient)
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.3), lineWidth: 1))
                        .shadow(color: accent.opacity(0.4), radius: 8, x: 0, y: 4)
                        .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                )
                .cornerRadius(12)
        }
    }
    
    private var lastEntriesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent entries")
                .font(.headline)
                .foregroundColor(.white)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(viewModel.todayEntries.prefix(5)) { entry in
                        entryCard(entry)
                    }
                }
            }
        }
    }
    
    private func entryCard(_ entry: WaterEntry) -> some View {
        HStack(spacing: 8) {
            Image(systemName: entry.drinkType.icon)
                .foregroundColor(.bellsGreen)
                .frame(width: 32, height: 32)
                .background(
                    Circle()
                        .fill(LinearGradient.bellsCardGreen)
                        .overlay(Circle().stroke(Color.bellsGreen.opacity(0.3), lineWidth: 1))
                        .shadow(color: Color.bellsGreen.opacity(0.2), radius: 4, x: 0, y: 2)
                )
            
            VStack(alignment: .leading, spacing: 2) {
                Text("\(entry.amount) ml \(entry.drinkType.displayName)")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                
                Text(timeString(from: entry.date))
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.5))
            }
        }
        .padding(12)
        .bellsSmallCard()
    }
    
    private var addButtonOverlay: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button {
                    showAddWater = true
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 26, weight: .semibold))
                        .foregroundColor(.black)
                        .frame(width: 60, height: 60)
                        .background(
                            Circle()
                                .fill(LinearGradient.bellsButtonGreen)
                                .overlay(Circle().stroke(Color.white.opacity(0.4), lineWidth: 1))
                                .shadow(color: Color.bellsGreen.opacity(0.5), radius: 16, x: 0, y: 8)
                                .shadow(color: .black.opacity(0.3), radius: 6, x: 0, y: 3)
                        )
                }
                .padding(.trailing, 24)
                .padding(.bottom, 24)
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
