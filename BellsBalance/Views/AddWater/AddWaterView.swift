//
//  AddWaterView.swift
//  BellsBalance
//

import SwiftUI

struct AddWaterView: View {
    @ObservedObject var viewModel: BellsBalanceViewModel
    var onDismiss: () -> Void
    
    @State private var amount: Int = 250
    @State private var note: String = ""
    @State private var isReminder: Bool = false
    @State private var drinkType: DrinkType = .water
    @State private var selectedContainerId: UUID?
    
    private let presetAmounts = [200, 250, 300, 500]
    
    var body: some View {
        NavigationView {
            ZStack {
                backgroundGradient
                
                ScrollView {
                    VStack(spacing: 24) {
                        templatesSection
                        drinkTypeSelector
                        volumeSelector
                        containerButtons
                        presetButtons
                        noteField
                        reminderCheckbox
                        actionButtons
                    }
                    .padding()
                }
            }
            .navigationTitle("Add drink")
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
        .onAppear {
            amount = viewModel.profile.preferredGlassSize
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
                .fill(RadialGradient.bellsGlow(color: .bellsGreen, radius: 140))
                .frame(width: 280, height: 280)
                .offset(x: 100, y: -80)
                .blur(radius: 60)
        }
        .ignoresSafeArea()
    }
    
    private var templatesSection: some View {
        Group {
            if !viewModel.templates.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Templates")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(viewModel.templates) { template in
                                Button {
                                    viewModel.addEntries(from: template)
                                    onDismiss()
                                } label: {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(template.name)
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                            .foregroundColor(.black)
                                        Text("\(template.effectiveHydration) ml")
                                            .font(.caption)
                                            .foregroundColor(.black.opacity(0.7))
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(LinearGradient.bellsButtonYellow)
                                            .shadow(color: Color.bellsYellow.opacity(0.4), radius: 8, x: 0, y: 4)
                                    )
                                    .cornerRadius(12)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    private var drinkTypeSelector: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Drink type")
                .font(.headline)
                .foregroundColor(.white)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(DrinkType.allCases) { type in
                        Button {
                            drinkType = type
                        } label: {
                            VStack(spacing: 4) {
                                Image(systemName: type.icon)
                                    .font(.title2)
                                Text(type.displayName)
                                    .font(.caption2)
                            }
                            .foregroundColor(drinkType == type ? .black : .white)
                            .frame(width: 70)
                            .padding(.vertical, 12)
                            .background(drinkType == type ? Color.bellsYellow : Color.white.opacity(0.1))
                            .cornerRadius(12)
                        }
                    }
                }
            }
        }
    }
    
    private var volumeSelector: some View {
        VStack(spacing: 16) {
            Text("Volume")
                .font(.headline)
                .foregroundColor(.white)
            
            HStack(spacing: 24) {
                Button {
                    amount = max(50, amount - viewModel.profile.preferredGlassSize)
                } label: {
                    Image(systemName: "minus.circle.fill")
                        .font(.system(size: 44))
                        .foregroundColor(.bellsYellow)
                }
                
                Text("\(amount) ml")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.bellsGreen)
                    .frame(minWidth: 120)
                
                Button {
                    amount = min(3000, amount + viewModel.profile.preferredGlassSize)
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 44))
                        .foregroundColor(.bellsYellow)
                }
            }
        }
        .padding()
    }
    
    private var containerButtons: some View {
        Group {
            if !viewModel.containers.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("My containers")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(viewModel.containers) { container in
                                Button {
                                    amount = container.volume
                                    selectedContainerId = container.id
                                } label: {
                                    Text("\(container.name)\n\(container.volume) ml")
                                        .font(.caption)
                                        .multilineTextAlignment(.center)
                                        .foregroundColor(selectedContainerId == container.id ? .black : .white)
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 10)
                                        .background(selectedContainerId == container.id ? Color.bellsGreen : Color.white.opacity(0.1))
                                        .cornerRadius(12)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    private var presetButtons: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick select")
                .font(.headline)
                .foregroundColor(.white)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(presetAmounts, id: \.self) { preset in
                    Button {
                        amount = preset
                        selectedContainerId = nil
                    } label: {
                        Text("\(preset) ml")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(amount == preset ? Color.bellsYellow : Color.white.opacity(0.1))
                            .cornerRadius(12)
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
            
            TextField("After workout", text: $note)
                .textFieldStyle(.plain)
                .padding()
                .background(Color.white.opacity(0.1))
                .cornerRadius(12)
                .foregroundColor(.white)
                .accentColor(.bellsYellow)
        }
    }
    
    private var reminderCheckbox: some View {
        Button {
            isReminder.toggle()
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "bell.fill")
                    .foregroundColor(isReminder ? .bellsYellow : .gray)
                
                Text("Was this a reminder?")
                    .font(.subheadline)
                    .foregroundColor(.white)
                
                Spacer()
                
                if isReminder {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.bellsYellow)
                }
            }
            .padding()
            .background(Color.white.opacity(0.05))
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }
    
    private var actionButtons: some View {
        VStack(spacing: 16) {
            Button {
                viewModel.addEntry(amount: amount, note: note.isEmpty ? nil : note, isReminder: isReminder, drinkType: drinkType, containerId: selectedContainerId)
                onDismiss()
            } label: {
                Text("Add")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .bellsPrimaryButton(green: true)
            }
        }
    }
}
