import UserNotifications

final class NotificationManager {
    static let shared = NotificationManager()
    static let sessionCompleteCategory = "SESSION_COMPLETE"
    static let logActionIdentifier = "LOG_ACTION"

    private init() {}

    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            if let error = error {
                print("Notification permission error: \(error)")
            }
        }

        let logAction = UNNotificationAction(
            identifier: Self.logActionIdentifier,
            title: "Log What You Did",
            options: .foreground
        )
        let category = UNNotificationCategory(
            identifier: Self.sessionCompleteCategory,
            actions: [logAction],
            intentIdentifiers: []
        )
        UNUserNotificationCenter.current().setNotificationCategories([category])
    }

    func sendSessionCompleteNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Focus Session Complete!"
        content.body = "Great work! Tap to log what you accomplished."
        content.sound = .default
        content.categoryIdentifier = Self.sessionCompleteCategory

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )

        UNUserNotificationCenter.current().add(request)
    }
}
