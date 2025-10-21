import SwiftUI

struct ProgPage: View {
    
    let lineColor = Color.gray
    let lineHeight: CGFloat = 0.5
    let apptitle : String = "My Plants 🌱"
    let headerTopPadding: CGFloat = 0
    
  
    
    var body: some View {
        
        
        VStack(spacing: 0) {
            
            VStack(alignment: .leading, spacing: 10) {
                
                Spacer().frame(height: headerTopPadding)
                
                                
                Text(apptitle)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.horizontal, 20)
                    .foregroundColor(Color.white)
                
//                
//                Rectangle()
//                    .fill(lineColor)
//                    .frame(height: lineHeight)
//                    .padding(.top, 8)
//                
                

            }
            .frame(maxWidth: .infinity, alignment: .leading)
            Spacer()

            ZStack {
               

                
            }
           
        }
    }
}
#Preview {
    ProgPage()
}
