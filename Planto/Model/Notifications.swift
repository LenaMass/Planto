import Foundation
import UserNotifications

/// Central place to manage all local notifications for PlantReminder items.
struct NotificationManager {

    // MARK: - Authorization

    /// Ask once for notification permission (safe to call multiple times).
    static func requestAuthorizationIfNeeded() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            guard settings.authorizationStatus == .notDetermined else { return }
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                if let error = error {
                    print("Notification authorization error: \(error.localizedDescription)")
                } else {
                    print("Notification authorization granted? \(granted)")
                }
            }
        }
    }

    // MARK: - Scheduling / Canceling single reminders

    /// Schedule a local notification for a specific reminder.
    /// This uses a best-effort mapping to a time interval. Customize `secondsUntilNextWater` to your data model.
    static func scheduleNotification(for reminder: PlantReminder) {
        let content = UNMutableNotificationContent()
        content.title = "Planto"
        content.body  = "Hey! let’s water \(reminder.plantName)"
        content.sound = .default

        // Compute the next trigger time.
        var interval = secondsUntilNextWater(for: reminder)

        #if DEBUG
        // Make simulator testing easy: fire after 10 seconds in Debug builds.
        interval = 5
        #endif

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: max(5, interval), repeats: false)

        // Use the reminder's UUID so you can update/cancel reliably.
        let identifier = reminder.id.uuidString
        let request   = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            } else {
                print("Scheduled notification for \(reminder.plantName) (id: \(identifier)).")
            }
        }
    }

    /// Cancel a pending notification for a reminder.
    static func cancelNotification(for reminder: PlantReminder) {
        let identifier = reminder.id.uuidString
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
        print("Canceled notification for \(reminder.plantName) (id: \(identifier)).")
    }

    // MARK: - Bulk helpers

    /// Convenience: re-schedule notifications for a whole list. Call this after saving/closing the sheet.
    static func scheduleAll(for reminders: [PlantReminder]) {
        for reminder in reminders {
            scheduleNotification(for: reminder)
        }
    }

    // MARK: - Mapping helper (customize for your app)

    /// Map your reminder's data to a delay. Adjust to match your fields.
    /// If you store:
    ///  - `intervalDays: Int` -> return TimeInterval(intervalDays * 86400)
    ///  - `nextWaterDate: Date` -> return max(5, nextWaterDate.timeIntervalSinceNow)
    ///  - an enum schedule -> switch over cases to return appropriate seconds
    private static func secondsUntilNextWater(for reminder: PlantReminder) -> TimeInterval {
        // Example mappings (uncomment the one that fits your model, and delete the rest):

        // 1) If you have an integer interval in days:
        // return TimeInterval(reminder.intervalDays * 24 * 60 * 60)

        // 2) If you store an absolute date:
        // if let next = reminder.nextWaterDate { return max(5, next.timeIntervalSinceNow) }

        // 3) If you have an enum like .everyDay / .every2Days / ...:
        // switch reminder.schedule {
        // case .everyDay:    return 1 * 24 * 60 * 60
        // case .every2Days:  return 2 * 24 * 60 * 60
        // case .every3Days:  return 3 * 24 * 60 * 60
        // case .onceAWeek:   return 7 * 24 * 60 * 60
        // case .every10Days: return 10 * 24 * 60 * 60
        // case .every2Weeks: return 14 * 24 * 60 * 60
        // }

        // Fallback: remind tomorrow.
        return 24 * 60 * 60
    }
}

