import SwiftUI
import SwiftData

@main
struct PillarityApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
            Pill.self,
            PillBottle.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema,
                                                    isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            HomeView()   // ← start on the medications list
                .tint(Color(red: 0xED/255, green: 0x32/255, blue: 0x82/255))
        }
        .modelContainer(sharedModelContainer)
    }
}
