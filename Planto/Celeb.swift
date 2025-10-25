import SwiftUI
struct Celeb: View {
    
    @State private var isShowingSheet = false
    
    var body: some View {
        NavigationStack {
            
            VStack(spacing: 0) {
                
                Image("Celb")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 300, height: 300)
                
            }
        }
    }
}
