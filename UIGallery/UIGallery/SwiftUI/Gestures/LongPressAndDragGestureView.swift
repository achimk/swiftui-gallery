import SwiftUI

struct LongPressAndDragGestureView: View {
    @Environment(\.colorScheme) var colorScheme
    @State var offset: CGSize = .zero
    @GestureState var isLongPressed = false
    
    var body: some View {
        let longPressGesture = LongPressGesture()
            .updating($isLongPressed) { value, state, transcation in
                print(value, state, transcation)
                state = value
            }
            .onEnded { (value) in
                print(value)
            }
        
        let dragGesture = DragGesture()
            .onChanged { (value) in
                print(value.startLocation, value.location, value.translation)
                offset = value.translation
            }
            .onEnded { (value) in
                if(abs(value.translation.width) >= 40 || abs(value.translation.height - (-260)) >= 40) {
                    offset = .zero
                } else {
                    offset = CGSize(width: 0, height: -260)
                }
            }
            .simultaneously(with: longPressGesture)
        
        return VStack{
            Circle()
                .fill(colorScheme == .dark ? Color.white : Color.black)
                .opacity(0.1)
                .frame(width: 200, height: 200)
                .offset(CGSize(width: 0, height: -50))
            
            Circle()
                .fill(Color.purple)
                .frame(width: 200, height: 200)
                .offset(offset)
                .gesture(dragGesture)
                .scaleEffect(isLongPressed ? 1.4 : 1)
        }
        
    }
}

struct LongPressAndDrapGestureView_Previews: PreviewProvider {
    static var previews: some View {
        LongPressAndDragGestureView()
    }
}
