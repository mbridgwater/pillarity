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
    var type: Pill
    var owner: User?
    var pillCount: Int
    var timestamp: Date

    init(type: Pill,
         pillCount: Int,
         timestamp: Date = .now,
         owner: User? = nil) {
        self.type = type
        self.pillCount = pillCount
        self.timestamp = timestamp
        self.owner = owner
    }
}
