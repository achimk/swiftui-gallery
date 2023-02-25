import SwiftUI

struct RotationGestureView: View {
    @State var degree = 0.0
    
    var body: some View {
        let rotationGesture = RotationGesture(minimumAngleDelta: Angle(degrees: 1))
            .onChanged { (angle) in
                degree = angle.degrees
            }
        
        Rectangle()
            .frame(width: 240, height: 240)
            .foregroundColor(.purple)
            .cornerRadius(10)
            .rotationEffect(Angle(degrees: degree))
            .gesture(rotationGesture)
            
    }
}

struct RotationGestureView_Previews: PreviewProvider {
    static var previews: some View {
        RotationGestureView()
    }
}
