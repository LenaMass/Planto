import SwiftUI

struct StartPage: View {

    let customFontSize: CGFloat = 20
    let lineHeight: CGFloat = 0.5
    let headerTopPadding: CGFloat = 55

    @State private var store = ReminderStore()
    @State private var isFirstTimeUser: Bool = true
    @State private var isShowingSheet = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                if isFirstTimeUser {
                    VStack(spacing: 15) {
                        
                        Spacer().frame(height: 100)
                        
                        Image("Face1")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 200, height: 200)
                        
                        Text("Start your plant journey!")
                            .font(.title)
                            .foregroundColor(.white)
                            .offset(y: 20)
                        
                        Text("Now all your plants will be in one place and we will help you take care of them :) 🪴")
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                            .foregroundColor(Color.gray)
                            .offset(y: 20)
                        
                        Spacer()
                        
                        Button(action: {
                            print("Set plant reminder button tapped")
                            isShowingSheet = true
                        }){
                            Text("Set Plant Reminder")
                                .font(.system(size: customFontSize, weight: .semibold, design: .rounded))
                                .foregroundColor(.white)
                                .padding(.vertical)
                                .padding(.horizontal,80)
                             //   .glassEffect(.clear)
                                .glassEffect(.regular.tint(.cyncolor).interactive())
                                .cornerRadius(30)
                        }
                        .offset(y:-200)
                    }
                } else {
                    ProgPage(store: store, isShowingSheet: $isShowingSheet)
                }
            }
            .sheet(isPresented: $isShowingSheet){
                ReminderSheetView(isFirstTimeUser: $isFirstTimeUser, store: store)
                    .presentationDetents([.large, .large])
            }
        }
    }
}

#Preview
{
    StartPage()
}


