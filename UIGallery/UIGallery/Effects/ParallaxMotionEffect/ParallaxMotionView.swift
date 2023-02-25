import SwiftUI

struct ParallaxMotionView: View {
    @ObservedObject var manager = MotionManager()
        
        var body: some View {
            ZStack {
                Rectangle()
                    .frame(width: 240, height: 240)
                    .foregroundColor(.yellow)
                    .cornerRadius(15)
                    .scaleEffect(1.2)
                    .modifier(ParallaxMotionModifier(manager: manager, magnitude: 10))
                
                Rectangle()
                    .frame(width: 240, height: 240)
                    .foregroundColor(.orange)
                    .cornerRadius(15)
                    .scaleEffect(1.0)
                    .modifier(ParallaxMotionModifier(manager: manager, magnitude: 10))
                
                Rectangle()
                    .frame(width: 240, height: 240)
                    .foregroundColor(.red)
                    .cornerRadius(15)
                    .scaleEffect(0.8)
                    .modifier(ParallaxMotionModifier(manager: manager, magnitude: 10))
                
                Rectangle()
                    .frame(width: 240, height: 240)
                    .foregroundColor(.purple)
                    .cornerRadius(15)
                    .scaleEffect(0.6)
                    .modifier(ParallaxMotionModifier(manager: manager, magnitude: 10))
                
                Rectangle()
                    .frame(width: 240, height: 240)
                    .foregroundColor(.blue)
                    .cornerRadius(15)
                    .scaleEffect(0.4)
                    .modifier(ParallaxMotionModifier(manager: manager, magnitude: 10))
                
                Rectangle()
                    .frame(width: 240, height: 240)
                    .foregroundColor(.green)
                    .cornerRadius(15)
                    .scaleEffect(0.2)
                    .modifier(ParallaxMotionModifier(manager: manager, magnitude: 10))
            }
        }
}

struct ParallaxMotionView_Previews: PreviewProvider {
    static var previews: some View {
        ParallaxMotionView()
    }
}
