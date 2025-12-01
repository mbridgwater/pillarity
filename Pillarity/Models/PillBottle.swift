//
//  PillBottle.swift
//  Pillarity
//
//  Created by Anmol Gupta on 11/18/25.
//

import Foundation
import SwiftData

enum DoseFrequency: String, CaseIterable, Identifiable, Codable {
    case onceDaily = "Once daily"
    case twiceDaily = "Twice daily"
    case threeTimesDaily = "Thrice daily"

    var id: String { rawValue }
}

@Model
final class PillBottle {
    // Relationships
    var identifier: UUID
    var type: Pill          // which pill this bottle contains
    var owner: User?        // which user owns it

    // Inventory
    var initialPillCount: Int      // total pills when bottle is created
    var remainingPillCount: Int    // current pills left
    var createdAt: Date

    // Schedule / configuration
    var dosageAmount: Int   // pills per dose (1, 2, 3…)
    var frequency: DoseFrequency
    var firstDoseTime: Date // time-of-day for first dose

    // Adherence state
    var lastTakenAt: Date?
    var safetyLockEnabled: Bool
    var pillsTakenToday: Int = 0
    var lastDoseTrackingDate: Date  // Allows for auto-reset at midnight

    // TO DO - add a next dose variable 

    // Aggregates for analytics
    // NOTE: Assumption for MVP: All medications are started on the same day.
    // Analytics aggregates roll up across all PillBottle instances.
    // Daily analytics
    var dailyLast7: [Int] = []        // rolling 7 days (for charts)
    var dailyWeekBucket: [Int] = []   // resets every 7 days (for weekly aggregation)
    // Weekly analytics
    var weeklyLast4: [Int] = []       // rolling 4 weeks (for charts)
    var weeklyMonthBucket: [Int] = [] // resets every 4 weeks (for monthly aggregation)
    // Monthly analytics
    var monthlyLast12: [Int] = []     // rolling 12 months (for charts)

    init(
        type: Pill,
        owner: User?,
        initialPillCount: Int,
        remainingPillCount: Int,
        createdAt: Date,
        dosageAmount: Int,
        frequency: DoseFrequency,
        firstDoseTime: Date,
        lastTakenAt: Date? = nil,
        safetyLockEnabled: Bool = false
    ) {
        self.identifier = UUID()
        self.type = type
        self.owner = owner
        self.initialPillCount = initialPillCount
        self.remainingPillCount = remainingPillCount
        self.createdAt = createdAt
        self.dosageAmount = dosageAmount
        self.frequency = frequency
        self.firstDoseTime = firstDoseTime
        self.lastTakenAt = lastTakenAt
        self.safetyLockEnabled = safetyLockEnabled
        self.lastDoseTrackingDate = Date()
    }

    // Resets the daily dose counter if a new day has started
    // Call resetIfNewDay() anytime pillsTakenToday is accessed or modified
    func resetIfNewDay() {
        if !Calendar.current.isDateInToday(lastDoseTrackingDate) {
            pillsTakenToday = 0
            lastDoseTrackingDate = .now
        }
    }

    // Rolls over daily/weekly/monthly analytics if one or more days have passed.
    // Called whenever PillsTakenToday is accessed or modified.
    //
    // MVP Simplification:
    // - If multiple days passed, only the most recent day's pillsTakenToday is added.
    // - Older missing days are treated as 0.
    // - All medications assumed to start on the same day.
    func performDailyRolloverIfNeeded() {
        let calendar = Calendar.current

        if calendar.isDateInToday(lastDoseTrackingDate) {
            return
        }

        let daysPassed = calendar.dateComponents(
            [.day],
            from: calendar.startOfDay(for: lastDoseTrackingDate),
            to: calendar.startOfDay(for: Date())
        ).day ?? 0

        guard daysPassed > 0 else { return }

        // 1. Add missing days: last day gets yesterday’s value, others get 0
        if daysPassed > 1 {
            for _ in 1..<(daysPassed) {
                dailyLast7.append(0)
                dailyWeekBucket.append(0)
            }
        }

        dailyLast7.append(pillsTakenToday)
        dailyWeekBucket.append(pillsTakenToday)

        // Keep rolling 7-day window
        while dailyLast7.count > 7 {
            dailyLast7.removeFirst()
        }

        // 2. Weekly rollup
        if dailyWeekBucket.count == 7 {
            let sumWeek = dailyWeekBucket.reduce(0, +)

            weeklyLast4.append(sumWeek)
            weeklyMonthBucket.append(sumWeek)

            dailyWeekBucket = [] // reset week bucket
        }

        // Keep rolling 4-week window
        while weeklyLast4.count > 4 {
            weeklyLast4.removeFirst()
        }

        // 3. Monthly rollup
        if weeklyMonthBucket.count == 4 {
            let sumMonth = weeklyMonthBucket.reduce(0, +)

            monthlyLast12.append(sumMonth)

            weeklyMonthBucket = [] // reset month bucket
        }

        // Keep rolling 12-month window
        while monthlyLast12.count > 12 {
            monthlyLast12.removeFirst()
        }

        // Reset today
        pillsTakenToday = 0
        lastDoseTrackingDate = Date()
    }

    /// Public entry point for day-boundary logic.
    /// Always call this instead of resetIfNewDay().
    func updateForNewDayIfNeeded() {
        performDailyRolloverIfNeeded()    // handles analytics first
        resetIfNewDay()                   // then zeroes pillsTakenToday safely
    }

}
