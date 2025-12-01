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
}
