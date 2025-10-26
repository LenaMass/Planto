import SwiftUI

// NOTE: This file assumes PlantReminder, ReminderStore, customDarkGray, and cyncolor
// are defined elsewhere in your project (as you shared).

// MARK: - ADD Reminder Sheet

struct ReminderSheetView: View {
    
    // Controls first-run flow from MainPage
    @Binding var isFirstTimeUser: Bool
    
    // Shared store (Bindable for SwiftUI Observation)
    @Bindable var store: ReminderStore

    // State properties for the selected values (defaults for new reminder)
    @State private var plantName: String = "Pothos"
    @State private var selectedRoom: String = "Bedroom"
    @State private var selectedLight: String = "Partial sun"
    @State private var selectedWateringDays: String = "Once a week"
    @State private var selectedWaterAmount: String = "20-50 ml"
    
    // Picker options (same as your current sheet)
    private let reminders = (
        rooms: ["Living Room", "Bedroom", "Kitchen", "Balcony", "Bathroom"],
        lights: ["Full sun", "Partial sun", "Shade"],
        wateringDays: ["Every day", "Every 2 days", "Every 3 days", "Once a week", "Every 10 days", "Every 2 weeks"],
        waterAmounts: ["10-20 ml", "20-50 ml", "50-100 ml", "200-300 ml"]
    )
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            List {
                // MARK: - Plant Name
                Section {
                    HStack(spacing: 20) {
                        Text("Plant Name")
                            .foregroundColor(.white)
                            .fontWeight(.semibold)
                        
                        TextField("Enter Name", text: $plantName)
                            .foregroundColor(.white.opacity(0.8))
                            .textInputAutocapitalization(.words)
                            .multilineTextAlignment(.trailing)
                    }
                    .frame(minHeight: 44)
                }
                .listRowBackground(Color.customDarkGray)
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 10, leading: 20, bottom: 0, trailing: 20))
                
                // MARK: - Room & Light
                Section {
                    HStack {
                        Image(systemName: "paperplane")
                        Text("Room")
                        Spacer()
                        Menu {
                            ForEach(reminders.rooms, id: \.self) { room in
                                Button(room) { selectedRoom = room }
                            }
                        } label: {
                            HStack {
                                Text(selectedRoom)
                                Image(systemName: "chevron.right").font(.caption)
                            }
                            .foregroundColor(.gray)
                        }
                    }
                    
                    HStack {
                        Image(systemName: "sun.max")
                        Text("Light")
                        Spacer()
                        Menu {
                            ForEach(reminders.lights, id: \.self) { light in
                                Button(light) { selectedLight = light }
                            }
                        } label: {
                            HStack {
                                Text(selectedLight)
                                Image(systemName: "chevron.right").font(.caption)
                            }
                            .foregroundColor(.gray)
                        }
                    }
                }
                .listRowBackground(Color.customDarkGray)
                
                // MARK: - Watering
                Section {
                    HStack {
                        Image(systemName: "drop")
                        Text("Watering Days")
                        Spacer()
                        Menu {
                            ForEach(reminders.wateringDays, id: \.self) { days in
                                Button(days) { selectedWateringDays = days }
                            }
                        } label: {
                            HStack {
                                Text(selectedWateringDays)
                                Image(systemName: "chevron.right").font(.caption)
                            }
                            .foregroundColor(.gray)
                        }
                    }
                    
                    HStack {
                        Image(systemName: "drop")
                        Text("Water Amount")
                        Spacer()
                        Menu {
                            ForEach(reminders.waterAmounts, id: \.self) { amount in
                                Button(amount) { selectedWaterAmount = amount }
                            }
                        } label: {
                            HStack {
                                Text(selectedWaterAmount)
                                Image(systemName: "chevron.right").font(.caption)
                            }
                            .foregroundColor(.gray)
                        }
                    }
                }
                .listRowBackground(Color.customDarkGray)
            }
            .background(Color.customDarkGray.edgesIgnoringSafeArea(.all))
            .listStyle(.insetGrouped)
            .navigationTitle("Set Reminder")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(.white)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        // Create the new reminder
                        var name = plantName.trimmingCharacters(in: .whitespacesAndNewlines)
                        if name.isEmpty { name = "Untitled Plant" }
                        let newReminder = PlantReminder(
                            plantName: name,
                            room: selectedRoom,
                            light: selectedLight,
                            wateringDays: selectedWateringDays,
                            waterAmount: selectedWaterAmount
                        )
                        // Save
                        store.add(reminder: newReminder)
                        // Leave first-time flow
                        isFirstTimeUser = false
                        // Dismiss
                        dismiss()
                    } label: {
                        Image(systemName: "checkmark")
                            .foregroundColor(.white)
                    }
                    .buttonStyle(.borderedProminent).tint(Color.cyncolor)
                    .disabled(plantName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}

// MARK: - EDIT Reminder Sheet (merged here)

struct EditReminderView: View {
    @Environment(\.dismiss) private var dismiss
    
    // We pass the store so we can write back the update
    @Bindable var store: ReminderStore
    
    // Local editable draft initialized from the provided reminder
    @State private var draft: PlantReminder
    
    // Picker options (kept identical to add sheet for consistency)
    private let rooms = ["Living Room", "Bedroom", "Kitchen", "Balcony", "Bathroom"]
    private let lights = ["Full sun", "Partial sun", "Shade"]
    private let wateringDays = ["Every day", "Every 2 days", "Every 3 days", "Once a week", "Every 10 days", "Every 2 weeks"]
    private let waterAmounts = ["10-20 ml", "20-50 ml", "50-100 ml", "200-300 ml"]
    
    // Convenience init to seed the draft
    init(reminder: PlantReminder, store: ReminderStore) {
        _draft = State(initialValue: reminder)
        self.store = store
    }
    
    var body: some View {
        NavigationView {
            List {
                // MARK: - Plant Name
                Section {
                    HStack(spacing: 20) {
                        Text("Plant Name")
                            .foregroundColor(.white)
                            .fontWeight(.semibold)
                        
                        TextField("Enter Name", text: $draft.plantName)
                            .foregroundColor(.white.opacity(0.9))
                            .textInputAutocapitalization(.words)
                            .multilineTextAlignment(.trailing)
                    }
                    .frame(minHeight: 44)
                }
                .listRowBackground(Color.customDarkGray)
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 10, leading: 20, bottom: 0, trailing: 20))
                
                // MARK: - Room & Light
                Section {
                    HStack {
                        Image(systemName: "paperplane")
                        Text("Room")
                        Spacer()
                        Menu {
                            ForEach(rooms, id: \.self) { room in
                                Button(room) { draft.room = room }
                            }
                        } label: {
                            HStack {
                                Text(draft.room)
                                Image(systemName: "chevron.right").font(.caption)
                            }
                            .foregroundColor(.gray)
                        }
                    }
                    
                    HStack {
                        Image(systemName: "sun.max")
                        Text("Light")
                        Spacer()
                        Menu {
                            ForEach(lights, id: \.self) { light in
                                Button(light) { draft.light = light }
                            }
                        } label: {
                            HStack {
                                Text(draft.light)
                                Image(systemName: "chevron.right").font(.caption)
                            }
                            .foregroundColor(.gray)
                        }
                    }
                }
                .listRowBackground(Color.customDarkGray)
                
                // MARK: - Watering
                Section {
                    HStack {
                        Image(systemName: "drop")
                        Text("Watering Days")
                        Spacer()
                        Menu {
                            ForEach(wateringDays, id: \.self) { days in
                                Button(days) { draft.wateringDays = days }
                            }
                        } label: {
                            HStack {
                                Text(draft.wateringDays)
                                Image(systemName: "chevron.right").font(.caption)
                            }
                            .foregroundColor(.gray)
                        }
                    }
                    
                    HStack {
                        Image(systemName: "drop")
                        Text("Water Amount")
                        Spacer()
                        Menu {
                            ForEach(waterAmounts, id: \.self) { amount in
                                Button(amount) { draft.waterAmount = amount }
                            }
                        } label: {
                            HStack {
                                Text(draft.waterAmount)
                                Image(systemName: "chevron.right").font(.caption)
                            }
                            .foregroundColor(.gray)
                        }
                    }
                }
                .listRowBackground(Color.customDarkGray)
            }
            .background(Color.customDarkGray.edgesIgnoringSafeArea(.all))
            .listStyle(.insetGrouped)
            .navigationTitle("Edit Reminder")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(.white)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        // Sanitize name
                        var updated = draft
                        if updated.plantName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            updated.plantName = "Untitled Plant"
                        }
                        // Write back to the store by ID (no need to add a new method)
                        if let idx = store.reminders.firstIndex(where: { $0.id == updated.id }) {
                            store.reminders[idx] = updated
                            // keep newest-first sort if you want that behavior on edits
                            store.reminders.sort { $0.createdAt > $1.createdAt }
                        }
                        dismiss()
                    } label: {
                        Image(systemName: "checkmark")
                            .foregroundColor(.white)
                    }
                    .buttonStyle(.borderedProminent).tint(Color.cyncolor)
                }
            }
        }
    }
}

