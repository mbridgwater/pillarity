//
//  DashboardCard.swift
//  Pillarity
//
//  Created by Anmol Gupta on 11/19/25.
//

import SwiftUI
import SwiftData

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

extension DashboardCard {

    static func dosesTodayCard(for bottles: [PillBottle]) -> DashboardCard {
        let totalDoses = bottles.reduce(0) { $0 + $1.totalDailyDoses }

        // TODO: replace with real count when you track doses
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
