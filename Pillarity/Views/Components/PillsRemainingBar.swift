//
//  PillsRemainingBar.swift
//  Pillarity
//
//  Created by Anmol Gupta on 11/19/25.
//

import SwiftUI

struct PillsRemainingBar: View {
    let current: Int
    let total: Int

    private var progress: Double {
        guard total > 0 else { return 0 }
        return min(max(Double(current) / Double(total), 0), 1)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("Pills Remaining")
                    .font(.subheadline)
                Spacer()
                Text("\(current)/\(total)")
                    .font(.subheadline)
            }

            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color(.systemGray5))
                    .frame(height: 6)

                Capsule()
                    .fill(Color.black)
                    .frame(width: nil, height: 6)
                    .frame(
                        maxWidth: .infinity,
                        alignment: .leading
                    )
                    .mask(
                        GeometryReader { geo in
                            Rectangle()
                                .frame(width: geo.size.width * progress)
                        }
                    )
            }
        }
    }
}
