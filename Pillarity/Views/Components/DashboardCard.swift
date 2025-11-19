//
//  DashboardCard.swift
//  Pillarity
//
//  Created by Anmol Gupta on 11/19/25.
//

import SwiftUI
import SwiftData

struct DashboardCard: View {
    let title: String
    let value: String
    let subtitle: String
    let icon: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Spacer()
                Image(systemName: icon)
                    .foregroundColor(.gray)
            }

            Text(value)
                .font(.title.bold())

            Text(subtitle)
                .font(.footnote)
                .foregroundColor(.secondary)
        }
        .padding(18)
        .frame(maxWidth: .infinity)
        .background(Color(.systemGray6))
        .cornerRadius(18)
    }
}
