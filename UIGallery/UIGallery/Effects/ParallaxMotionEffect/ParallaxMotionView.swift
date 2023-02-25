import SwiftUI

struct ParallaxMotionView: View {
    @ObservedObject var manager = MotionManager()
        
        var body: some View {
            ZStack {
                
                Rectangle()
                    .frame(width: 240, height: 240)
                    .foregroundColor(.pink)
                    .cornerRadius(15)
                    .scaleEffect(1.4)
                    .modifier(ParallaxMotionModifier(manager: manager, magnitude: 48))
                
                Rectangle()
                    .frame(width: 240, height: 240)
                    .foregroundColor(.yellow)
                    .cornerRadius(15)
                    .scaleEffect(1.2)
                    .modifier(ParallaxMotionModifier(manager: manager, magnitude: 42))
                
                Rectangle()
                    .frame(width: 240, height: 240)
                    .foregroundColor(.orange)
                    .cornerRadius(15)
                    .scaleEffect(1.0)
                    .modifier(ParallaxMotionModifier(manager: manager, magnitude: 36))
                
                Rectangle()
                    .frame(width: 240, height: 240)
                    .foregroundColor(.red)
                    .cornerRadius(15)
                    .scaleEffect(0.8)
                    .modifier(ParallaxMotionModifier(manager: manager, magnitude: 30))
                
                Rectangle()
                    .frame(width: 240, height: 240)
                    .foregroundColor(.purple)
                    .cornerRadius(15)
                    .scaleEffect(0.6)
                    .modifier(ParallaxMotionModifier(manager: manager, magnitude: 24))
                
                Rectangle()
                    .frame(width: 240, height: 240)
                    .foregroundColor(.blue)
                    .cornerRadius(15)
                    .scaleEffect(0.4)
                    .modifier(ParallaxMotionModifier(manager: manager, magnitude: 18))
                
                Rectangle()
                    .frame(width: 240, height: 240)
                    .foregroundColor(.green)
                    .cornerRadius(15)
                    .scaleEffect(0.2)
                    .modifier(ParallaxMotionModifier(manager: manager, magnitude: 12))
            }
        }
}

struct ParallaxMotionView_Previews: PreviewProvider {
    static var previews: some View {
        ParallaxMotionView()
    }
}
