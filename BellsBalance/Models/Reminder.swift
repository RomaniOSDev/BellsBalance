//
//  Reminder.swift
//  BellsBalance
//

import Foundation

struct Reminder: Identifiable, Codable {
    let id: UUID
    var time: Date
    var isActive: Bool
    var days: [Int] // 1-7, 1 = Monday
    var note: String?
    
    init(id: UUID = UUID(), time: Date, isActive: Bool = true, days: [Int], note: String? = nil) {
        self.id = id
        self.time = time
        self.isActive = isActive
        self.days = days
        self.note = note
    }
}
