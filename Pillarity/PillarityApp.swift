//
//  PillarityApp.swift
//  Pillarity
//
//  Created by Missy Bridgwater on 11/11/25.
//

import SwiftUI
import SwiftData

@main
struct PillarityApp: App {
    // This block sets up SwiftData’s local database
    var sharedModelContainer: ModelContainer = {
        // Defines which data models (SwiftData entities) exist in your app
        let schema = Schema([
            Item.self,
        ])
        // Tells SwiftData to persist the data to disk (not just in memory).
        // If true, data would reset when you close the app
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            // This creates the actual persistent store (like your database file). If it fails, fatalError stops the app
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        // WindowGroup → defines your app’s main window (the screen users see).
        WindowGroup {
            // Inside it, SwiftUI loads your ContentView — that’s the root UI of the app.
            NavigationStack {
                ConnectScaleView()
            }
        }
        .modelContainer(sharedModelContainer)
    }
}
