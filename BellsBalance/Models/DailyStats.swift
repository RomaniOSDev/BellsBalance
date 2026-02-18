//
//  DailyStats.swift
//  BellsBalance
//

import Foundation

struct DailyStats: Codable {
    let date: Date
    var total: Int
    var entries: [WaterEntry]
    var goalAchieved: Bool
}
