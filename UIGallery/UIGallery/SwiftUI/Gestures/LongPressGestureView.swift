import SwiftUI

struct LongPressGestureView: View {
    @GestureState var isLongPressed = false
    @State var isPressed = false
    
    var body: some View {
        let longPressGesture = LongPressGesture()
            .updating($isLongPressed) { value, state, transcation in
                print(value, state, transcation)
                state = value
            }
            .onEnded { (value) in
                withAnimation(.spring()) {
                    isPressed.toggle()
                }
            }
        
        Circle()
            .fill(Color.purple)
            .frame(width: 240, height: 240)
            .gesture(longPressGesture)
            .scaleEffect(isPressed ? 1.4 : 1)
    }
}

struct LongPressGestureView_Previews: PreviewProvider {
    static var previews: some View {
        LongPressGestureView()
    }
}
