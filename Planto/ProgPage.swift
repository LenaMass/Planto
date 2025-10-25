import SwiftUI


struct PlantRowView: View {
    let reminder: PlantReminder
    var onToggle: (Bool) -> Void
    
    @State private var isWateredToday: Bool = false
    
    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            Button {
                isWateredToday.toggle()
                onToggle(isWateredToday)
            } label: {
                Image(systemName: isWateredToday ? "checkmark.circle.fill" : "circle")
                    .resizable()
                    .frame(width: 24, height: 24)
                    .foregroundColor(.cyncolor)
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 5) {
                HStack(spacing: 4) {
                    Image(systemName: "paperplane")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                    Text("in \(reminder.room)")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                }
                
                Text(reminder.plantName)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.bottom, 5)
                
                HStack(spacing: 15) {
                    HStack(spacing: 4) {
                        Image(systemName: "sun.max")
                        Text(reminder.light)
                    }
                    HStack(spacing: 4) {
                        Image(systemName: "drop")
                        Text(reminder.waterAmount)
                    }
                }
                .font(.caption)
                .padding(.vertical, 5)
                .padding(.horizontal, 8)
                .background(Color.black.opacity(0.5))
                .clipShape(Capsule())
                .foregroundColor(.white.opacity(0.8))
            }
            Spacer()
        }
        .padding(.vertical, 8)
        .padding(.leading, 5)
    }
}

// ---------------------------------------------------------------- //

struct ProgPage: View {
    
    @Bindable var store: ReminderStore
    @Binding var isShowingSheet: Bool
    
    @State private var completedCount: Int = 0
    
    var completionProgress: Double {
        guard !store.reminders.isEmpty else { return 0 }
        // FIX: The progress count needs to be adjusted because you removed the placeholder
        // Check if the store is empty before calculating progress
        let validReminderCount = store.reminders.count
        return Double(completedCount) / Double(validReminderCount)
    }
    
    // ⭐️ NEW: Logic to check if the goal is met
    var isGoalCompleted: Bool {
        // Only true if there are reminders AND progress is 100%
        !store.reminders.isEmpty && completionProgress >= 1.0
    }
    
    var body: some View {
        // 1. ZStack layers the button over the content
        ZStack(alignment: .bottomTrailing) {
            
            NavigationView {
                // ⭐️ CONDITIONAL VIEW LOGIC
                if isGoalCompleted {
                    // --- Completion UI (Your Requested Image Screen) ---
                    VStack {
                        Spacer()
                        
                        // Your requested image view
                        VStack {
                            Image("Celb") // Make sure "Celb" is in your Assets
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 300, height: 300)
                            

                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        
                        Spacer()
                    }
                    // Apply background here for the whole content when complete
                    .background(Color.black.ignoresSafeArea())

                } else {
                    // --- Standard Progress and List UI ---
                    VStack(spacing: 0) {
                        
                        // Progress Bar View
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Daily Progress")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            ProgressView(value: completionProgress)
                                .progressViewStyle(LinearProgressViewStyle(tint: .cyncolor))
                                .scaleEffect(x: 1, y: 3, anchor: .center)
                                .background(Color.customDarkGray)
                                .cornerRadius(5)
                        }
                        .padding(.horizontal, 25)
                        .padding(.vertical, 15)
                        .background(Color.black)
                        
                        List {
                            if store.reminders.isEmpty {
                                // You can put a message here for an empty list
                                Text("No reminders yet. Tap '+' to add your first plant!")
                                    .foregroundColor(.white.opacity(0.7))
                                    .listRowBackground(Color.black)
                            } else {
                                ForEach(store.reminders) { reminder in
                                    PlantRowView(reminder: reminder) { isChecked in
                                        if isChecked { completedCount += 1 } else { completedCount -= 1 }
                                        completedCount = max(0, completedCount)
                                        print("Completed: \(completedCount) / Total: \(store.reminders.count)")
                                    }
                                    .listRowBackground(
                                        RoundedRectangle(cornerRadius: 15)
                                            .fill(Color.black.opacity(0.8))
                                            .padding(.vertical, 4)
                                    )
                                    .listRowInsets(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
                                    .listRowSeparator(.hidden)
                                }
                            }
                        }
                        .listStyle(.plain)
                        .background(Color.black.ignoresSafeArea()) // Apply background to list
                    }
                }
            }
            .navigationTitle("My Plants 🌱")
            // To ensure the navigation bar color is set consistently
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)


            // 2. Floating Action Button (FAB) - Fixed Logic
            Button(action: {
                if isGoalCompleted {
                    // 1. Clear the old reminders
                    store.clearAllReminders()
                    completedCount = 0
                }
                // 2. Always show the sheet to add a new reminder
                isShowingSheet = true
            }) {
                ZStack {
                    Image(systemName: "plus")
                        .font(.title2.bold())
                        .foregroundColor(.white)
                        .padding(20)
                }
                .background(
                    RoundedRectangle(cornerRadius: 100)
                        .fill(Color.cyncolor)
                        // Using a standard material for glass effect compatibility
                        .glassEffect(.regular.tint(.cyncolor).interactive())
                )
                .frame(width: 60, height: 60)
                .shadow(radius: 5)
            }
            .padding(.trailing, 25)
            .padding(.bottom, 20)
        }
    }
}

struct ProgPageWrapper: View {
    // FIX: Using @StateObject is correct for a class conforming to ObservableObject
    @State private var mockStore = ReminderStore()
    @State private var isSheetPresented = false
    
    init() {
        // Initial mock data setup
        // The mock data will now be the *only* data since the store starts empty.
        mockStore.add(reminder: PlantReminder(plantName: "Monstera Deliciosa", room: "Kitchen", light: "Partial sun", wateringDays: "Every 7 days", waterAmount: "50-100 ml"))
        mockStore.add(reminder: PlantReminder(plantName: "Pothos Golden", room: "Bedroom", light: "Shade", wateringDays: "Every 10 days", waterAmount: "20-50 ml"))
        mockStore.add(reminder: PlantReminder(plantName: "ZZ Plant", room: "Office", light: "Low light", wateringDays: "Every 14 days", waterAmount: "100-150 ml"))
    }
    
    var body: some View {
        ProgPage(store: mockStore, isShowingSheet: $isSheetPresented)
    }
}

#Preview {
    ProgPageWrapper()
}
