import SwiftUI

// NOTE: Assumes PlantReminder, ReminderStore, Color.customDarkGray, and Color.cyncolor exist.

struct EditReminderView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var store: ReminderStore

    // Make a local draft to edit without mutating the store until Save
    @State private var draft: PlantReminder

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
                            ForEach(ReminderOptions.rooms, id: \.self) { room in
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
                            ForEach(ReminderOptions.lights, id: \.self) { light in
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
                            ForEach(ReminderOptions.wateringDays, id: \.self) { days in
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
                            ForEach(ReminderOptions.waterAmounts, id: \.self) { amount in
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
                        Image(systemName: "xmark").foregroundColor(.white)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        var updated = draft
                        if updated.plantName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            updated.plantName = "Untitled Plant"
                        }
                        if let idx = store.reminders.firstIndex(where: { $0.id == updated.id }) {
                            store.reminders[idx] = updated
                            // Optional: keep newest-first
                            store.reminders.sort { $0.createdAt > $1.createdAt }
                        }
                        dismiss()
                    } label: {
                        Image(systemName: "checkmark").foregroundColor(.white)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Color.cyncolor)
                }
            }
        }
    }
}

