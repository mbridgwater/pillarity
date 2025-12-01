//
//  RootView.swift
//  Pillarity
//
//  Created by Anmol Gupta on 11/18/25.
//

import SwiftUI
import SwiftData

struct RootView: View {
    @EnvironmentObject var session: AppSession

    var body: some View {
        if let _ = session.currentUser {
            MainShellView()
        } else {
            AuthRootView()
        }
    }
}

////
////  RootView.swift
////  Pillarity
////
//
//import SwiftUI
//import SwiftData
//
//struct RootView: View {
//    @EnvironmentObject var session: AppSession
//    @Environment(\.modelContext) private var modelContext
//
//    @State private var hasLoadedDemo = false
//
//    var body: some View {
//        Group {
//            if let _ = session.currentUser {
//                MainShellView()
//            } else {
//                AuthRootView()
//            }
//        }
//        .task {
//            await loadDemoUserIfNeeded()
//        }
//    }
//
//    private func loadDemoUserIfNeeded() async {
//        // Prevent running twice
//        guard !hasLoadedDemo else { return }
//        hasLoadedDemo = true
//
//        do {
//            try DemoUserFactory.createDemoUserIfNeeded(modelContext: modelContext)
//        } catch {
//            print("Error creating demo user: \(error)")
//        }
//    }
//}
