//
//  PillBottle+TimeOfDay.swift
//  Pillarity
//
//  Created by Anmol Gupta on 11/19/25.
//

import Foundation

extension PillBottle {

    // Slot for firstDoseTime
    private var firstDoseSlot: TimeOfDay {
        let hour = Calendar.current.component(.hour, from: firstDoseTime)

        switch hour {
        case 5..<12:   return .morning
        case 12..<17:  return .afternoon
        case 17..<21:  return .evening
        default:       return .night
        }
    }

    /// Badges used in the card UI.
    var timeOfDayBadges: [TimeOfDay] {
        switch frequency {
        case .onceDaily:
            return [firstDoseSlot]

        case .twiceDaily:
            return [.morning, .evening]

        case .threeTimesDaily:
            return [.morning, .afternoon, .evening]
        }
    }
}
