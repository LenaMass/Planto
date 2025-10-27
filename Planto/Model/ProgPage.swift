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

// --- Info Tag View ---
struct InfoTagView: View {
    let iconName: String
    let text: String
    var accentColor: Color?
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: iconName)
            Text(text)
        }
        .font(.caption)
        .foregroundColor(accentColor ?? Color(.systemGray2))
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(Color.white.opacity(0.1))
        .cornerRadius(8)
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

        HStack(spacing: 10) {
            // Cyan checkbox (leading)
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

                HStack(spacing: 8) {
                    InfoTagView(iconName: "sun.max", text: reminder.light, accentColor: Color("light-color"))
                    InfoTagView(iconName: "drop", text: reminder.waterAmount, accentColor: Color("water-color"))
                }
                .font(.footnote)
                .foregroundColor(.gray)
            }

            Spacer(minLength: 0)
        }
        .padding(.vertical, 10)
        .background(RoundedRectangle(cornerRadius: 12).fill(Color.clear))
        .saturation(saturation)
        .opacity(dimOpacity)
        .animation(.easeInOut(duration: 0.25), value: isChecked)
        // IMPORTANT: no extra insets; List content margins control the left edge
        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden) // we draw our own divider for alignment
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
        .padding(.horizontal, 20) // shared content margin
        .padding(.vertical, 15)
    }
}

// --- Main View ---
struct ProgPage: View {
    @Bindable var store: ReminderStore
    @Binding var isShowingSheet: Bool
    @State private var completedCount: Int = 0

    // Selected reminder for editing via swipe
    @State private var editingReminder: PlantReminder? = nil

    private let contentMargin: CGFloat = 20 // shared with header & list

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
                        VStack (spacing: 15) {
                            Spacer().frame(height: 100)
                            Image("Celb")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 300, height: 300)
                            Text("All done! 🎉")
                                .font(.title)
                                .offset(y: -80)
                            Text("All reminders Completed ")
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 20)
                                .foregroundColor(Color.gray)
                                .offset(y: -80)
                            Spacer()
                        }
                        Spacer()
                    }
                } else {
                    VStack(spacing: 0) {
                        // Title
                        HStack {
                            Text("My Plants 🌱")
                                .font(.largeTitle.bold())
                                .foregroundColor(.white)
                                .padding(.leading, contentMargin)
                            Spacer(minLength: 0)
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
                                    // enumerate to draw divider only between rows
                                    ForEach(Array(store.reminders.enumerated()), id: \.element.id) { idx, reminder in
                                        PlantRowView(reminder: reminder) { isChecked in
                                            if isChecked { completedCount += 1 } else { completedCount -= 1 }
                                            completedCount = max(0, completedCount)
                                        }
                                        // LEADING SWIPE TO EDIT (left -> right), no full swipe to avoid checkbox conflict
                                        .swipeActions(edge: .leading, allowsFullSwipe: false) {
                                            Button {
                                                editingReminder = reminder
                                            } label: {
                                                Label {
                                                    Text("Edit")
                                                } icon: {
                                                    Image(systemName: "pencil")
                                                }
                                            }
                                            .tint(.cyncolor)
                                        }
                                        // Custom divider aligned with the same left/right margins
                                        .overlay(alignment: .bottomLeading) {
                                            if idx < store.reminders.count - 1 {
                                                Rectangle()
                                                    .fill(Color.white.opacity(0.18))
                                                    .frame(height: 0.5)                  // 0.5pt line (no UIScreen.main)
                                                    .padding(.leading, contentMargin)    // start at same x as progress bar / checkbox
                                                    .padding(.trailing, contentMargin)   // end at same right margin
                                            }
                                        }
                                    }
                                    .onDelete { indexSet in store.delete(at: indexSet) }
                                }
                            }
                        }
                        .listStyle(.plain)
                        .scrollContentBackground(.hidden)
                        .background(Color.black)
                        // iOS 17+: unify side margins for the whole list
                        .modifier(HorizontalContentMarginsIfAvailable(contentMargin))
                        // iOS 16 and earlier fallback: apply same horizontal padding to list content
                        .modifier(HorizontalListPaddingIfOldiOS(contentMargin))
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
        // give space for the FAB without adding a giant row gap
        .safeAreaInset(edge: .bottom) {
            Color.clear.frame(height: 70)
        }
        // EDIT SHEET for the selected row
        .sheet(item: $editingReminder) { r in
            EditReminderView(reminder: r, store: store)
        }
    }
}

// Helpers to apply consistent horizontal margins on all iOS versions
private struct HorizontalContentMarginsIfAvailable: ViewModifier {
    let value: CGFloat
    init(_ value: CGFloat) { self.value = value }
    func body(content: Content) -> some View {
        if #available(iOS 17.0, *) {
            content.contentMargins(.horizontal, value)
        } else {
            content
        }
    }
}

private struct HorizontalListPaddingIfOldiOS: ViewModifier {
    let value: CGFloat
    init(_ value: CGFloat) { self.value = value }
    func body(content: Content) -> some View {
        if #available(iOS 17.0, *) {
            content
        } else {
            // Pad the whole list so the checkbox aligns with the progress bar
            content.padding(.horizontal, value)
        }
    }
}

