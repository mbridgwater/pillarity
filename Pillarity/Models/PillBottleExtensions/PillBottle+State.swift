//
//  PillBottle+State.swift
//  Pillarity
//
//  Created by Anmol Gupta on 11/19/25.
//

import Foundation

extension PillBottle {

    /// How many times per day this med is scheduled.
    var dosesPerDay: Int {
        switch frequency {
        case .onceDaily:       return 1
        case .twiceDaily:      return 2
        case .threeTimesDaily: return 3
        }
    }

    /// Total doses per day (freq × dosageAmount).
    var totalDailyDoses: Int {
        dosageAmount * dosesPerDay
    }

    /// Scheduled dose times for a specific calendar day.
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
            let hour   = calendar.component(.hour,   from: firstDoseTime)
            let minute = calendar.component(.minute, from: firstDoseTime)
            return [makeTime(hour: hour, minute: minute)].compactMap { $0 }

        case .twiceDaily:
            return [
                makeTime(hour: 8,  minute: 0),
                makeTime(hour: 17, minute: 0)
            ].compactMap { $0 }

        case .threeTimesDaily:
            return [
                makeTime(hour: 8,  minute: 0),
                makeTime(hour: 13, minute: 0),
                makeTime(hour: 18, minute: 0)
            ].compactMap { $0 }
        }
    }

    /// Next scheduled dose time from `now` forwards.
    func nextDoseDate(after now: Date = Date()) -> Date? {
        let calendar = Calendar.current

        // 1. remaining times today
        let todayTimes = doseTimes(on: now).filter { $0 >= now }
        if let earliestToday = todayTimes.min() {
            return earliestToday
        }

        // 2. otherwise first time tomorrow
        guard let tomorrow = calendar.date(byAdding: .day, value: 1, to: now) else {
            return nil
        }
        return doseTimes(on: tomorrow).min()
    }
}
