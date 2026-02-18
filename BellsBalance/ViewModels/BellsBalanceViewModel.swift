//
//  BellsBalanceViewModel.swift
//  BellsBalance
//

import SwiftUI
import Combine

class BellsBalanceViewModel: ObservableObject {
    @Published var entries: [WaterEntry] = []
    @Published var reminders: [Reminder] = []
    @Published var profile: UserProfile
    @Published var selectedDate: Date = Date()
    @Published var containers: [Container] = []
    @Published var templates: [Template] = []
    @Published var gamification: GamificationState
    @Published var unlockedAchievements: Set<String> = []
    
    private let entriesKey = "bells_entries"
    private let remindersKey = "bells_reminders"
    private let profileKey = "bells_profile"
    private let containersKey = "bells_containers"
    private let templatesKey = "bells_templates"
    private let gamificationKey = "bells_gamification"
    private let achievementsKey = "bells_achievements"
    
    init() {
        self.profile = UserProfile.defaultProfile
        self.gamification = GamificationState.default
        loadFromUserDefaults()
        migrateOldData()
        seedDefaultContainersAndTemplates()
    }
    
    // MARK: - Today (using effective hydration)
    
    var todayEntries: [WaterEntry] {
        entries.filter { Calendar.current.isDate($0.date, inSameDayAs: Date()) }
    }
    
    var todayTotal: Int {
        todayEntries.reduce(0) { $0 + $1.effectiveAmount }
    }
    
    var todayPercentage: Double {
        guard profile.dailyGoal > 0 else { return 0 }
        return min(Double(todayTotal) / Double(profile.dailyGoal) * 100, 150)
    }
    
    var todayLevel: HydrationLevel {
        HydrationLevel.from(percentage: todayPercentage)
    }
    
    var todayStatusColor: Color {
        switch todayLevel {
        case .critical: return .bellsRed
        case .low: return .bellsYellow
        case .good, .excellent: return .bellsGreen
        }
    }
    
    // MARK: - CRUD Entries
    
    func addEntry(amount: Int, note: String?, isReminder: Bool, drinkType: DrinkType = .water, containerId: UUID? = nil) {
        let entry = WaterEntry(amount: amount, date: Date(), note: note, isReminder: isReminder, drinkType: drinkType, containerId: containerId)
        entries.insert(entry, at: 0)
        addPoints(for: entry)
        checkAchievements()
        saveToUserDefaults()
    }
    
    func addEntries(from template: Template, note: String? = nil) {
        for item in template.items {
            addEntry(amount: item.amount, note: note, isReminder: false, drinkType: item.drinkType)
        }
    }
    
    func deleteEntry(_ entry: WaterEntry) {
        entries.removeAll { $0.id == entry.id }
        saveToUserDefaults()
    }
    
    // MARK: - CRUD Reminders
    
    func addReminder(time: Date, days: [Int], note: String?) {
        let reminder = Reminder(time: time, isActive: true, days: days, note: note)
        reminders.append(reminder)
        saveToUserDefaults()
    }
    
    func updateReminder(_ reminder: Reminder) {
        if let index = reminders.firstIndex(where: { $0.id == reminder.id }) {
            reminders[index] = reminder
            saveToUserDefaults()
        }
    }
    
    func deleteReminder(_ reminder: Reminder) {
        reminders.removeAll { $0.id == reminder.id }
        saveToUserDefaults()
    }
    
    func toggleReminder(_ reminder: Reminder) {
        if let index = reminders.firstIndex(where: { $0.id == reminder.id }) {
            reminders[index].isActive.toggle()
            saveToUserDefaults()
        }
    }
    
    // MARK: - Containers
    
    func addContainer(name: String, volume: Int) {
        containers.append(Container(name: name, volume: volume))
        saveToUserDefaults()
    }
    
    func updateContainer(_ container: Container) {
        if let index = containers.firstIndex(where: { $0.id == container.id }) {
            containers[index] = container
            saveToUserDefaults()
        }
    }
    
    func deleteContainer(_ container: Container) {
        containers.removeAll { $0.id == container.id }
        saveToUserDefaults()
    }
    
    // MARK: - Templates
    
    func addTemplate(name: String, items: [DrinkTemplateItem]) {
        templates.append(Template(name: name, items: items))
        saveToUserDefaults()
    }
    
    func deleteTemplate(_ template: Template) {
        templates.removeAll { $0.id == template.id }
        saveToUserDefaults()
    }
    
    // MARK: - Statistics (effective hydration)
    
    func entriesForDate(_ date: Date) -> [WaterEntry] {
        entries.filter { Calendar.current.isDate($0.date, inSameDayAs: date) }
    }
    
    func totalForDate(_ date: Date) -> Int {
        entriesForDate(date).reduce(0) { $0 + $1.effectiveAmount }
    }
    
    func percentageForDate(_ date: Date) -> Double {
        guard profile.dailyGoal > 0 else { return 0 }
        return Double(totalForDate(date)) / Double(profile.dailyGoal) * 100
    }
    
    func streakDays() -> Int {
        let calendar = Calendar.current
        var currentDate = calendar.startOfDay(for: Date())
        var streak = 0
        while true {
            let total = totalForDate(currentDate)
            let percentage = Double(total) / Double(profile.dailyGoal) * 100
            if percentage >= 100 {
                streak += 1
                guard let previous = calendar.date(byAdding: .day, value: -1, to: currentDate) else { break }
                currentDate = previous
            } else { break }
        }
        return streak
    }
    
    func weeklyTotals() -> [Int] {
        let calendar = Calendar.current
        var result: [Int] = []
        for i in (0..<7).reversed() {
            guard let date = calendar.date(byAdding: .day, value: -i, to: Date()) else { continue }
            result.append(totalForDate(date))
        }
        return result
    }
    
    func weeklyAverages() -> [Int] {
        let totals = weeklyTotals()
        guard !totals.isEmpty else { return [] }
        return totals.map { $0 / totals.count }
    }
    
    func monthlyTotal() -> Int {
        let calendar = Calendar.current
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: Date())) ?? Date()
        let endOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth) ?? Date()
        return entries
            .filter { $0.date >= startOfMonth && $0.date <= endOfMonth }
            .reduce(0) { $0 + $1.effectiveAmount }
    }
    
    func averageDailyVolume() -> Int {
        let totals = weeklyTotals()
        guard !totals.isEmpty else { return 0 }
        return totals.reduce(0, +) / totals.count
    }
    
    func totalLitersAllTime() -> Int {
        entries.reduce(0) { $0 + $1.effectiveAmount }
    }
    
    // MARK: - Analytics
    
    func trendsLast30Days() -> [(Date, Int)] {
        let calendar = Calendar.current
        return (0..<30).compactMap { i -> (Date, Int)? in
            guard let date = calendar.date(byAdding: .day, value: -29 + i, to: Date()) else { return nil }
            return (date, totalForDate(date))
        }
    }
    
    func forecastToday() -> Int {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: Date())
        let remainingHours = max(1, 24 - hour)
        let avgPerHour = todayTotal / max(1, hour)
        return todayTotal + avgPerHour * remainingHours
    }
    
    func bestHourOfDay() -> Int? {
        var hourTotals: [Int: Int] = [:]
        let calendar = Calendar.current
        let thirtyDaysAgo = calendar.date(byAdding: .day, value: -30, to: Date()) ?? Date()
        for entry in entries where entry.date >= thirtyDaysAgo {
            let hour = calendar.component(.hour, from: entry.date)
            hourTotals[hour, default: 0] += entry.effectiveAmount
        }
        return hourTotals.max(by: { $0.value < $1.value })?.key
    }
    
    func exportCSV() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        var csv = "Date,Amount,Type,Effective,Note,Reminder\n"
        for entry in entries.sorted(by: { $0.date > $1.date }) {
            csv += "\(formatter.string(from: entry.date)),\(entry.amount),\(entry.drinkType.rawValue),\(entry.effectiveAmount),\(entry.note ?? ""),\(entry.isReminder)\n"
        }
        return csv
    }
    
    // MARK: - Motivation & Tips
    
    func dailyTip() -> String {
        let percentage = todayPercentage
        if percentage < 30 { return "Start with a glass of water — every drop counts!" }
        if percentage < 70 { return "You're halfway there. Keep sipping!" }
        if percentage < 100 { return "Almost there! One more glass to go." }
        return "You crushed it today! Stay hydrated tomorrow too."
    }
    
    // MARK: - Color for calendar
    
    func colorForDate(_ date: Date) -> Color {
        let percentage = percentageForDate(date)
        if percentage >= 100 { return .bellsGreen }
        else if percentage >= 50 { return .bellsYellow }
        else if percentage > 0 { return .bellsRed }
        else { return .gray.opacity(0.3) }
    }
    
    // MARK: - Gamification
    
    var points: Int { gamification.points }
    var level: Int { gamification.level }
    
    var pointsToNextLevel: Int {
        level * 100
    }
    
    func addPoints(for entry: WaterEntry) {
        var pts = 5
        if entry.effectiveAmount >= 500 { pts += 10 }
        if entry.isReminder { pts += 5 }
        gamification.points += pts
        updateLevel()
    }
    
    private func updateLevel() {
        let required = (1...level).reduce(0) { $0 + $1 * 100 }
        if gamification.points >= required {
            gamification.level = min(level + 1, 99)
        }
    }
    
    var todayDailyChallenge: DailyChallenge {
        DailyChallenge.todayChallenge()
    }
    
    func completeDailyChallenge() -> Bool {
        let challenge = todayDailyChallenge
        let calendar = Calendar.current
        if let last = gamification.lastDailyChallengeDate, calendar.isDateInToday(last) {
            return false
        }
        var completed = false
        switch challenge.id {
        case "early":
            completed = todayEntries.contains { Calendar.current.component(.hour, from: $0.date) < 9 && $0.effectiveAmount >= challenge.target }
        case "double":
            completed = todayEntries.contains { $0.effectiveAmount >= challenge.target }
        case "streak":
            completed = todayEntries.count >= challenge.target
        case "goal":
            completed = todayPercentage >= Double(challenge.target)
        default:
            break
        }
        if completed {
            gamification.lastDailyChallengeDate = Date()
            gamification.completedDailyChallenges += 1
            gamification.points += challenge.pointsReward
            saveToUserDefaults()
        }
        return completed
    }
    
    func isDailyChallengeCompleted() -> Bool {
        guard let last = gamification.lastDailyChallengeDate else { return false }
        return Calendar.current.isDateInToday(last)
    }
    
    // MARK: - Achievements
    
    func checkAchievements() {
        var newUnlocked: Set<String> = unlockedAchievements
        
        if streakDays() >= 7 && !newUnlocked.contains("streak7") { newUnlocked.insert("streak7") }
        if streakDays() >= 30 && !newUnlocked.contains("streak30") { newUnlocked.insert("streak30") }
        if totalLitersAllTime() >= 100_000 && !newUnlocked.contains("100liters") { newUnlocked.insert("100liters") }
        if totalLitersAllTime() >= 500_000 && !newUnlocked.contains("500liters") { newUnlocked.insert("500liters") }
        if hasEarlyBird() && !newUnlocked.contains("early") { newUnlocked.insert("early") }
        if streakDays() >= 7 && !newUnlocked.contains("perfect") {
            let last7 = (0..<7).allSatisfy { i in
                guard let d = Calendar.current.date(byAdding: .day, value: -i, to: Date()) else { return false }
                return percentageForDate(d) >= 100
            }
            if last7 { newUnlocked.insert("perfect") }
        }
        let drinkTypes = Set(entries.map { $0.drinkType })
        if drinkTypes.count >= 4 && !newUnlocked.contains("diversity") { newUnlocked.insert("diversity") }
        let reminderCount = entries.filter { $0.isReminder }.count
        if reminderCount >= 10 && !newUnlocked.contains("reminder") { newUnlocked.insert("reminder") }
        
        unlockedAchievements = newUnlocked
    }
    
    func hasEarlyBird() -> Bool {
        todayEntries.contains { Calendar.current.component(.hour, from: $0.date) < 8 && $0.effectiveAmount > 0 }
    }
    
    func isAchievementUnlocked(_ id: String) -> Bool {
        unlockedAchievements.contains(id)
    }
    
    // MARK: - Calculate daily goal (with activity, gender, age)
    
    func calculateDailyGoal() -> Int {
        var base = Double(profile.weight) * profile.activityLevel.multiplier
        if profile.gender == .female { base *= 0.9 }
        if let age = profile.age, age > 50 { base *= 0.95 }
        return Int(base)
    }
    
    // MARK: - Persistence
    
    func saveToUserDefaults() {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        if let entriesData = try? encoder.encode(entries) { UserDefaults.standard.set(entriesData, forKey: entriesKey) }
        if let remindersData = try? encoder.encode(reminders) { UserDefaults.standard.set(remindersData, forKey: remindersKey) }
        if let profileData = try? encoder.encode(profile) { UserDefaults.standard.set(profileData, forKey: profileKey) }
        if let containersData = try? encoder.encode(containers) { UserDefaults.standard.set(containersData, forKey: containersKey) }
        if let templatesData = try? encoder.encode(templates) { UserDefaults.standard.set(templatesData, forKey: templatesKey) }
        if let gamificationData = try? encoder.encode(gamification) { UserDefaults.standard.set(gamificationData, forKey: gamificationKey) }
        UserDefaults.standard.set(Array(unlockedAchievements), forKey: achievementsKey)
    }
    
    func loadFromUserDefaults() {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        if let entriesData = UserDefaults.standard.data(forKey: entriesKey),
           let decoded = try? decoder.decode([WaterEntry].self, from: entriesData) {
            entries = decoded.sorted { $0.date > $1.date }
        }
        if let remindersData = UserDefaults.standard.data(forKey: remindersKey),
           let decoded = try? decoder.decode([Reminder].self, from: remindersData) { reminders = decoded }
        if let profileData = UserDefaults.standard.data(forKey: profileKey),
           let decoded = try? decoder.decode(UserProfile.self, from: profileData) { profile = decoded }
        if let containersData = UserDefaults.standard.data(forKey: containersKey),
           let decoded = try? decoder.decode([Container].self, from: containersData) { containers = decoded }
        if let templatesData = UserDefaults.standard.data(forKey: templatesKey),
           let decoded = try? decoder.decode([Template].self, from: templatesData) { templates = decoded }
        if let gamificationData = UserDefaults.standard.data(forKey: gamificationKey),
           let decoded = try? decoder.decode(GamificationState.self, from: gamificationData) { gamification = decoded }
        if let arr = UserDefaults.standard.array(forKey: achievementsKey) as? [String] {
            unlockedAchievements = Set(arr)
        }
    }
    
    private func migrateOldData() {
        // Old data migrated via Codable defaults
    }
    
    private func seedDefaultContainersAndTemplates() {
        if containers.isEmpty {
            containers = [
                Container(name: "Glass", volume: 250),
                Container(name: "Bottle", volume: 500),
                Container(name: "Mug", volume: 350)
            ]
        }
        if templates.isEmpty {
            templates = [
                Template(name: "Morning", items: [
                    DrinkTemplateItem(drinkType: .water, amount: 250),
                    DrinkTemplateItem(drinkType: .coffee, amount: 200)
                ]),
                Template(name: "After workout", items: [
                    DrinkTemplateItem(drinkType: .water, amount: 500)
                ])
            ]
        }
    }
    
    func resetAllData() {
        entries = []
        reminders = []
        profile = UserProfile.defaultProfile
        containers = [
            Container(name: "Glass", volume: 250),
            Container(name: "Bottle", volume: 500),
            Container(name: "Mug", volume: 350)
        ]
        templates = [
            Template(name: "Morning", items: [
                DrinkTemplateItem(drinkType: .water, amount: 250),
                DrinkTemplateItem(drinkType: .coffee, amount: 200)
            ]),
            Template(name: "After workout", items: [
                DrinkTemplateItem(drinkType: .water, amount: 500)
            ])
        ]
        gamification = GamificationState.default
        unlockedAchievements = []
        saveToUserDefaults()
    }
}
