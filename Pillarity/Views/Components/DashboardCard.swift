//
//  DashboardCard.swift
//  Pillarity
//
//  Created by Anmol Gupta on 11/19/25.
//

import SwiftUI
import SwiftData

// MARK: - View

struct DashboardCard: View {
    let title: String
    let value: String
    let subtitle: String
    let icon: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Spacer()
                Image(systemName: icon)
                    .foregroundColor(.gray)
            }

            Text(value)
                .font(.title.bold())

            Text(subtitle)
                .font(.footnote)
                .foregroundColor(.secondary)
        }
        .padding(18)
        .frame(maxWidth: .infinity)
        .background(Color(.systemGray6))
        .cornerRadius(18)
    }
}

// MARK: - Per-bottle helpers

extension PillBottle {

    /// How many times per day this med is scheduled.
    var dosesPerDay: Int {
        switch frequency {
        case .onceDaily:       return 1
        case .twiceDaily:      return 2
        case .threeTimesDaily: return 3
        }
    }

    /// Total “doses” for this med per day (freq × dosageAmount).
    var totalDailyDoses: Int {
        dosageAmount * dosesPerDay
    }

    /// Scheduled dose times for a given calendar day.
    func doseTimes(on date: Date) -> [Date] {
        let calendar = Calendar.current
        var comps = calendar.dateComponents([.year, .month, .day], from: date)

        func makeTime(hour: Int, minute: Int) -> Date? {
            comps.hour = hour
            comps.minute = minute
            return calendar.date(from: comps)
        }

        switch frequency {
        case .onceDaily:
            // Respect user-configured firstDoseTime
            let hour   = calendar.component(.hour,   from: firstDoseTime)
            let minute = calendar.component(.minute, from: firstDoseTime)
            return [makeTime(hour: hour, minute: minute)].compactMap { $0 }

        case .twiceDaily:
            // Defaults: 8:00 AM and 5:00 PM
            return [
                makeTime(hour: 8,  minute: 0),
                makeTime(hour: 17, minute: 0)
            ].compactMap { $0 }

        case .threeTimesDaily:
            // Defaults: 8:00 AM, 1:00 PM, 6:00 PM
            return [
                makeTime(hour: 8,  minute: 0),
                makeTime(hour: 13, minute: 0),
                makeTime(hour: 18, minute: 0)
            ].compactMap { $0 }
        }
    }

    /// Next scheduled dose time from `now` forward.
    func nextDoseDate(after now: Date = Date()) -> Date? {
        let calendar = Calendar.current

        // 1) Try remaining times today
        let today = now
        let todayTimes = doseTimes(on: today).filter { $0 >= now }
        if let earliestToday = todayTimes.min() {
            return earliestToday
        }

        // 2) Otherwise first time tomorrow
        guard let tomorrow = calendar.date(byAdding: .day, value: 1, to: today) else {
            return nil
        }
        return doseTimes(on: tomorrow).min()
    }
}

// MARK: - Dashboard card builders

extension DashboardCard {

    /// "Doses Today" card.
    static func dosesTodayCard(for bottles: [PillBottle]) -> DashboardCard {
        // denominator: sum of totalDailyDoses across all meds
        let totalDoses = bottles.reduce(0) { $0 + $1.totalDailyDoses }

        // TODO: replace with real count once you track taken doses
        let takenDoses = 0

        let remaining = max(totalDoses - takenDoses, 0)

        let value: String
        let subtitle: String

        if totalDoses > 0 {
            value = "\(takenDoses)/\(totalDoses)"
            subtitle = "\(remaining) remaining"
        } else {
            value = "0/0"
            subtitle = "No doses scheduled today"
        }

        return DashboardCard(
            title: "Doses Today",
            value: value,
            subtitle: subtitle,
            icon: "pills"
        )
    }

    /// "Next Dose" card.
    static func nextDoseCard(for bottles: [PillBottle]) -> DashboardCard {
        let now = Date()
        let calendar = Calendar.current

        let nextDose = bottles
            .compactMap { $0.nextDoseDate(after: now) }
            .min()

        guard let next = nextDose else {
            return DashboardCard(
                title: "Next Dose",
                value: "--",
                subtitle: "No upcoming doses",
                icon: "clock"
            )
        }

        let timeFormatter = DateFormatter()
        timeFormatter.timeStyle = .short

        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short

        let timeString = timeFormatter.string(from: next)
        let minutes = Int(next.timeIntervalSince(now) / 60)

        let subtitle: String
        if calendar.isDateInToday(next) {
            if minutes <= 0 {
                subtitle = "Due now"
            } else if minutes < 60 {
                subtitle = "in \(minutes) min"
            } else {
                let hours = minutes / 60
                subtitle = "in \(hours) hr"
            }
        } else if calendar.isDateInTomorrow(next) {
            subtitle = "Tomorrow at \(timeString)"
        } else {
            subtitle = dateFormatter.string(from: next)
        }

        return DashboardCard(
            title: "Next Dose",
            value: timeString,
            subtitle: subtitle,
            icon: "clock"
        )
    }
}
