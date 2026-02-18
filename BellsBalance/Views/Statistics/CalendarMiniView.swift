//
//  CalendarMiniView.swift
//  BellsBalance
//

import SwiftUI

struct CalendarMiniView: View {
    @ObservedObject var viewModel: BellsBalanceViewModel
    @Binding var selectedDate: Date
    
    private let calendar = Calendar.current
    private let daysOfWeek = ["S", "M", "T", "W", "T", "F", "S"]
    
    var body: some View {
        let month = calendar.date(from: calendar.dateComponents([.year, .month], from: selectedDate)) ?? selectedDate
        let days = daysInMonth(month)
        let firstWeekday = firstWeekdayOfMonth(month)
        
        VStack(spacing: 12) {
            HStack {
                Text(monthTitle(month))
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
            }
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                ForEach(0..<7, id: \.self) { i in
                    Text(daysOfWeek[i])
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
                
                ForEach(0..<(firstWeekday - 1), id: \.self) { _ in
                    Color.clear
                        .frame(height: 32)
                }
                
                ForEach(days, id: \.self) { day in
                    if let date = calendar.date(byAdding: .day, value: day - 1, to: month) {
                        dayButton(date: date)
                    }
                }
            }
        }
        .padding()
        .bellsCard()
    }
    
    private func dayButton(date: Date) -> some View {
        let dayNum = calendar.component(.day, from: date)
        let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)
        let color = viewModel.colorForDate(date)
        let isCurrentMonth = calendar.isDate(date, equalTo: selectedDate, toGranularity: .month)
        
        return NavigationLink(value: date) {
            Text("\(dayNum)")
                .font(.caption)
                .fontWeight(isSelected ? .bold : .regular)
                .foregroundColor(isCurrentMonth ? .white : .gray.opacity(0.5))
                .frame(width: 32, height: 32)
                .background(
                    Circle()
                        .fill(isSelected ?
                              LinearGradient(colors: [color, color.opacity(0.8)], startPoint: .topLeading, endPoint: .bottomTrailing) :
                                LinearGradient(colors: [color.opacity(0.3), color.opacity(0.15)], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .overlay(Circle().stroke(isSelected ? color.opacity(0.5) : Color.white.opacity(0.1), lineWidth: isSelected ? 1.5 : 1))
                        .shadow(color: isSelected ? color.opacity(0.4) : .clear, radius: 4, x: 0, y: 2)
                )
                .clipShape(Circle())
        }
        .buttonStyle(.plain)
        .simultaneousGesture(TapGesture().onEnded {
            selectedDate = date
        })
    }
    
    private func daysInMonth(_ month: Date) -> [Int] {
        let range = calendar.range(of: .day, in: .month, for: month) ?? 1..<1
        return Array(range)
    }
    
    private func firstWeekdayOfMonth(_ month: Date) -> Int {
        let components = calendar.dateComponents([.year, .month], from: month)
        let firstDay = calendar.date(from: components) ?? month
        let weekday = calendar.component(.weekday, from: firstDay)
        return weekday
    }
    
    private func monthTitle(_ month: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: month)
    }
}
