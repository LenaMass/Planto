import SwiftUI
import Combine

// --- Custom Thick Progress Bar (keeps your header spacing unchanged) ---
struct ThickProgressBar: View {
    var progress: Double
    var height: CGFloat = 16
    private var clamped: CGFloat { CGFloat(min(max(progress, 0), 1)) }

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: height / 2)
                    .fill(Color.customDarkGray)
                RoundedRectangle(cornerRadius: height / 2)
                    .fill(Color.cyncolor)
                    .frame(width: geo.size.width * clamped)
            }
        }
        .frame(height: height)
        .clipShape(RoundedRectangle(cornerRadius: height / 2))
    }
}

// --- Supporting Views ---
struct PlantRowView: View {
    var reminder: PlantReminder
    var onToggle: (Bool) -> Void
    @State private var isChecked: Bool = false

    var body: some View {
        // Graying out the card but keeping button cyan
        let dimOpacity: Double = isChecked ? 0.55 : 1.0
        let saturation: Double = isChecked ? 0.0  : 1.0

        HStack {
            // Cyan checkbox stays vivid
            Button(action: {
                withAnimation(.easeInOut(duration: 0.25)) {
                    isChecked.toggle()
                }
                onToggle(isChecked)
            }) {
                Image(systemName: isChecked ? "circle.fill" : "circle")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
                    .foregroundColor(.cyncolor)
            }
            .padding(.trailing, 10)

            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    Image(systemName: "paperplane").font(.caption)
                    Text("in \(reminder.room)").font(.caption)
                }
                .foregroundColor(.gray)

                Text(reminder.plantName)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .strikethrough(isChecked, color: .white.opacity(0.7))

                HStack(spacing: 15) {
                    HStack { Image(systemName: "sun.max"); Text(reminder.light) }
                    HStack { Image(systemName: "drop"); Text("\(reminder.waterAmount)") }
                }
                .font(.footnote)
                .foregroundColor(.gray)
            }
            Spacer()
        }
        .padding(.vertical, 15)
        .padding(.horizontal)
        .background(
            RoundedRectangle(cornerRadius: 15).fill(Color.customDarkGray)
        )
        // fade out content but keep cyan icon untouched
        .saturation(saturation)
        .opacity(dimOpacity)
        .animation(.easeInOut(duration: 0.25), value: isChecked)
        .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
    }
}

// --- Progress Header ---
struct ProgressHeaderView: View {
    var completionProgress: Double
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Daily Progress")
                .font(.headline)
                .foregroundColor(.white)
            ThickProgressBar(progress: completionProgress, height: 16)
                .background(Color.clear)
        }
        .padding(.horizontal, 25)
        .padding(.vertical, 15)
    }
}

// --- Edit Picker Sheet ---
private struct EditReminderPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var store: ReminderStore

    var body: some View {
        NavigationStack {
            Group {
                if store.reminders.isEmpty {
                    List {
                        Section {
                            ContentUnavailableView(
                                "No Reminders",
                                systemImage: "leaf"
                            )
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                        }
                    }
                    .scrollContentBackground(.hidden)
                    .background(Color.customDarkGray)
                } else {
                    List {
                        Section("Choose a reminder") {
                            ForEach(store.reminders) { r in
                                NavigationLink {
                                    EditReminderView(reminder: r, store: store)
                                } label: {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(r.plantName)
                                            .foregroundColor(.white)
                                            .fontWeight(.semibold)
                                        Text("in \(r.room) • \(r.light) • \(r.wateringDays) • \(r.waterAmount)")
                                            .font(.footnote)
                                            .foregroundColor(.gray)
                                    }
                                    .padding(.vertical, 4)
                                }
                                .listRowBackground(Color.customDarkGray)
                            }
                        }
                    }
                    .scrollContentBackground(.hidden)
                    .background(Color.customDarkGray)
                }
            }
            .navigationTitle("Edit Reminder")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.customDarkGray, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") { dismiss() }.foregroundColor(.white)
                }
            }
        }
    }
}

// --- Main View ---
struct ProgPage: View {
    @Bindable var store: ReminderStore
    @Binding var isShowingSheet: Bool
    @State private var completedCount: Int = 0
    @State private var isEditPickerPresented: Bool = false

    var completionProgress: Double {
        guard !store.reminders.isEmpty else { return 0 }
        return Double(completedCount) / Double(store.reminders.count)
    }

    var isGoalCompleted: Bool {
        !store.reminders.isEmpty && completionProgress >= 1.0
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            NavigationView {
                if isGoalCompleted {
                    VStack {
                        Spacer()
                        VStack {
                            Image("Celb")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 300, height: 300)
                            
                        }
                        Spacer()
                    }
//                    .background(Color.black.ignoresSafeArea())
//                    .navigationTitle("My Plants 🌱")
//                    .padding(.leading, 25)
                } else {
                    VStack(spacing: 0) {
                        // Title + Edit button header
                        HStack {
                            Text("My Plants 🌱")
                                .font(.largeTitle.bold())
                                .foregroundColor(.white)
                                .padding(.leading, 25)
                            Spacer()
                            Button("Edit") { isEditPickerPresented = true }
                                .foregroundColor(.white)
                                .padding(.trailing, 25)
                        }
                        .padding(.top, 50)
                        .padding(.bottom, 10)

                        ProgressHeaderView(completionProgress: completionProgress)

                        List {
                            if store.reminders.isEmpty {
                                Section {
                                    ContentUnavailableView("No Reminders Set",
                                        systemImage: "drop")
                                    .frame(maxWidth: .infinity)
                                    .padding(.top, 100)
                                    .foregroundColor(.gray)
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
                                        .padding(.vertical, 8)
                                    }
                                    .onDelete { indexSet in store.delete(at: indexSet) }

                                    Color.clear
                                        .frame(height: 90)
                                        .listRowBackground(Color.clear)
                                        .listRowSeparator(.hidden)
                                }
                            }
                        }
                        .listStyle(.plain)
                        .scrollContentBackground(.hidden)
                        .background(Color.black)
                    }
                    .navigationTitle("")
                    .toolbarBackground(.hidden, for: .navigationBar)
                    .ignoresSafeArea(.all, edges: .top)
                }
            }
            .toolbarColorScheme(.dark, for: .navigationBar)

            // FAB
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
                            .glassEffect(.regular.tint(.cyncolor).interactive())
                    )
                    .frame(width: 60, height: 60)
                    .shadow(radius: 5)
            }
            .padding(.trailing, 25)
            .padding(.bottom, 20)
        }
        .sheet(isPresented: $isEditPickerPresented) {
            EditReminderPickerView(store: store)
                .presentationDetents([.medium, .large])
        }
    }
}
