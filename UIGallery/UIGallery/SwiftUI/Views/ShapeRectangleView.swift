import SwiftUI

struct ShapeRectangleView: View {
    var body: some View {
        ScrollView {
            VStack{
                Rectangle()
                Rectangle()
                    .fill(Color.orange)
                    .frame(width: 200, height: 200)
                
                ZStack {
                    Rectangle().fill(Color.purple)
                        .frame(width: 300, height: 200)
                    
                    Rectangle().fill(Color.yellow)
                        .frame(width: 300, height: 200)
                        .scaleEffect(0.8)
                    
                    Rectangle()
                        .fill(Color.orange)
                        .frame(width: 300, height: 200)
                        .scaleEffect(0.6)
                }
                
                RoundedRectangle(cornerRadius: 120)
                
                RoundedRectangle(cornerSize: CGSize(width: 100, height: 40)).frame(width: 300, height: 200)
                
                RoundedRectangle(cornerRadius: 100, style: RoundedCornerStyle.continuous)
            }
        }
    }
}

struct ShapeRectangleView_Previews: PreviewProvider {
    static var previews: some View {
        ShapeRectangleView()
    }
}
