//
//  Achievement.swift
//  BellsBalance
//

import Foundation

struct Achievement: Identifiable {
    let id: String
    let title: String
    let description: String
    let icon: String
    let color: String
    
    static let all: [Achievement] = [
        Achievement(id: "streak7", title: "7 days in a row", description: "Hit goal 7 days straight", icon: "bell.fill", color: "green"),
        Achievement(id: "streak30", title: "30-day streak", description: "Hit goal for 30 days", icon: "flame.fill", color: "green"),
        Achievement(id: "100liters", title: "100 liters", description: "Total 100 liters logged", icon: "drop.fill", color: "yellow"),
        Achievement(id: "500liters", title: "500 liters", description: "Total 500 liters logged", icon: "drop.fill", color: "yellow"),
        Achievement(id: "early", title: "Early bird", description: "First drink before 8 AM", icon: "sun.max.fill", color: "yellow"),
        Achievement(id: "perfect", title: "Perfect week", description: "7/7 days at 100%+", icon: "star.fill", color: "green"),
        Achievement(id: "diversity", title: "Variety", description: "Log 4 drink types", icon: "cup.and.saucer.fill", color: "yellow"),
        Achievement(id: "reminder", title: "On time", description: "Log 10 reminder responses", icon: "bell.badge.fill", color: "green")
    ]
}
