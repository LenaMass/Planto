import SwiftUI

struct ReminderSheetView: View {
    @Binding var isFirstTimeUser: Bool
    @Bindable var store: ReminderStore

    // State for new reminder defaults
    @State private var plantName: String = ""
    @State private var selectedRoom: String = "Bedroom"
    @State private var selectedLight: String = "Partial sun"
    @State private var selectedWateringDays: String = "Once a week"
    @State private var selectedWaterAmount: String = "20-50 ml"

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            List {
                // MARK: - Plant Name
                Section {
                    TextField("Plant Name", text: $plantName)
                        .foregroundColor(.white.opacity(0.9))
                        .textInputAutocapitalization(.words)
                        .multilineTextAlignment(.leading)
                        .padding(.vertical, 8)
                }
                .listRowBackground(Color.customDarkGray)
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: -4, leading: 20, bottom: 0, trailing: 20))

                // MARK: - Room & Light
                Section {
                    HStack {
                        Image(systemName: "paperplane")
                        Text("Room")
                        Spacer()
                        Menu {
                            ForEach(ReminderOptions.rooms, id: \.self) { room in
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
                            ForEach(ReminderOptions.lights, id: \.self) { light in
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
                            ForEach(ReminderOptions.wateringDays, id: \.self) { days in
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
                            ForEach(ReminderOptions.waterAmounts, id: \.self) { amount in
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
                        Image(systemName: "xmark").foregroundColor(.white)
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        var name = plantName.trimmingCharacters(in: .whitespacesAndNewlines)
                        if name.isEmpty { name = "Untitled Plant" }

                        let newReminder = PlantReminder(
                            plantName: name,
                            room: selectedRoom,
                            light: selectedLight,
                            wateringDays: selectedWateringDays,
                            waterAmount: selectedWaterAmount
                        )

                        store.add(reminder: newReminder)
                        isFirstTimeUser = false
                        dismiss()
                    } label: {
                        Image(systemName: "checkmark").foregroundColor(.white)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Color.cyncolor)
                    .disabled(plantName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}

