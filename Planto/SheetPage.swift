import SwiftUI

struct ReminderSheetView: View {
    let onSave: () -> Void 
    @State private var plantName: String = "Pothos"
    @State private var selectedRoom: String = "Bedroom"
    @State private var selectedLight: String = "Full sun"
    @State private var selectedWateringDays: String = "Every day"
    @State private var selectedWaterAmount: String = "20-50 ml"
    

    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            
            List {
                
                Section {
                    HStack(spacing: 20) {
                        
                        Text("Plant Name")
                            .foregroundColor(.white)
                            .fontWeight(.semibold)
                            .offset(y: -3)
                        
                        TextField(plantName, text: $plantName)
                            .foregroundColor(.gray)
                            .textInputAutocapitalization(.words)
                            .offset(y: -3)
                            .offset(x: -10)

                        
                    }
                    .frame(minHeight: 44)
                }
                .listRowBackground(Color.customDarkGray)
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 10, leading: 20, bottom: 0, trailing: 20))

                Section {
                    HStack {
                        Image(systemName: "paperplane.fill")
                        Text("Room")
                        Spacer()
                        Menu {
                            Button("Living Room") { selectedRoom = "Living Room" }
                            Button("Bedroom") { selectedRoom = "Bedroom" }
                            Button("Kitchen") { selectedRoom = "Kitchen" }
                        } label: {
                            HStack {
                                Text(selectedRoom)
                                Image(systemName: "chevron.right").font(.caption)
                            }
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                        }
                    }

                    HStack {
                        Image(systemName: "sun.max.fill")
                        Text("Light")
                        Spacer()
                        Menu {
                            Button("Full sun") { selectedLight = "Full sun" }
                            Button("Partial sun") { selectedLight = "Partial sun" }
                            Button("Shade") { selectedLight = "Shade" }
                        } label: {
                            HStack {
                                Text(selectedLight)
                                Image(systemName: "chevron.right").font(.caption)
                            }
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                        }
                    }
                }
                .listRowBackground(Color.customDarkGray)

                Section {
                    HStack {
                        Image(systemName: "drop.fill")
                        Text("Watering Days")
                        Spacer()
                        Menu {
                            Button("Every day") { selectedWateringDays = "Every day" }
                            Button("Every 2 days") { selectedWateringDays = "Every 2 days" }
                            Button("Once a week") { selectedWateringDays = "Once a week" }
                        } label: {
                            HStack {
                                Text(selectedWateringDays)
                                Image(systemName: "chevron.right").font(.caption)
                            }
                            .foregroundColor(.gray)
                        }
                        .listRowBackground(Color.customDarkGray)
                    }

                    HStack {
                        Image(systemName: "drop.fill")
                        Text("Water")
                        Spacer()
                        Menu {
                            Button("10-20 ml") { selectedWaterAmount = "10-20 ml" }
                            Button("20-50 ml") { selectedWaterAmount = "20-50 ml" }
                            Button("50-100 ml") { selectedWaterAmount = "50-100 ml" }
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
            //.scrollContentBackground(.hidden)
            .listStyle(.insetGrouped)
            .navigationTitle("Set Reminder")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white)
                            .padding(8)

                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        print("Reminder saved for \(plantName)!")
                        onSave()
                        dismiss()
                    } label: {
                        Image(systemName: "checkmark")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white)
                            .padding(8)
                        

                    }
                    .buttonStyle(.borderedProminent).tint(Color.cyncolor)
                        
                }
          
            }
        }
    }
}

struct ReminderSheetView_Previews: PreviewProvider {
    static var previews: some View {
        ReminderSheetView(onSave: {})
        .presentationDetents([.medium, .large])
    }
}
