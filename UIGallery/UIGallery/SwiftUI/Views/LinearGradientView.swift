import SwiftUI

struct LinearGradientView: View {
    private let linearGradient = LinearGradient(
        gradient: Gradient(colors: [.orange, .red, .purple]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing)
    
    var body: some View {
        Text("SwifUI Linear Gradient")
            .font(.system(size: 36))
            .padding()
            .foregroundColor(.white)
            .multilineTextAlignment(.center)
            .background(linearGradient)
    }
}

struct LinearGradientView_Previews: PreviewProvider {
    static var previews: some View {
        LinearGradientView()
    }
}
