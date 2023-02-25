import SwiftUI

struct TapGestureView: View {
    @State var isPressed = false
    
    var body: some View {
        let tapGesture = TapGesture()
            .onEnded { _ in
                self.isPressed.toggle()
            }
        
        Circle()
            .fill(Color.purple)
            .frame(width: 240, height: 240)
            .gesture(tapGesture)
            .scaleEffect(isPressed ? 1.4 : 1)
    }
}

struct TapGestureView_Previews: PreviewProvider {
    static var previews: some View {
        TapGestureView()
    }
}
