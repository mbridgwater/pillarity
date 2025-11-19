////
////  PillDoseInfoView.swift
////  Pillarity
////
////  Created by Anmol Gupta on 11/19/25.
////
//
//import SwiftUI
//import SwiftData
//
//struct PillDoseInfoView: View {
//    let bottle: PillBottle
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 8) {
//            // Next dose
//            HStack(spacing: 8) {
//                Image(systemName: "clock")
//                    .foregroundColor(.secondary)
//                Text("Next dose:")
//                    .font(.subheadline)
//                    .foregroundColor(.secondary)
//                Text(nextDoseText)
//                    .font(.subheadline)
//            }
//
//            // Last taken
//            HStack(spacing: 8) {
//                Image(systemName: "waveform.path.ecg")
//                    .foregroundColor(.secondary)
//                Text("Last taken:")
//                    .font(.subheadline)
//                    .foregroundColor(.secondary)
//                Text(lastTakenText)
//                    .font(.subheadline)
//            }
//        }
//    }
//
//    private var nextDoseText: String {
//        // for now using firstDoseTime.
//        let timeFormatter = DateFormatter()
//        timeFormatter.timeStyle = .short
//
//        let timeString = timeFormatter.string(from: bottle.firstDoseTime)
//        return "\(timeString) Today"
//    }
//
//    private var lastTakenText: String {
//        guard let last = bottle.lastTakenAt else {
//            return "—"
//        }
//
//        let timeFormatter = DateFormatter()
//        timeFormatter.timeStyle = .short
//
//        if Calendar.current.isDateInToday(last) {
//            return "\(timeFormatter.string(from: last)) Today"
//        } else if Calendar.current.isDateInYesterday(last) {
//            return "\(timeFormatter.string(from: last)) Yesterday"
//        } else {
//            let dateFormatter = DateFormatter()
//            dateFormatter.dateStyle = .short
//            dateFormatter.timeStyle = .short
//            return dateFormatter.string(from: last)
//        }
//    }
//}

//
//  PillDoseInfoView.swift
//  Pillarity
//

import SwiftUI
import SwiftData

struct PillDoseInfoView: View {
    let bottle: PillBottle

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {

            // Next dose
            HStack(spacing: 8) {
                Image(systemName: "clock")
                    .foregroundColor(.secondary)
                Text("Next dose:")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text(nextDoseText)
                    .font(.subheadline)
            }

            // Last taken
            HStack(spacing: 8) {
                Image(systemName: "waveform.path.ecg")
                    .foregroundColor(.secondary)
                Text("Last taken:")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text(lastTakenText)
                    .font(.subheadline)
            }
        }
    }

    // -------------------------------------------------------------
    // MARK: - NEXT DOSE CALCULATION
    // -------------------------------------------------------------

    private var nextDoseText: String {
        let now = Date()
        let calendar = Calendar.current

        let times: [Date] = doseTimesForFrequency()

        // find the first dose today that hasn't happened yet
        if let nextToday = times.first(where: { $0 > now }) {
            return "\(formatTime(nextToday)) Today"
        }

        // otherwise the next dose is the first one tomorrow
        if let first = times.first {
            let next = calendar.date(byAdding: .day, value: 1, to: first) ?? first
            return "\(formatTime(next)) Tomorrow"
        }

        return "—"
    }

    /// Returns the daily schedule of dose times depending on frequency.
    private func doseTimesForFrequency() -> [Date] {
        let calendar = Calendar.current
        let now = Date()
        let comps = calendar.dateComponents([.year, .month, .day], from: now)

        func time(_ hour: Int, _ minute: Int) -> Date {
            var c = comps
            c.hour = hour
            c.minute = minute
            return calendar.date(from: c) ?? now
        }

        switch bottle.frequency {
        case .onceDaily:
            // Use the configured firstDoseTime *today*
            var c = comps
            let stored = bottle.firstDoseTime
            c.hour = calendar.component(.hour, from: stored)
            c.minute = calendar.component(.minute, from: stored)
            return [calendar.date(from: c) ?? now]

        case .twiceDaily:
            // Fixed: 8:00 AM & 5:00 PM
            return [
                time(8, 0),
                time(17, 0)
            ]

        case .threeTimesDaily:
            // Fixed: 8:00 AM, 1:00 PM, 6:00 PM
            return [
                time(8, 0),
                time(13, 0),
                time(18, 0)
            ]
        }
    }

    private func formatTime(_ date: Date) -> String {
        let f = DateFormatter()
        f.timeStyle = .short
        return f.string(from: date)
    }

    // -------------------------------------------------------------
    // MARK: - LAST TAKEN
    // -------------------------------------------------------------

    private var lastTakenText: String {
        guard let last = bottle.lastTakenAt else {
            return "—"
        }

        let formatter = DateFormatter()
        formatter.timeStyle = .short

        if Calendar.current.isDateInToday(last) {
            return "\(formatter.string(from: last)) Today"
        }
        if Calendar.current.isDateInYesterday(last) {
            return "\(formatter.string(from: last)) Yesterday"
        }

        let df = DateFormatter()
        df.dateStyle = .short
        df.timeStyle = .short
        return df.string(from: last)
    }
}

