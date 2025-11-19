//
//  AppTabBar.swift
//  Pillarity
//
//  Created by Anmol Gupta on 11/18/25.
//

import SwiftUI

struct AppTabBar: View {
    @Binding var selectedTab: MainTab

    var body: some View {
        HStack(spacing: 24) {
            tabButton(
                tab: .home,
                icon: "house",
                title: "Home"
            )

            tabButton(
                tab: .analytics,
                icon: "chart.bar",
                title: "Analytics"
            )

            tabButton(
                tab: .settings,
                icon: "gearshape",
                title: "Settings"
            )
        }
        .padding(.vertical, 6)
    }

    @ViewBuilder
    private func tabButton(tab: MainTab, icon: String, title: String) -> some View {
        let isSelected = selectedTab == tab

        Button {
            selectedTab = tab
        } label: {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                Text(title)
                    .font(.footnote)
            }
            .foregroundColor(isSelected ? .black : Color(.systemGray))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(
                Group {
                    if isSelected {
                        RoundedRectangle(cornerRadius: 18)
                            .fill(Color.white)
                            .shadow(color: .black.opacity(0.08), radius: 8, y: 3)
                    } else {
                        Color.clear
                    }
                }
            )
        }
        .buttonStyle(.plain)
    }
}
