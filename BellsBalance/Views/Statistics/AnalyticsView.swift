//
//  AnalyticsView.swift
//  BellsBalance
//

import SwiftUI
import UIKit

struct AnalyticsView: View {
    @ObservedObject var viewModel: BellsBalanceViewModel
    @State private var showShareSheet = false
    @State private var csvData: String = ""
    
    private let weekdays = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                forecastCard
                bestTimeCard
                trendsSection
                exportButton
            }
            .padding()
        }
        .bellsScreenBackground(accent: .bellsGreen)
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(activityItems: [csvData])
        }
    }
    
    private var forecastCard: some View {
        let forecast = viewModel.forecastToday()
        let willReach = forecast >= viewModel.profile.dailyGoal
        
        return VStack(alignment: .leading, spacing: 12) {
            Text("Today's forecast")
                .font(.headline)
                .foregroundColor(.white)
            
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text("\(forecast)")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(willReach ? .bellsGreen : .bellsYellow)
                Text("ml")
                    .font(.title3)
                    .foregroundColor(.gray)
            }
            
            Text(willReach ? "On track to reach goal" : "Drink more to reach goal")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .bellsCard(accent: willReach ? .bellsGreen : .bellsYellow)
    }
    
    private var bestTimeCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Best drinking hour")
                .font(.headline)
                .foregroundColor(.white)
            
            if let hour = viewModel.bestHourOfDay() {
                Text(formatHour(hour))
                    .font(.title2)
                    .bold()
                    .foregroundColor(.bellsGreen)
                Text("Your most active hour in last 30 days")
                    .font(.caption)
                    .foregroundColor(.gray)
            } else {
                Text("Not enough data")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .bellsCard(accent: .bellsGreen)
    }
    
    private var trendsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("30-day trend")
                .font(.headline)
                .foregroundColor(.white)
            
            let trends = viewModel.trendsLast30Days()
            let maxVal = max(1, trends.map { $0.1 }.max() ?? 1)
            
            HStack(alignment: .bottom, spacing: 2) {
                ForEach(Array(trends.enumerated()), id: \.offset) { index, item in
                    VStack(spacing: 4) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(barColor(for: item.1))
                            .frame(height: max(CGFloat(item.1) / CGFloat(maxVal) * 80, 2))
                        if index % 5 == 0 {
                            Text("\(Calendar.current.component(.day, from: item.0))")
                                .font(.system(size: 8))
                                .foregroundColor(.gray)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .frame(height: 120)
        }
        .padding()
        .bellsElevatedCard()
    }
    
    private func barColor(for total: Int) -> Color {
        let percentage = viewModel.profile.dailyGoal > 0 ? Double(total) / Double(viewModel.profile.dailyGoal) * 100 : 0
        if percentage >= 100 { return .bellsGreen }
        else if percentage >= 50 { return .bellsYellow }
        else if total > 0 { return .bellsRed }
        return .gray.opacity(0.3)
    }
    
    private var exportButton: some View {
        Button {
            csvData = viewModel.exportCSV()
            showShareSheet = true
        } label: {
            HStack {
                Image(systemName: "square.and.arrow.up")
                Text("Export to CSV")
            }
            .font(.headline)
            .foregroundColor(.black)
            .frame(maxWidth: .infinity)
            .padding()
            .bellsPrimaryButton(green: true)
        }
    }
    
    private func formatHour(_ hour: Int) -> String {
        if hour < 12 { return "\(hour == 0 ? 12 : hour) AM" }
        return "\(hour == 12 ? 12 : hour - 12) PM"
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
