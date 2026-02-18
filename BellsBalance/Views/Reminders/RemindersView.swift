//
//  RemindersView.swift
//  BellsBalance
//

import SwiftUI

struct RemindersView: View {
    @ObservedObject var viewModel: BellsBalanceViewModel
    @State private var showAddReminder = false
    
    private let dayNames = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    
    var body: some View {
        ZStack {
            backgroundGradient
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    header
                    remindersList
                }
                .padding()
            }
            
            addButtonOverlay
        }
        .sheet(isPresented: $showAddReminder) {
            AddReminderView(viewModel: viewModel) {
                showAddReminder = false
            }
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
                .fill(RadialGradient.bellsGlow(color: .bellsYellow, radius: 150))
                .frame(width: 300, height: 300)
                .offset(x: 80, y: 150)
                .blur(radius: 60)
        }
        .ignoresSafeArea()
    }
    
    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Bells")
                .font(.largeTitle)
                .bold()
                .foregroundColor(.bellsYellow)
            
            Text("Configure reminders")
                .font(.subheadline)
                .foregroundColor(.bellsGreen)
        }
    }
    
    private var remindersList: some View {
        VStack(spacing: 16) {
            ForEach(viewModel.reminders) { reminder in
                reminderCard(reminder)
            }
        }
    }
    
    private func reminderCard(_ reminder: Reminder) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(timeString(from: reminder.time))
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Spacer()
                
                Toggle("", isOn: Binding(
                    get: { reminder.isActive },
                    set: { _ in viewModel.toggleReminder(reminder) }
                ))
                .labelsHidden()
                .tint(.bellsGreen)
            }
            
            HStack(spacing: 8) {
                ForEach(1...7, id: \.self) { day in
                    dayChip(day: day, isSelected: reminder.days.contains(day))
                    .onTapGesture {
                        toggleDay(day, for: reminder)
                    }
                }
            }
            
            if let note = reminder.note, !note.isEmpty {
                Text(note)
                    .font(.caption)
                    .foregroundColor(.bellsYellow)
            }
        }
        .padding()
        .bellsCard(accent: .bellsGreen)
    }
    
    private func dayChip(day: Int, isSelected: Bool) -> some View {
        Text(dayNames[day - 1])
            .font(.caption2)
            .fontWeight(.medium)
            .foregroundColor(isSelected ? .black : .white)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? LinearGradient.bellsButtonYellow : LinearGradient(colors: [Color.white.opacity(0.12), Color.white.opacity(0.05)], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(isSelected ? Color.bellsYellow.opacity(0.5) : Color.white.opacity(0.1), lineWidth: 1))
                    .shadow(color: isSelected ? Color.bellsYellow.opacity(0.3) : .black.opacity(0.2), radius: isSelected ? 4 : 2, x: 0, y: 2)
            )
            .cornerRadius(8)
    }
    
    private func toggleDay(_ day: Int, for reminder: Reminder) {
        var newDays = reminder.days
        if newDays.contains(day) {
            newDays.removeAll { $0 == day }
        } else {
            newDays.append(day)
            newDays.sort()
        }
        var updated = reminder
        updated.days = newDays
        viewModel.updateReminder(updated)
    }
    
    private var addButtonOverlay: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button {
                    showAddReminder = true
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
    }
    
    private func timeString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
