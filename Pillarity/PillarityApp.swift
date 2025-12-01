import SwiftUI
import SwiftData
import UserNotifications

@main
struct PillarityApp: App {

    init() {
        UNUserNotificationCenter.current().delegate = NotificationDelegate.shared
        DoseNotificationManager.shared.requestNotifications()
    }

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
