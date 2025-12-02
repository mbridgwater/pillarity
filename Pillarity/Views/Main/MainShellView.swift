//
//  MainShellView.swift
//  Pillarity
//
//  Created by Anmol Gupta on 11/18/25.
//

import SwiftUI
import SwiftData

enum MainTab {
    case home
    case analytics
    case settings
}

struct MainShellView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var session: AppSession

    @State private var selectedTab: MainTab = .home

    var body: some View {
        VStack(spacing: 0) {
            // --- HEADER ---
            AppHeaderView()
                .padding(.horizontal)
                .padding(.top, 8)
                .padding(.bottom, 4)

            Divider()

            // --- MAIN CONTENT (switches with tab) ---
            ZStack {
                switch selectedTab {
                case .home:
                    if let user = session.currentUser {
                        HomeView(currentUser: user)
                    } else {
                        Text("No user logged in")
                    }
                case .analytics:
                    AnalyticsView()
                case .settings:
                    if let user = session.currentUser {
                        SettingsView(user: user)
                    } else {
                        Text("No user logged in")
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemGroupedBackground))

            Divider()

            // --- FOOTER TAB BAR ---
            AppTabBar(selectedTab: $selectedTab)
                .padding(.horizontal)
                .padding(.top, 6)
                .padding(.bottom, 10)
                .background(.ultraThinMaterial)
        }
        .ignoresSafeArea(edges: [.bottom])
    }
}
