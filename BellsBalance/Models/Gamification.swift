//
//  Gamification.swift
//  BellsBalance
//

import Foundation

struct GamificationState: Codable {
    var points: Int
    var level: Int
    var lastDailyChallengeDate: Date?
    var completedDailyChallenges: Int
    
    static let `default` = GamificationState(
        points: 0,
        level: 1,
        lastDailyChallengeDate: nil,
        completedDailyChallenges: 0
    )
}

struct DailyChallenge: Identifiable {
    let id: String
    let title: String
    let description: String
    let target: Int
    let pointsReward: Int
    let icon: String
    
    static func todayChallenge() -> DailyChallenge {
        let calendar = Calendar.current
        let dayOfYear = calendar.ordinality(of: .day, in: .year, for: Date()) ?? 1
        let options: [DailyChallenge] = [
            DailyChallenge(id: "early", title: "Early bird", description: "Drink before 9 AM", target: 250, pointsReward: 20, icon: "sun.max.fill"),
            DailyChallenge(id: "double", title: "Double up", description: "Add 500+ ml at once", target: 500, pointsReward: 25, icon: "drop.fill"),
            DailyChallenge(id: "streak", title: "Keep going", description: "5 entries today", target: 5, pointsReward: 30, icon: "flame.fill"),
            DailyChallenge(id: "goal", title: "Goal crusher", description: "Reach 100%", target: 100, pointsReward: 50, icon: "star.fill")
        ]
        return options[dayOfYear % options.count]
    }
}
