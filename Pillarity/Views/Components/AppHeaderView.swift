//
//  AppHeaderView.swift
//  Pillarity
//
//  Created by Anmol Gupta on 11/18/25.
//

import SwiftUI

struct AppHeaderView: View {
    var body: some View {
        HStack(spacing: 12) {
            Image("PillarityLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 32, height: 32)
                .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 2) {
                Text("Pillarity")
                    .font(.headline)
            }

            Spacer()

            Button {
                // TODO: open notifications sheet later
            } label: {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: "bell")
                        .font(.system(size: 20, weight: .regular))
                    Circle()
                        .fill(Color.red)
                        .frame(width: 8, height: 8)
                        .offset(x: 6, y: -4)
                }
            }
            .foregroundColor(.black)
        }
    }
}
