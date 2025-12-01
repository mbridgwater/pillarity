import Foundation
import UserNotifications

final class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {

    static let shared = NotificationDelegate()

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completion: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo

        if let id = userInfo["bottleID"] as? String {
            NotificationCenter.default.post(
                name: Notification.Name("OpenDoseView"),
                object: id
            )
        }

        completion()
    }
}
