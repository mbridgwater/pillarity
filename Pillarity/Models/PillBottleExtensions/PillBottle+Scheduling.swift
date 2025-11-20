//
//  PillBottle+Scheduling.swift
//  Pillarity
//
//  Created by Anmol Gupta on 11/19/25.
//

import Foundation

extension PillBottle {

    /// Has the user taken at least one dose of this med today?
    var hasTakenToday: Bool {
        guard let lastTakenAt else { return false }
        return Calendar.current.isDateInToday(lastTakenAt)
    }

    /// Simple “low stock” heuristic.
    var isLowStock: Bool {
        // threshold: max(3 doses worth, or 5 pills)
        remainingPillCount <= max(dosageAmount * 3, 5)
    }
}
