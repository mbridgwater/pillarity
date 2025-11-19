//
//  PillBottleCard.swift
//  Pillarity
//
//  Created by Anmol Gupta on 11/18/25.
//

import SwiftUI
import SwiftData

struct PillBottleCard: View {
    let bottle: PillBottle

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Medication name
            Text(bottle.type.name)
                .font(.headline)

            // Pills remaining (just the count for now)
            Text("Pills in this bottle: \(bottle.pillCount)")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(.separator), lineWidth: 0.5)
        )
    }
}
