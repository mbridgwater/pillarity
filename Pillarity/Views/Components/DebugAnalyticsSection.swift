//
//  DebugAnalyticsSection.swift
//  Pillarity
//

import SwiftUI

struct DebugAnalyticsSection: View {
    @Environment(\.modelContext) private var modelContext
    let bottle: PillBottle

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("DEBUG Analytics")
                .font(.caption.bold())
                .foregroundStyle(.secondary)

            Group {
                Text("Daily (last 7): \(bottle.dailyLast7)")
                Text("Daily WeekBucket: \(bottle.dailyWeekBucket)")
            }
            .font(.caption2)
            .foregroundStyle(.secondary)

            Group {
                Text("Weekly (last 4): \(bottle.weeklyLast4)")
                Text("Weekly MonthBucket: \(bottle.weeklyMonthBucket)")
            }
            .font(.caption2)
            .foregroundStyle(.secondary)

            Text("Monthly (last 12): \(bottle.monthlyLast12)")
                .font(.caption2)
                .foregroundStyle(.secondary)

            Button("Simulate Day Rollover") {
                bottle.lastDoseTrackingDate = Calendar.current
                    .date(byAdding: .day, value: -1, to: .now)!

                bottle.updateForNewDayIfNeeded()
                try? modelContext.save()
            }
            .buttonStyle(.bordered)
            .font(.caption)
            .padding(.top, 6)

            Button("Simulate Taking 1 Pill") {
                bottle.updateForNewDayIfNeeded()
                bottle.pillsTakenToday += 1
                bottle.remainingPillCount = max(bottle.remainingPillCount - 1, 0)
                bottle.lastTakenAt = .now

                try? modelContext.save()
            }
            .buttonStyle(.borderedProminent)
            .font(.caption)
            .padding(.top, 4)
        }
        .padding(.top, 8)
    }
}
