//
//  AppSession.swift
//  Pillarity
//
//  Created by Anmol Gupta on 11/18/25.
//

import Foundation
import SwiftData

final class AppSession: ObservableObject {
    @Published var currentUser: User? = nil
    @Published var isDarkModeEnabled: Bool = false
    @Published var debugModeEnabled: Bool = false
    func logout() {
        currentUser = nil
    }
}
