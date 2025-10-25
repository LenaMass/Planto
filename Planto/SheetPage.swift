import SwiftUI

// NOTE: This file assumes PlantReminder, ReminderStore, customDarkGray, and cyncolor
// are defined in DataStore.swift.

struct ReminderSheetView: View {
    
    // NEW: Binding to control the main app's flow
    @Binding var isFirstTimeUser: Bool
    
    // REINSTATED: The store is needed to save the new reminder
    @Bindable var store: ReminderStore

    // State properties for the selected values
    @State private var plantName: String = "Pothos"
    @State private var selectedRoom: String = "Bedroom"
    @State private var selectedLight: String = "Partial sun"
    @State private var selectedWateringDays: String = "Once a week"
    @State private var selectedWaterAmount: String = "20-50 ml"
    

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
                // MARK: - Plant Name Section
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
                
                // MARK: - Room and Light Section
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
                
                // MARK: - Watering Section
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
                            .glassEffect(.regular.tint(.clear).interactive())
                        
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        // 1. Create the new PlantReminder object
                        let newReminder = PlantReminder(
                            plantName: plantName.isEmpty ? "Untitled Plant" : plantName,
                            room: selectedRoom,
                            light: selectedLight,
                            wateringDays: selectedWateringDays,
                            waterAmount: selectedWaterAmount
                        )
                        
                        // 2. Save it to the shared store
                        store.add(reminder: newReminder)
                        
                        // 3. Mark the app as initialized, which automatically transitions to ProgPage
                        // This achieves the desired transition from the dummy page.
                        isFirstTimeUser = false
                        
                        // 4. Dismiss the sheet
                        dismiss()
                    } label: {
                        Image(systemName: "checkmark")
                            .foregroundColor(.white)
                    }
                    .buttonStyle(.borderedProminent).tint(Color.cyncolor)
                    .disabled(plantName.isEmpty)
                }
            }
        }
    }
}

struct ReminderSheetView_Previews: PreviewProvider {
    static var previews: some View {
        // Mock the store and pass a constant binding for isFirstTimeUser
        ReminderSheetView(isFirstTimeUser: .constant(true), store: ReminderStore())
            .presentationDetents([.medium, .large])
    }
}
