//
//  User.swift
//  Pillarity
//
//  Created by Anmol Gupta on 11/18/25.
//

import Foundation
import SwiftData

enum AccountType: String, Codable, CaseIterable {
    case patient = "Patient"
    case caregiver = "Caregiver"
}

@Model
final class User {
    var name: String
    var email: String
    var password: String
    var accountType: AccountType
    var createdAt: Date

    var pillBottles: [PillBottle] = []

    init(name: String,
         email: String,
         password: String,
         accountType: AccountType,
         createdAt: Date = .now)
    {
        self.name = name
        self.email = email
        self.password = password
        self.accountType = accountType
        self.createdAt = createdAt
    }
}
