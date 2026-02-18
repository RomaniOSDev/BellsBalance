//
//  UserProfile.swift
//  BellsBalance
//

import Foundation

enum ActivityLevel: String, Codable, CaseIterable {
    case sedentary = "Sedentary"
    case light = "Light"
    case moderate = "Moderate"
    case active = "Active"
    case veryActive = "Very Active"
    
    var multiplier: Double {
        switch self {
        case .sedentary: return 30
        case .light: return 32
        case .moderate: return 35
        case .active: return 38
        case .veryActive: return 42
        }
    }
}

enum Gender: String, Codable, CaseIterable {
    case male = "Male"
    case female = "Female"
}

enum AppTheme: String, Codable, CaseIterable {
    case dark = "Dark"
    case light = "Light"
    case system = "System"
}

struct UserProfile: Codable {
    var weight: Int
    var dailyGoal: Int
    var reminderInterval: Int
    var preferredGlassSize: Int
    var activityLevel: ActivityLevel
    var gender: Gender
    var age: Int?
    var theme: AppTheme
    
    static let defaultProfile = UserProfile(
        weight: 70,
        dailyGoal: 2500,
        reminderInterval: 60,
        preferredGlassSize: 250,
        activityLevel: .moderate,
        gender: .male,
        age: nil,
        theme: .dark
    )
    
    init(weight: Int, dailyGoal: Int, reminderInterval: Int, preferredGlassSize: Int, activityLevel: ActivityLevel = .moderate, gender: Gender = .male, age: Int? = nil, theme: AppTheme = .dark) {
        self.weight = weight
        self.dailyGoal = dailyGoal
        self.reminderInterval = reminderInterval
        self.preferredGlassSize = preferredGlassSize
        self.activityLevel = activityLevel
        self.gender = gender
        self.age = age
        self.theme = theme
    }
    
    enum CodingKeys: String, CodingKey {
        case weight, dailyGoal, reminderInterval, preferredGlassSize
        case activityLevel, gender, age, theme
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        weight = try container.decode(Int.self, forKey: .weight)
        dailyGoal = try container.decode(Int.self, forKey: .dailyGoal)
        reminderInterval = try container.decode(Int.self, forKey: .reminderInterval)
        preferredGlassSize = try container.decode(Int.self, forKey: .preferredGlassSize)
        activityLevel = try container.decodeIfPresent(ActivityLevel.self, forKey: .activityLevel) ?? .moderate
        gender = try container.decodeIfPresent(Gender.self, forKey: .gender) ?? .male
        age = try container.decodeIfPresent(Int.self, forKey: .age)
        theme = try container.decodeIfPresent(AppTheme.self, forKey: .theme) ?? .dark
    }
}
