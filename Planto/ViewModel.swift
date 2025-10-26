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
    
    
    var reminders: [PlantReminder] = []
    
    func add(reminder: PlantReminder) {
        reminders.append(reminder)
        // Sorts the reminders by the newest one first
        reminders.sort { $0.createdAt > $1.createdAt }
    }
    
    func clearAllReminders() {
        self.reminders.removeAll()
    }
    
    // ReminderStore.swift
    func delete(at offsets: IndexSet) {
        reminders.remove(atOffsets: offsets)
    }
    func delete(id: UUID) {
        reminders.removeAll { $0.id == id }
    }

    
    // ReminderStore.swift
    func update(reminder: PlantReminder) {
        if let idx = reminders.firstIndex(where: { $0.id == reminder.id }) {
            reminders[idx] = reminder
            // keep your newest-first sort if you want it to re-order after edits
            reminders.sort { $0.createdAt > $1.createdAt }
        }
    }
}
