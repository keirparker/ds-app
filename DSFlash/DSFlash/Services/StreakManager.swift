import Foundation
import UserNotifications

enum StreakManager {

    // MARK: - Keys

    private static let lastStudyKey    = "dsflash_last_study_date"
    private static let streakKey       = "dsflash_streak_count"
    private static let todayKey        = "dsflash_cards_today"
    private static let goalKey         = "dsflash_daily_goal"
    private static let notifEnabledKey = "dsflash_notif_enabled"
    private static let notifHourKey    = "dsflash_notif_hour"
    private static let notifMinKey     = "dsflash_notif_min"
    private static let notifID         = "dsflash.daily.reminder"

    // MARK: - Public state

    static var dailyGoal: Int {
        get {
            let v = UserDefaults.standard.integer(forKey: goalKey)
            return v > 0 ? v : 20
        }
        set { UserDefaults.standard.set(newValue, forKey: goalKey) }
    }

    static var currentStreak: Int {
        UserDefaults.standard.integer(forKey: streakKey)
    }

    static var cardsStudiedToday: Int {
        UserDefaults.standard.integer(forKey: todayKey)
    }

    static var isGoalComplete: Bool {
        cardsStudiedToday >= dailyGoal
    }

    // MARK: - Recording

    /// Call once each time a card is rated (not skipped).
    static func recordCardStudied() {
        let defaults = UserDefaults.standard
        let cal = Calendar.current

        if let lastDate = defaults.object(forKey: lastStudyKey) as? Date {
            if cal.isDateInToday(lastDate) {
                // Same day — just increment today's count
                defaults.set(cardsStudiedToday + 1, forKey: todayKey)
                return
            }

            // New day — reset today count and update streak
            defaults.set(1, forKey: todayKey)
            defaults.set(Date.now, forKey: lastStudyKey)

            if cal.isDateInYesterday(lastDate) {
                defaults.set(currentStreak + 1, forKey: streakKey)
            } else {
                defaults.set(1, forKey: streakKey)  // streak broken
            }
        } else {
            // First ever study
            defaults.set(1, forKey: todayKey)
            defaults.set(Date.now, forKey: lastStudyKey)
            defaults.set(1, forKey: streakKey)
        }
    }

    // MARK: - Notifications

    @discardableResult
    static func requestPermission() async -> Bool {
        do {
            return try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .badge, .sound])
        } catch {
            return false
        }
    }

    static func scheduleNotification(hour: Int, minute: Int) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [notifID])

        let content = UNMutableNotificationContent()
        content.title = "Time to study 📚"
        content.body  = "You have cards due. Keep your streak alive!"
        content.sound = .default

        var components = DateComponents()
        components.hour   = hour
        components.minute = minute
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        center.add(UNNotificationRequest(identifier: notifID, content: content, trigger: trigger))

        UserDefaults.standard.set(true,   forKey: notifEnabledKey)
        UserDefaults.standard.set(hour,   forKey: notifHourKey)
        UserDefaults.standard.set(minute, forKey: notifMinKey)
    }

    static func cancelNotification() {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: [notifID])
        UserDefaults.standard.set(false, forKey: notifEnabledKey)
    }

    static var notificationsEnabled: Bool {
        UserDefaults.standard.bool(forKey: notifEnabledKey)
    }

    static var notificationHour: Int {
        let h = UserDefaults.standard.integer(forKey: notifHourKey)
        return h > 0 ? h : 9
    }

    static var notificationMinute: Int {
        UserDefaults.standard.integer(forKey: notifMinKey)
    }
}
