//
//  DayDetailView.swift
//  BellsBalance
//

import SwiftUI

struct DayDetailView: View {
    @ObservedObject var viewModel: BellsBalanceViewModel
    let date: Date
    
    private let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .long
        return f
    }()
    
    private var dayEntries: [WaterEntry] {
        viewModel.entriesForDate(date)
    }
    
    private var dayTotal: Int {
        viewModel.totalForDate(date)
    }
    
    private var dayPercentage: Double {
        viewModel.percentageForDate(date)
    }
    
    private var statusColor: Color {
        if dayPercentage >= 100 { return .bellsGreen }
        else if dayPercentage >= 70 { return .bellsGreen }
        else if dayPercentage >= 30 { return .bellsYellow }
        else { return .bellsRed }
    }
    
    var body: some View {
        ZStack {
            backgroundGradient
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    header
                    daySummary
                    hourlyTimeline
                    entriesList
                }
                .padding()
            }
        }
        .navigationTitle(dateFormatter.string(from: date))
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
                .fill(RadialGradient.bellsGlow(color: statusColor, radius: 120))
                .frame(width: 240, height: 240)
                .offset(x: 60, y: 100)
                .blur(radius: 50)
        }
        .ignoresSafeArea()
    }
    
    private var header: some View {
        Text(dateFormatter.string(from: date))
            .font(.largeTitle)
            .bold()
            .foregroundColor(.bellsYellow)
    }
    
    private var daySummary: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text("\(dayTotal)")
                    .font(.system(size: 42, weight: .bold))
                    .foregroundColor(statusColor)
                
                Text("ml")
                    .font(.title3)
                    .foregroundColor(.gray)
            }
            
            Text("of \(viewModel.profile.dailyGoal) ml goal")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            Text("\(Int(dayPercentage))%")
                .font(.headline)
                .foregroundColor(statusColor)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .bellsCard(accent: statusColor)
    }
    
    private var hourlyTimeline: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("By hour")
                .font(.headline)
                .foregroundColor(.white)
            
            let hoursWithEntries = hourBuckets()
            HStack(alignment: .bottom, spacing: 4) {
                ForEach(0..<24, id: \.self) { hour in
                    VStack(spacing: 4) {
                        let amount = hoursWithEntries[hour] ?? 0
                        let height = min(CGFloat(amount) / 500.0 * 60, 80)
                        
                        if amount > 0 {
                            Image(systemName: "drop.fill")
                                .font(.caption)
                                .foregroundColor(.bellsGreen)
                                .frame(height: height)
                        } else {
                            Color.clear
                                .frame(height: 4)
                        }
                        
                        Text("\(hour)")
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .frame(height: 100)
        }
        .padding()
        .bellsCard()
    }
    
    private func hourBuckets() -> [Int: Int] {
        var buckets: [Int: Int] = [:]
        let calendar = Calendar.current
        
        for entry in dayEntries {
            let hour = calendar.component(.hour, from: entry.date)
            buckets[hour, default: 0] += entry.effectiveAmount
        }
        return buckets
    }
    
    private var entriesList: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Entries")
                .font(.headline)
                .foregroundColor(.white)
            
            ForEach(dayEntries.sorted(by: { $0.date > $1.date })) { entry in
                entryRow(entry)
            }
        }
    }
    
    private func entryRow(_ entry: WaterEntry) -> some View {
        HStack(spacing: 12) {
            Text(timeString(from: entry.date))
                .font(.subheadline)
                .foregroundColor(.bellsYellow)
                .frame(width: 60, alignment: .leading)
            
            Image(systemName: entry.drinkType.icon)
                .font(.caption)
                .foregroundColor(.bellsGreen)
            
            Text("\(entry.amount) ml \(entry.drinkType.displayName)")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.white)
            
            if entry.isReminder {
                Image(systemName: "bell.fill")
                    .font(.caption)
                    .foregroundColor(.bellsYellow)
            }
            
            Spacer()
            
            if let note = entry.note, !note.isEmpty {
                Text(note)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .lineLimit(1)
            }
        }
        .padding()
        .bellsSmallCard()
    }
    
    private func timeString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
