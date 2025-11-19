import SwiftUI
import SwiftData

@main
struct PillarityApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Pill.self,
            PillBottle.self,
            User.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    // Logged-in user session
    @StateObject private var session = AppSession()

    var body: some Scene {
        WindowGroup {
            RootView()
                .modelContainer(sharedModelContainer)
                .environmentObject(session)
        }
    }
}
