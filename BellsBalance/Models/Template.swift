//
//  Template.swift
//  BellsBalance
//

import Foundation

struct DrinkTemplateItem: Codable {
    let drinkType: DrinkType
    let amount: Int
}

struct Template: Identifiable, Codable {
    let id: UUID
    var name: String
    var items: [DrinkTemplateItem]
    
    init(id: UUID = UUID(), name: String, items: [DrinkTemplateItem]) {
        self.id = id
        self.name = name
        self.items = items
    }
    
    var totalAmount: Int {
        items.reduce(0) { $0 + $1.amount }
    }
    
    var effectiveHydration: Int {
        var total: Double = 0
        for item in items {
            total += Double(item.amount) * item.drinkType.hydrationCoefficient
        }
        return Int(total)
    }
}
