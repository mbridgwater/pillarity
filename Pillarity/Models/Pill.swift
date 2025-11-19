//
//  Pill.swift
//  Pillarity
//
//  Created by Anmol Gupta on 11/18/25.
//

import Foundation
import SwiftData

@Model
final class Pill {
    var name: String
    var calibratedWeight: Float
    var timestamp: Date

    init(name: String, calibratedWeight: Float, timestamp: Date = .now) {
        self.name = name
        self.calibratedWeight = calibratedWeight
        self.timestamp = timestamp
    }
}
