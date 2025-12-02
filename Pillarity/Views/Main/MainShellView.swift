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
    @State private var showDoseSheet = false
    @State private var bottleForDose: PillBottle?

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
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("OpenDoseView"))) { notif in
            if let id = notif.object as? String {
                if let bottle = findBottle(by: id) {
                    showDoseSheet = true
                    bottleForDose = bottle
                }
            }
        }
        .sheet(item: $bottleForDose) { bottle in
            TakeDoseView(bottle: bottle)
        }
    }

    private func findBottle(by id: String) -> PillBottle? {
        guard let uuid = UUID(uuidString: id) else { return nil }
        
        return try? modelContext.fetch(
            FetchDescriptor<PillBottle>(
                predicate: #Predicate { $0.identifier == uuid }
            )
        ).first
    }

}
