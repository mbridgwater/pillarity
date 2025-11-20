//
//  PillTimeOfDayBadges.swift
//  Pillarity
//
//  Created by Anmol Gupta on 11/19/25.
//

import SwiftUI
import SwiftData

enum TimeOfDay: String, CaseIterable, Identifiable {
    case morning
    case afternoon
    case evening
    case night

    var id: String { rawValue }

    var label: String {
        switch self {
        case .morning:   return "Morning"
        case .afternoon: return "Afternoon"
        case .evening:   return "Evening"
        case .night:     return "Night"
        }
    }

    var systemImage: String {
        switch self {
        case .morning:   return "sunrise.fill"
        case .afternoon: return "sun.max.fill"
        case .evening:   return "sunset.fill"
        case .night:     return "moon.stars.fill"
        }
    }
}

struct TimeOfDayBadge: View {
    let timeOfDay: TimeOfDay

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: timeOfDay.systemImage)
                .font(.caption2)
            Text(timeOfDay.label)
                .font(.caption)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 4)
        .background(Color(.systemGray6))
        .cornerRadius(14)
    }
}
//
//extension PillBottle {
//
//    // Map the firstDoseTime into a TimeOfDay bucket.
//    private var firstDoseSlot: TimeOfDay {
//        let hour = Calendar.current.component(.hour, from: firstDoseTime)
//
//        switch hour {
//        case 5..<12:      // 5:00–11:59
//            return .morning
//        case 12..<17:     // 12:00–16:59
//            return .afternoon
//        case 17..<21:     // 17:00–20:59
//            return .evening
//        default:          // 21:00–4:59
//            return .night
//        }
//    }
//
//    // Time-of-day badges based on firstDoseTime + frequency.
//    var timeOfDayBadges: [TimeOfDay] {
//        switch frequency {
//        case .onceDaily:
//            return [firstDoseSlot]
//
//        case .twiceDaily:
//            // Morning + Evening
//            return [.morning, .evening]
//
//        case .threeTimesDaily:
//            // Morning, Afternoon, Evening
//            return [.morning, .afternoon, .evening]
//        }
//    }
//}
