//
//  AddTemplateView.swift
//  BellsBalance
//

import SwiftUI

struct AddTemplateView: View {
    @ObservedObject var viewModel: BellsBalanceViewModel
    var onDismiss: () -> Void
    
    @State private var name: String = ""
    @State private var items: [DrinkTemplateItem] = [DrinkTemplateItem(drinkType: .water, amount: 250)]
    @State private var showAddItem = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.bellsBackground
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Template name")
                                .font(.headline)
                                .foregroundColor(.white)
                            TextField("Morning routine", text: $name)
                                .textFieldStyle(.plain)
                                .padding()
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(12)
                                .foregroundColor(.white)
                                .accentColor(.bellsYellow)
                        }
                        
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Drinks")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                Spacer()
                                Button {
                                    items.append(DrinkTemplateItem(drinkType: .water, amount: 250))
                                } label: {
                                    Image(systemName: "plus.circle.fill")
                                        .foregroundColor(.bellsGreen)
                                }
                            }
                            
                            ForEach(Array(items.enumerated()), id: \.offset) { index, _ in
                                templateItemRow(index: index)
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Add template")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        onDismiss()
                    }
                    .foregroundColor(.bellsRed)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        if !name.isEmpty, !items.isEmpty {
                            viewModel.addTemplate(name: name, items: items)
                            onDismiss()
                        }
                    }
                    .foregroundColor(.bellsGreen)
                    .disabled(name.isEmpty || items.isEmpty)
                }
            }
        }
    }
    
    @ViewBuilder
    private func templateItemRow(index: Int) -> some View {
        if index < items.count {
            HStack {
                Picker("", selection: Binding(
                    get: { items[index].drinkType },
                    set: { newType in
                        items[index] = DrinkTemplateItem(drinkType: newType, amount: items[index].amount)
                    }
                )) {
                    ForEach(DrinkType.allCases, id: \.self) { type in
                        Text(type.displayName).tag(type)
                    }
                }
                .pickerStyle(.menu)
                .tint(.bellsYellow)
                .frame(width: 120)
                
                TextField("ml", value: Binding(
                    get: { items[index].amount },
                    set: { newAmount in
                        items[index] = DrinkTemplateItem(drinkType: items[index].drinkType, amount: newAmount)
                    }
                ), format: .number)
                    .keyboardType(.numberPad)
                    .textFieldStyle(.plain)
                    .padding()
                    .frame(width: 80)
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(8)
                    .foregroundColor(.white)
                
                if items.count > 1 {
                    Button {
                        items.remove(at: index)
                    } label: {
                        Image(systemName: "trash")
                            .foregroundColor(.bellsRed)
                    }
                }
            }
            .padding()
            .background(Color.white.opacity(0.05))
            .cornerRadius(12)
        }
    }
}
