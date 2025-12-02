import Foundation
import UserNotifications
import SwiftData

@MainActor
final class DoseNotificationManager {

    static let shared = DoseNotificationManager()

    private init() {}

    // request permissions
    func requestNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { _, _ in }
    }

    // schedule notifications for each bottle
    func scheduleDailyDoseNotifications(for bottle: PillBottle) {

        let times = bottle.doseTimes(on: Date())// clear any existing notifications for this bottle
        print("DEBUG: Scheduling notifications for bottle:", bottle.type.name)
        print("DEBUG: Dose times returned =", times)
        print("DEBUG: Number of dose times =", times.count)
        print("DEBUG: Bottle identifier =", bottle.identifier.uuidString)
        

        let identifiers = times.indices.map { "\(bottle.identifier.uuidString)-\($0)" }
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)


        // Schedule a repeating daily notification at this dose time.
        // Extract the hour/minute, create a daily calendar trigger, and
        // register a unique notification request for this pill bottle.
        for (idx, time) in times.enumerated() {
            
            let fmt = DateFormatter()
            fmt.timeStyle = .short
            let doseTimeString = fmt.string(from: time)

            let content = UNMutableNotificationContent()
            content.title = "Time to take your \(bottle.type.name) pill!"
            content.body = "\(bottle.dosageAmount) pill\(bottle.dosageAmount == 1 ? "" : "s") • \(doseTimeString)"
            content.sound = .default
            content.userInfo = [
               "bottleID": bottle.identifier.uuidString
            ]

            // convert date to components
            var comps = Calendar.current.dateComponents([.hour, .minute], from: time)
            comps.timeZone = TimeZone.current

            let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: true)

            let request = UNNotificationRequest(
                identifier: "\(bottle.identifier.uuidString)-\(idx)",
                content: content,
                trigger: trigger
            )

            UNUserNotificationCenter.current().add(request)
        }
    }
}
