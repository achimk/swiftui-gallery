import SwiftUI

struct TapGestureView: View {
    @State var isPressed = false
    
    var body: some View {
        Circle()
            .fill(Color.purple)
            .frame(width: 240, height: 240)
            .scaleEffect(isPressed ? 1.4 : 1)
            .onTapGesture {
                withAnimation {
                    isPressed.toggle()
                }
            }
    }
}

struct TapGestureView_Previews: PreviewProvider {
    static var previews: some View {
        TapGestureView()
    }
}
