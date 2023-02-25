import SwiftUI

struct DoubleTapGestureView: View {
    @State var isPressed = false
    
    var body: some View {
        Circle()
            .fill(Color.purple)
            .frame(width: 240, height: 240)
            .scaleEffect(isPressed ? 1.4 : 1)
            .onTapGesture(count: 2) {
                withAnimation {
                    isPressed.toggle()
                }
            }
    }
    
}

struct DoubleTapGestureView_Previews: PreviewProvider {
    static var previews: some View {
        DoubleTapGestureView()
    }
}
