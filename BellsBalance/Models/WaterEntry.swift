//
//  WaterEntry.swift
//  BellsBalance
//

import Foundation

struct WaterEntry: Identifiable, Codable {
    let id: UUID
    let amount: Int // ml
    let date: Date
    let note: String?
    let isReminder: Bool
    let drinkType: DrinkType
    let containerId: UUID?
    
    init(id: UUID = UUID(), amount: Int, date: Date = Date(), note: String? = nil, isReminder: Bool = false, drinkType: DrinkType = .water, containerId: UUID? = nil) {
        self.id = id
        self.amount = amount
        self.date = date
        self.note = note
        self.isReminder = isReminder
        self.drinkType = drinkType
        self.containerId = containerId
    }
    
    /// Effective hydration in ml (amount × coefficient)
    var effectiveAmount: Int {
        Int(Double(amount) * drinkType.hydrationCoefficient)
    }
    
    enum CodingKeys: String, CodingKey {
        case id, amount, date, note, isReminder, drinkType, containerId
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        amount = try container.decode(Int.self, forKey: .amount)
        date = try container.decode(Date.self, forKey: .date)
        note = try container.decodeIfPresent(String.self, forKey: .note)
        isReminder = try container.decodeIfPresent(Bool.self, forKey: .isReminder) ?? false
        drinkType = try container.decodeIfPresent(DrinkType.self, forKey: .drinkType) ?? .water
        containerId = try container.decodeIfPresent(UUID.self, forKey: .containerId)
    }
}
