//
//  Container.swift
//  BellsBalance
//

import Foundation

struct Container: Identifiable, Codable {
    let id: UUID
    var name: String
    var volume: Int // ml
    
    init(id: UUID = UUID(), name: String, volume: Int) {
        self.id = id
        self.name = name
        self.volume = volume
    }
}
