//
//  AddReminderView.swift
//  BellsBalance
//

import SwiftUI

struct AddReminderView: View {
    @ObservedObject var viewModel: BellsBalanceViewModel
    var onDismiss: () -> Void
    
    @State private var time: Date = Date()
    @State private var selectedDays: Set<Int> = []
    @State private var note: String = ""
    
    private let dayNames = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.bellsBackground
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        timePicker
                        daysSelector
                        noteField
                        saveButton
                    }
                    .padding()
                }
            }
            .navigationTitle("Add reminder")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        onDismiss()
                    }
                    .foregroundColor(.bellsRed)
                }
            }
        }
    }
    
    private var timePicker: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Time")
                .font(.headline)
                .foregroundColor(.white)
            
            DatePicker("", selection: $time, displayedComponents: .hourAndMinute)
                .datePickerStyle(.wheel)
                .labelsHidden()
                .colorScheme(.dark)
                .tint(.bellsGreen)
        }
    }
    
    private var daysSelector: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Days")
                .font(.headline)
                .foregroundColor(.white)
            
            HStack(spacing: 8) {
                ForEach(1...7, id: \.self) { day in
                    Button {
                        if selectedDays.contains(day) {
                            selectedDays.remove(day)
                        } else {
                            selectedDays.insert(day)
                        }
                    } label: {
                        Text(dayNames[day - 1])
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(selectedDays.contains(day) ? .black : .white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(selectedDays.contains(day) ? Color.bellsGreen : Color.white.opacity(0.1))
                            .cornerRadius(10)
                    }
                }
            }
        }
    }
    
    private var noteField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Note (optional)")
                .font(.headline)
                .foregroundColor(.white)
            
            TextField("Reminder note", text: $note)
                .textFieldStyle(.plain)
                .padding()
                .background(Color.white.opacity(0.1))
                .cornerRadius(12)
                .foregroundColor(.white)
                .accentColor(.bellsYellow)
        }
    }
    
    private var saveButton: some View {
        Button {
            let days = Array(selectedDays).sorted()
            if !days.isEmpty {
                viewModel.addReminder(time: time, days: days, note: note.isEmpty ? nil : note)
                onDismiss()
            }
        } label: {
            Text("Save")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.bellsGreen)
                .cornerRadius(12)
        }
        .disabled(selectedDays.isEmpty)
        .opacity(selectedDays.isEmpty ? 0.6 : 1)
    }
}
