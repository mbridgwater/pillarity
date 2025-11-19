//
//  SafetyLockRow.swift
//  Pillarity
//
//  Created by Anmol Gupta on 11/19/25.
//

import SwiftUI
import SwiftData

struct SafetyLockRow: View {
    @Bindable var bottle: PillBottle

    var body: some View {
        HStack {
            Image(systemName: "lock")
                .foregroundColor(.secondary)
            Text("Safety Lock")
                .font(.subheadline)
            Spacer()
            Toggle("", isOn: $bottle.safetyLockEnabled)
                .labelsHidden()
        }
    }
}
