import SwiftUI

struct RotationGestureView: View {
    @State var angle = 0.0
    
    var body: some View {
        let rotationGesture = RotationGesture(minimumAngleDelta: Angle.init(degrees: 20))
            .onChanged({ (angle) in
                self.angle += angle.animatableData
            }).onEnded { (angle) in
                print(self.angle)
            }
        
        Rectangle()
            .frame(width: 240, height: 240)
            .foregroundColor(.purple)
            .cornerRadius(10)
            .gesture(rotationGesture)
            .rotationEffect(Angle(degrees: angle))
    }
}

struct RotationGestureView_Previews: PreviewProvider {
    static var previews: some View {
        RotationGestureView()
    }
}
