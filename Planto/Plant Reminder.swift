import SwiftUI
import Combine

struct PlantReminder: Identifiable {
    let id = UUID()
    var plantName: String
    var room: String
    var light: String
    var wateringDays: String
    var waterAmount: String
    var createdAt = Date()
}

@Observable
class ReminderStore { // ⭐️ REMOVED : ObservableObject
    
    // ⭐️ FIX: Initialize with an empty array. The previous code
    // added a placeholder item that interfered with list count and clearing.
    var reminders: [PlantReminder] = []

    func add(reminder: PlantReminder) {
        reminders.append(reminder)
        // Sorts the reminders by the newest one first
        reminders.sort { $0.createdAt > $1.createdAt }
    }

    func clearAllReminders() {
        self.reminders.removeAll()
    }
}
