import SwiftUI

struct ExclusiveGestureView: View {
    @State var degree = 0.0
    @State var isDay = false
    
    var body: some View {
        let tapGesture = TapGesture(count: 1)
            .onEnded { _ in
                withAnimation {
                    isDay.toggle()
                }
            }
        
        let rotationGesture = RotationGesture()
            .onChanged { angle in
                degree = angle.degrees
            }
        
        Image(systemName: isDay ? "sun.min" : "moon")
            .resizable()
            .foregroundColor(Color.yellow)
            .scaledToFill()
            .frame(width: 200, height: 200)
            .rotationEffect(Angle.degrees(degree))
            .gesture(tapGesture.exclusively(before: rotationGesture))
    }
}

struct ExclusiveGestureView_Previews: PreviewProvider {
    static var previews: some View {
        ExclusiveGestureView()
    }
}
