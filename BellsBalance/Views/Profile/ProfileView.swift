//
//  ProfileView.swift
//  BellsBalance
//

import SwiftUI

struct ProfileView: View {
    @ObservedObject var viewModel: BellsBalanceViewModel
    @State private var weight: String = ""
    @State private var dailyGoal: String = ""
    @State private var age: String = ""
    @State private var showResetAlert = false
    @State private var showAddContainer = false
    @State private var showAddTemplate = false
    
    private let glassSizes = [200, 250, 300, 500]
    private let reminderIntervals = [30, 60, 90, 120]
    
    var body: some View {
        ZStack {
            backgroundGradient
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Text("Profile")
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(.bellsYellow)
                    
                    personalSection
                    containersSection
                    calculateButton
                    templatesSection
                    appSettingsSection
                    resetButton
                }
                .padding()
            }
        }
        .onAppear {
            weight = "\(viewModel.profile.weight)"
            dailyGoal = "\(viewModel.profile.dailyGoal)"
            age = viewModel.profile.age.map { "\($0)" } ?? ""
        }
        .alert("Reset data", isPresented: $showResetAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Reset", role: .destructive) {
                viewModel.resetAllData()
                weight = "\(viewModel.profile.weight)"
                dailyGoal = "\(viewModel.profile.dailyGoal)"
            }
        } message: {
            Text("All water entries, reminders, and profile data will be deleted. This cannot be undone.")
        }
        .sheet(isPresented: $showAddContainer) {
            AddContainerView(viewModel: viewModel) { showAddContainer = false }
        }
        .sheet(isPresented: $showAddTemplate) {
            AddTemplateView(viewModel: viewModel) { showAddTemplate = false }
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
                .fill(RadialGradient.bellsGlow(color: .bellsGreen, radius: 140))
                .frame(width: 280, height: 280)
                .offset(x: -100, y: 200)
                .blur(radius: 50)
        }
        .ignoresSafeArea()
    }
    
    private var personalSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Personal")
                .font(.headline)
                .foregroundColor(.white)
            
            weightField
            ageField
            dailyGoalField
            activityPicker
            genderPicker
            glassSizePicker
            reminderIntervalPicker
            themePicker
        }
    }
    
    private var weightField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Weight (kg)")
                .font(.subheadline)
                .foregroundColor(.gray)
            TextField("70", text: $weight)
                .keyboardType(.numberPad)
                .textFieldStyle(.plain)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(LinearGradient.bellsCard)
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.1), lineWidth: 1))
                        .shadow(color: .black.opacity(0.3), radius: 6, x: 0, y: 3)
                )
                .cornerRadius(12)
                .foregroundColor(.white)
                .accentColor(.bellsYellow)
                .onChange(of: weight) { newValue in
                    if let value = Int(newValue), value > 0 {
                        viewModel.profile.weight = value
                        viewModel.saveToUserDefaults()
                    }
                }
        }
    }
    
    private var ageField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Age (optional)")
                .font(.subheadline)
                .foregroundColor(.gray)
            TextField("30", text: $age)
                .keyboardType(.numberPad)
                .textFieldStyle(.plain)
                .padding()
                .background(Color.white.opacity(0.1))
                .cornerRadius(12)
                .foregroundColor(.white)
                .accentColor(.bellsYellow)
                .onChange(of: age) { newValue in
                    if newValue.isEmpty {
                        viewModel.profile.age = nil
                    } else if let value = Int(newValue), value > 0 {
                        viewModel.profile.age = value
                    }
                    viewModel.saveToUserDefaults()
                }
        }
    }
    
    private var dailyGoalField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Daily goal (ml)")
                .font(.subheadline)
                .foregroundColor(.gray)
            TextField("2500", text: $dailyGoal)
                .keyboardType(.numberPad)
                .textFieldStyle(.plain)
                .padding()
                .background(Color.white.opacity(0.1))
                .cornerRadius(12)
                .foregroundColor(.white)
                .accentColor(.bellsYellow)
                .onChange(of: dailyGoal) { newValue in
                    if let value = Int(newValue), value > 0 {
                        viewModel.profile.dailyGoal = value
                        viewModel.saveToUserDefaults()
                    }
                }
        }
    }
    
    private var activityPicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Activity level")
                .font(.subheadline)
                .foregroundColor(.gray)
            Picker("Activity", selection: Binding(
                get: { viewModel.profile.activityLevel },
                set: { viewModel.profile.activityLevel = $0; viewModel.saveToUserDefaults() }
            )) {
                ForEach(ActivityLevel.allCases, id: \.rawValue) { level in
                    Text(level.rawValue).tag(level)
                }
            }
            .pickerStyle(.menu)
            .tint(.bellsYellow)
        }
    }
    
    private var genderPicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Gender")
                .font(.subheadline)
                .foregroundColor(.gray)
            Picker("Gender", selection: Binding(
                get: { viewModel.profile.gender },
                set: { viewModel.profile.gender = $0; viewModel.saveToUserDefaults() }
            )) {
                ForEach(Gender.allCases, id: \.rawValue) { g in
                    Text(g.rawValue).tag(g)
                }
            }
            .pickerStyle(.segmented)
            .colorMultiply(.bellsGreen)
        }
    }
    
    private var glassSizePicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Glass size")
                .font(.subheadline)
                .foregroundColor(.gray)
            Picker("Glass size", selection: Binding(
                get: { viewModel.profile.preferredGlassSize },
                set: { viewModel.profile.preferredGlassSize = $0; viewModel.saveToUserDefaults() }
            )) {
                ForEach(glassSizes, id: \.self) { size in
                    Text("\(size) ml").tag(size)
                }
            }
            .pickerStyle(.segmented)
            .colorMultiply(.bellsGreen)
        }
    }
    
    private var reminderIntervalPicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Reminder interval")
                .font(.subheadline)
                .foregroundColor(.gray)
            Picker("Interval", selection: Binding(
                get: { viewModel.profile.reminderInterval },
                set: { viewModel.profile.reminderInterval = $0; viewModel.saveToUserDefaults() }
            )) {
                ForEach(reminderIntervals, id: \.self) { interval in
                    Text("\(interval) min").tag(interval)
                }
            }
            .pickerStyle(.segmented)
            .colorMultiply(.bellsGreen)
        }
    }
    
    private var themePicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Theme")
                .font(.subheadline)
                .foregroundColor(.gray)
            Picker("Theme", selection: Binding(
                get: { viewModel.profile.theme },
                set: { viewModel.profile.theme = $0; viewModel.saveToUserDefaults() }
            )) {
                ForEach(AppTheme.allCases, id: \.rawValue) { theme in
                    Text(theme.rawValue).tag(theme)
                }
            }
            .pickerStyle(.segmented)
            .colorMultiply(.bellsGreen)
        }
    }
    
    private var containersSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("My containers")
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
                Button {
                    showAddContainer = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.bellsGreen)
                }
            }
            
            ForEach(viewModel.containers) { container in
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(container.name)
                            .font(.subheadline)
                            .foregroundColor(.white)
                        Text("\(container.volume) ml")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                    Button {
                        viewModel.deleteContainer(container)
                    } label: {
                        Image(systemName: "trash")
                            .foregroundColor(.bellsRed)
                    }
                }
                .padding()
                .background(Color.white.opacity(0.05))
                .cornerRadius(12)
            }
        }
    }
    
    private var templatesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Templates")
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
                Button {
                    showAddTemplate = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.bellsGreen)
                }
            }
            
            ForEach(viewModel.templates) { template in
                HStack {
                    Text(template.name)
                        .font(.subheadline)
                        .foregroundColor(.white)
                    Spacer()
                    Text("\(template.effectiveHydration) ml")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Button {
                        viewModel.deleteTemplate(template)
                    } label: {
                        Image(systemName: "trash")
                            .foregroundColor(.bellsRed)
                    }
                }
                .padding()
                .background(Color.white.opacity(0.05))
                .cornerRadius(12)
            }
        }
    }
    
    private var appSettingsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("App")
                .font(.headline)
                .foregroundColor(.white)
            
            NavigationLink {
                SettingsView()
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "gearshape.fill")
                        .font(.title3)
                        .foregroundColor(.bellsYellow)
                    Text("Settings")
                        .font(.subheadline)
                        .foregroundColor(.white)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.5))
                }
                .padding()
                .bellsSmallCard()
            }
        }
    }
    
    private var calculateButton: some View {
        Button {
            viewModel.profile.dailyGoal = viewModel.calculateDailyGoal()
            dailyGoal = "\(viewModel.profile.dailyGoal)"
            viewModel.saveToUserDefaults()
        } label: {
            Text("Calculate norm")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .bellsPrimaryButton(green: true)
        }
    }
    
    private var resetButton: some View {
        Button {
            showResetAlert = true
        } label: {
            Text("Reset data")
                .font(.headline)
                .foregroundColor(.bellsRed)
        }
        .frame(maxWidth: .infinity)
    }
}
