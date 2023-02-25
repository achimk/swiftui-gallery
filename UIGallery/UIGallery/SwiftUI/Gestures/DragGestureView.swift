import SwiftUI

struct DragGestureView: View {
    @Environment(\.colorScheme) var colorScheme
    @State var offset: CGSize = .zero
    
    var body: some View {
        let dragGesture = DragGesture()
            .onChanged { (value) in
                print(value.startLocation, value.location, value.translation)
                self.offset = value.translation
            }
            .onEnded { (value) in
                if(abs(value.translation.width) >= 40 || abs(value.translation.height - (-260)) >= 40) {
                    self.offset = .zero
                } else {
                    self.offset = CGSize(width: 0, height: -260)
                }
            }
        
        VStack {
            Circle()
                .fill(colorScheme == .dark ? Color.white : Color.black)
                .opacity(0.1)
                .frame(width: 200, height: 200)
                .offset(CGSize(width: 0, height: -50))
            
            withAnimation(.spring()) {
                Circle()
                    .fill(Color.purple)
                    .frame(width: 200, height: 200)
                    .offset(offset)
                    .gesture(dragGesture)
            }
        }
        
    }
}

struct DragGestureView_Previews: PreviewProvider {
    static var previews: some View {
        DragGestureView()
    }
}
