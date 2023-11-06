import SwiftUI

struct TransactionColorView: View {
    let color: Color
    var body: some View {
        ZStack {
            Circle()
                .fill(.radialGradient(
                    colors: [color, Color.white],
                    center: .center,
                    startRadius: 0.0,
                    endRadius: 20.0
                ))
                .frame(width: 43.0)
                .padding(.top, 2)

            Circle()
                .fill(color)
                .frame(width: 30.0)
        }
    }
}

struct TransactionColorView_Previews: PreviewProvider {
    static var previews: some View {
        TransactionColorView(color: .pink)
    }
}
