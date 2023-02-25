import SwiftUI

struct AngularGradientView: View {
    private let firstGradient = AngularGradient(
        gradient: Gradient(colors: [.orange, .red, .purple]),
        center: UnitPoint(x: 0.5, y: 0.5),
        angle: Angle(degrees: -45))
    
    private let secondGradient = AngularGradient(
        gradient: Gradient(colors: [.orange, .red, .purple]),
        center: UnitPoint(x: 0.5, y: 0.5),
        startAngle: Angle(degrees: 0),
        endAngle: Angle(degrees: 0))
    
    var body: some View {
        
        VStack{
            Text("SwifUI Angular Gradient")
                .font(.system(size: 36))
                .multilineTextAlignment(.center)
                .padding()
                .foregroundColor(.white)
                .background(firstGradient)
            
            Text("SwifUI Angular Gradient")
                .font(.system(size: 36))
                .multilineTextAlignment(.center)
                .padding()
                .foregroundColor(.white)
                .background(secondGradient)
        }
        
    }
}

struct AngularGradientView_Previews: PreviewProvider {
    static var previews: some View {
        AngularGradientView()
    }
}
