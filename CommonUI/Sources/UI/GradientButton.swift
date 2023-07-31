import SwiftUI

public struct GradientButton: View {
    public var text: String
    public var disabled: Bool = false
    public var colors: [Color] = [.pink]
    public var action: () -> Void

    public var body: some View {
        Button(action: action) {
            Text(text)
                .font(.system(.body, design: .rounded))
                .foregroundColor(.white)
                .bold()
                .padding()
                .frame(minWidth: 0, maxWidth: .infinity)
                .background(LinearGradient(
                    gradient: Gradient(colors: colors),
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .opacity(disabled ? 0.4 : 1.0)
                )
                .cornerRadius(10)
                .padding(.horizontal)
                .disabled(disabled)
        }
    }
}

struct GradientButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            GradientButton(text: "Sign Up") { print("action!") }
            GradientButton(text: "Sign Up", disabled: true) { print("action!") }
            GradientButton(text: "Sign Up", colors: [.orange]) { print("action!") }
            GradientButton(text: "Sign Up", colors: [.purple]) { print("action!") }
            GradientButton(text: "Sign Up", colors: [.purple, .pink]) { print("action!") }
        }
    }
}
