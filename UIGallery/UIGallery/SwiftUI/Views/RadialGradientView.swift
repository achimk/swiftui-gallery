import SwiftUI

struct RadialGradientView: View {
    private let radialGradient = RadialGradient(
        gradient: Gradient(colors: [.orange, .red, .purple]),
        center: UnitPoint(x: 0.5, y: 0.5),
        startRadius: CGFloat(10),
        endRadius: CGFloat(120))
    
    var body: some View {
        Text("SwifUI Radial Gradient")
            .font(.system(size: 36))
            .multilineTextAlignment(.center)
            .padding()
            .foregroundColor(.white)
            .background(radialGradient)
    }
}

struct RadialGradientView_Previews: PreviewProvider {
    static var previews: some View {
        RadialGradientView()
    }
}
