//
//  PillBottle.swift
//  Pillarity
//
//  Created by Anmol Gupta on 11/18/25.
//

import Foundation
import SwiftData

@Model
final class PillBottle {
    @Relationship var type: Pill
    var pillCount: Int
    var timestamp: Date

    init(type: Pill, pillCount: Int, timestamp: Date = .now) {
        self.type = type
        self.pillCount = pillCount
        self.timestamp = timestamp
    }
}
