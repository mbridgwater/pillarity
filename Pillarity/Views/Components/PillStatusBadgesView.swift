//
//  PillStatusBadgesView.swift
//  Pillarity
//
//  Created by Anmol Gupta on 11/19/25.
//

import SwiftUI
import SwiftData

extension PillBottle {
    // TO DO: reflect medicine removals as taken - factor in dose and frequency. update lastTakenAt when med is taken.
    var hasTakenToday: Bool {
        guard let lastTakenAt else { return false }
        return Calendar.current.isDateInToday(lastTakenAt)
    }

    var isLowStock: Bool {
        // threshold is arbitrary; tweak later
        remainingPillCount <= max(dosageAmount * 3, 5)
    }
}

struct IntakeStatusBadge: View {
    let takenToday: Bool

    var body: some View {
        Text(takenToday ? "Taken" : "Not Yet Taken")
            .font(.caption)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(takenToday ? Color.black : Color(.systemGray5))
            .foregroundColor(takenToday ? .white : .primary)
            .cornerRadius(14)
    }
}

struct LowStockBadge: View {
    var body: some View {
        Text("Low Stock")
            .font(.caption)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(Color("AccentColor").opacity(0.9))
            .foregroundColor(.white)
            .cornerRadius(14)
    }
}

struct PillStatusBadgesRow: View {
    let bottle: PillBottle

    var body: some View {
        HStack(spacing: 8) {
            IntakeStatusBadge(takenToday: bottle.hasTakenToday)

            if bottle.isLowStock {
                LowStockBadge()
            }
        }
    }
}
