import SwiftUI
import SwiftData
import UserNotifications

@main
struct PillarityApp: App {

    init() {
        // Notifications
        UNUserNotificationCenter.current().delegate = NotificationDelegate.shared
        DoseNotificationManager.shared.requestNotifications()

        // Seed demo user on first launch
        seedDemoUserIfNeeded()
    }

    // Shared SwiftData container
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

    // MARK: - Demo user seeding
    private func seedDemoUserIfNeeded() {
        let context = ModelContext(sharedModelContainer)

        // 1) Check if demo user already exists
        let descriptor = FetchDescriptor<User>(
            predicate: #Predicate { $0.email == "missy@example.com" }
        )

        if let existing = try? context.fetch(descriptor),
           !existing.isEmpty {
            return  // already created
        }

        // 2) Create demo user
        let demoUser = User(
            name: "Demo User",
            email: "missy@example.com",
            password: "123",
            accountType: .patient
        )

        // Common values
        let calendar = Calendar.current
        let oneYearAgo = calendar.date(byAdding: .day, value: -365, to: Date()) ?? Date()
        let firstDoseTime = calendar.date(bySettingHour: 9, minute: 0, second: 0, of: Date()) ?? Date()

        // ---------------------------------------------------
        // BOTTLE 1 – Vitamin D (once daily)
        // ---------------------------------------------------
        let vitaminD = Pill(name: "Vitamin D", calibratedWeight: 0.5)

        let bottle1 = PillBottle(
            type: vitaminD,
            owner: demoUser,
            initialPillCount: 365,
            remainingPillCount: 365,
            createdAt: oneYearAgo,
            dosageAmount: 1,
            frequency: .onceDaily,
            firstDoseTime: firstDoseTime
        )

        bottle1.dailyLast7 = (0..<7).map { _ in Int.random(in: 0...1) }
        bottle1.weeklyLast4 = (0..<4).map { _ in Int.random(in: 3...7) }
        bottle1.monthlyLast12 = (0..<12).map { _ in Int.random(in: 10...30) }

        // ---------------------------------------------------
        // BOTTLE 2 – Adderall (twice daily)
        // ---------------------------------------------------
        let adderall = Pill(name: "Adderall", calibratedWeight: 0.3)

        let bottle2 = PillBottle(
            type: adderall,
            owner: demoUser,
            initialPillCount: 180,
            remainingPillCount: 180,
            createdAt: oneYearAgo,
            dosageAmount: 1,
            frequency: .twiceDaily,
            firstDoseTime: firstDoseTime
        )

        bottle2.dailyLast7 = (0..<7).map { _ in Int.random(in: 1...2) }
        bottle2.weeklyLast4 = (0..<4).map { _ in Int.random(in: 7...14) }
        bottle2.monthlyLast12 = (0..<12).map { _ in Int.random(in: 25...50) }

        // ---------------------------------------------------
        // BOTTLE 3 – Ibuprofen (three times daily)
        // ---------------------------------------------------
        let ibuprofen = Pill(name: "Ibuprofen", calibratedWeight: 0.4)

        let bottle3 = PillBottle(
            type: ibuprofen,
            owner: demoUser,
            initialPillCount: 270,
            remainingPillCount: 270,
            createdAt: oneYearAgo,
            dosageAmount: 1,
            frequency: .threeTimesDaily,
            firstDoseTime: firstDoseTime
        )

        bottle3.dailyLast7 = (0..<7).map { _ in Int.random(in: 1...3) }
        bottle3.weeklyLast4 = (0..<4).map { _ in Int.random(in: 10...20) }
        bottle3.monthlyLast12 = (0..<12).map { _ in Int.random(in: 30...70) }

        // Insert into SwiftData
        context.insert(demoUser)
        context.insert(vitaminD)
        context.insert(adderall)
        context.insert(ibuprofen)
        context.insert(bottle1)
        context.insert(bottle2)
        context.insert(bottle3)

        do {
            try context.save()
        } catch {
            print("DEBUG: Failed to seed demo data: \(error)")
        }
    }
}
