import SwiftUI
import Combine

// --- Supporting Views ---

struct PlantRowView: View {
    var reminder: PlantReminder
    var onToggle: (Bool) -> Void
    @State private var isChecked: Bool = false

    var body: some View {
        HStack {
            // Checkbox
            Button(action: {
                isChecked.toggle()
                onToggle(isChecked)
            }) {
                Image(systemName: isChecked ? "circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(isChecked ? .cyncolor : .white)
            }
            .padding(.trailing, 10)

            VStack(alignment: .leading, spacing: 5) {
                // Room and Name
                HStack {
                    Image(systemName: "paperplane").font(.caption)
                    Text("in \(reminder.room)").font(.caption)
                }
                .foregroundColor(.gray)

                Text(reminder.plantName)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .strikethrough(isChecked)

                // Details (Light and Water)
                HStack(spacing: 15) {
                    HStack { Image(systemName: "sun.max"); Text(reminder.light) }
                    HStack { Image(systemName: "drop");    Text("\(reminder.waterAmount)") }
                }
                .font(.footnote)
                .foregroundColor(.gray)
            }
            Spacer()
        }
        .padding(.vertical, 15)
        .padding(.horizontal)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.customDarkGray)
        )
        .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
        .contentShape(Rectangle()) // make the whole row tappable
    }
}

struct ProgressHeaderView: View {
    var completionProgress: Double
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Daily Progress")
                .font(.headline)
                .foregroundColor(.white)

            ProgressView(value: completionProgress)
                .progressViewStyle(.linear)
                .tint(.cyncolor)
                .scaleEffect(x: 1, y: 3, anchor: .center)
                .background(Color.customDarkGray)
                .cornerRadius(5)
        }
        .padding(.horizontal, 25)
        .padding(.vertical, 15)
        .background(Color.black)
    }
}

// --- Main View ---

struct ProgPage: View {

    @Bindable var store: ReminderStore
    @Binding var isShowingSheet: Bool

    @State private var completedCount: Int = 0
    @State private var editingReminder: PlantReminder? = nil   // <- for edit sheet

    var completionProgress: Double {
        guard !store.reminders.isEmpty else { return 0 }
        return Double(completedCount) / Double(store.reminders.count)
    }

    var isGoalCompleted: Bool {
        !store.reminders.isEmpty && completionProgress >= 1.0
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if isGoalCompleted {
                // Completion UI
                VStack {
                    Spacer()
                    VStack {
                        Image("Celb")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 300, height: 300)

                        Text("All Plants Cared For! 🎉")
                            .font(.largeTitle.bold())
                            .foregroundColor(.white)
                            .padding(.top, 20)

                        Text("Tap the '+' button to start a new batch of reminders.")
                            .foregroundColor(.white.opacity(0.7))
                            .font(.subheadline)
                            .padding(.top, 10)
                    }
                    Spacer()
                }
            } else {
                // Header + Progress
                VStack(spacing: 0) {
                    HStack {
                        Text("My Plants 🌱")
                            .font(.largeTitle.bold())
                            .foregroundColor(.white)
                            .padding(.leading, 25)
                        Spacer()
                    }
                    .padding(.top, 50)
                    .padding(.bottom, 10)
                    .background(Color.black)

                    ProgressHeaderView(completionProgress: completionProgress)

                    // --- Native List with swipe-to-delete + tap-to-edit ---
                    List {
                        if store.reminders.isEmpty {
                            Section {
                                VStack(spacing: 12) {
                                    ContentUnavailableView(
                                        "No Reminders Set",
                                        systemImage: "drop",
                                        description: Text("Add a new plant reminder using the + tab.")
                                    )
                                    .foregroundColor(.gray)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 60)
                                }
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                            }
                        } else {
                            Section {
                                ForEach(store.reminders) { reminder in
                                    PlantRowView(reminder: reminder) { isChecked in
                                        if isChecked { completedCount += 1 } else { completedCount -= 1 }
                                        completedCount = max(0, completedCount)
                                    }
                                    .padding(.horizontal, 25)
                                    // <- tap to edit this reminder
                                    .onTapGesture {
                                        editingReminder = reminder
                                    }
                                }
                                // Native swipe-to-delete
                                .onDelete { indexSet in
                                    store.delete(at: indexSet)
                                }

                                // breathing room above the FAB
                                Color.clear
                                    .frame(height: 100)
                                    .listRowBackground(Color.clear)
                                    .listRowSeparator(.hidden)
                            }
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                    .background(Color.black)
                }
                // Edit button for bulk delete (native iOS behavior)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        EditButton()
                    }
                }
            }
        }
        // FAB using safeAreaInset so it won’t interfere with swipes
        .safeAreaInset(edge: .bottom) {
            HStack {
                Spacer()
                Button(action: {
                    if isGoalCompleted {
                        store.clearAllReminders()
                        completedCount = 0
                    }
                    isShowingSheet = true
                }) {
                    Image(systemName: "plus")
                        .font(.title2.bold())
                        .foregroundColor(.white)
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 100)
                                .fill(Color.cyncolor)
                        )
                        .frame(width: 60, height: 60)
                        .shadow(radius: 5)
                }
                .padding(.trailing, 25)
            }
            .padding(.bottom, 20)
            .background(.clear)
        }
        // Present edit sheet when a row is tapped
        .sheet(item: $editingReminder) { reminder in
            EditReminderView(reminder: reminder, store: store)
                .presentationDetents([.medium, .large])
        }
    }
}

