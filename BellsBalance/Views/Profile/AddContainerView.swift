//
//  AddContainerView.swift
//  BellsBalance
//

import SwiftUI

struct AddContainerView: View {
    @ObservedObject var viewModel: BellsBalanceViewModel
    var onDismiss: () -> Void
    
    @State private var name: String = ""
    @State private var volume: String = "250"
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.bellsBackground
                    .ignoresSafeArea()
                
                Form {
                    TextField("Name", text: $name)
                        .listRowBackground(Color.white.opacity(0.1))
                        .foregroundColor(.white)
                    
                    TextField("Volume (ml)", text: $volume)
                        .keyboardType(.numberPad)
                        .listRowBackground(Color.white.opacity(0.1))
                        .foregroundColor(.white)
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Add container")
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
                        if !name.isEmpty, let vol = Int(volume), vol > 0 {
                            viewModel.addContainer(name: name, volume: vol)
                            onDismiss()
                        }
                    }
                    .foregroundColor(.bellsGreen)
                    .disabled(name.isEmpty || Int(volume) == nil || (Int(volume) ?? 0) <= 0)
                }
            }
        }
    }
}
