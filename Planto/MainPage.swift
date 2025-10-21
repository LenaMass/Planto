import SwiftUI
struct MainPage: View {

    let customFontSize: CGFloat = 20
    let lineColor = Color.gray
    let lineHeight: CGFloat = 0.5
    let headerTopPadding: CGFloat = 55
    
    // State for modal presentation
    @State private var isShowingSheet = false
    
    // ⭐️ State for Navigation
    @State private var isNavigatingToProg = false
    
    var body: some View {
        // ⭐️ Use NavigationStack for hierarchical navigation
        NavigationStack {
            
            ZStack {
                // Apply the app-wide background color here (e.g., system black for dark mode)
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 10) {
                    
                    Spacer().frame(height: 100)
                    
                    // NOTE: 'Image("Face1")' requires an asset named "Face1" in your Assets.xcassets
                    Image("Face1")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 200, height: 200)
                    
                    Text("Start your plant journey!")
                        .font(.title)
                        .offset(y: 20)
                    
                    Text("Now all your plants will be in one place and we will help you take care of them :) 🪴")
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                        .foregroundColor(lineColor)
                        .offset(y: 20)
                    
                    Spacer()
                    
                    Button(action: {
                        print("Set plant reminder button tapped")
                        // Toggles the sheet to open
                        isShowingSheet = true
                    }){
                        Text("Set Plant Reminder")
                            
                            .font(.system(size: customFontSize, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.vertical)
                            .padding(.horizontal,80)
                            .glassEffect()
                            .background(Color.cyncolor)
                            .cornerRadius(30)
                            
                            
                   
                    }
                    .offset(y:-200)
                }
                
            }
            // ⭐️ Navigation Destination based on state
            .navigationDestination(isPresented: $isNavigatingToProg) {
                ProgPage()
            }
        }
        // ⭐️ The .sheet modifier is attached here, providing a closure to handle success
        .sheet(isPresented: $isShowingSheet){
            // Pass a closure to the sheet that runs when the checkmark is pressed
            ReminderSheetView(onSave: {
                // This code runs AFTER the sheet is dismissed (in ReminderSheetView)
                isNavigatingToProg = true // Trigger navigation to ProgPage
            })
            .presentationDetents([.medium, .large])
        }
    }
}




struct MainPage_Previews: PreviewProvider {
    static var previews: some View {
        MainPage()
    }
}
