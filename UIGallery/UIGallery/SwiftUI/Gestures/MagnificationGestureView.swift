import SwiftUI

struct MagnificationGestureView: View {
    @GestureState var scale: CGFloat = 1.0
    
    var body: some View {
        let magnificationGesture = MagnificationGesture()
            .updating($scale, body: { (value, scale, trans) in
                scale = value.magnitude
            })
            .onEnded { (value) in
                print(value)
            }
        
        Rectangle()
            .foregroundColor(Color.purple)
            .frame(width: 240, height: 240)
            .cornerRadius(15)
            .scaleEffect(scale)
            .gesture(magnificationGesture)
    }
}

struct MagnificationGestureView_Previews: PreviewProvider {
    static var previews: some View {
        MagnificationGestureView()
    }
}
