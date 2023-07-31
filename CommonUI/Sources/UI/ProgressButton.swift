import SwiftUI

public struct ProgressButton: View {
    public var text: String
    public var disabled: Bool = false
    public var inProgress: Bool = false
    public var colors: [Color] = [.pink]
    public var action: () -> Void

    public var body: some View {
        if inProgress {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                .padding()
                .frame(minWidth: 0, maxWidth: .infinity)
                .background(makeBackground())
                .cornerRadius(10)
                .padding(.horizontal)
                .disabled(true)
        } else {
            Button(action: action) {
                Text(text)
                    .foregroundColor(.white)
                    .font(.system(.body, design: .rounded))
                    .bold()
                    .padding()
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .background(makeBackground())
                    .cornerRadius(10)
                    .padding(.horizontal)
                    .disabled(disabled)
            }
        }
    }

    @ViewBuilder
    private func makeBackground() -> some View {
        LinearGradient(
            gradient: Gradient(colors: colors),
            startPoint: .leading,
            endPoint: .trailing
        )
        .opacity(!inProgress && disabled ? 0.4 : 1.0)
    }
}

struct ProgressButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            ProgressButton(text: "Sign In") {}
            ProgressButton(text: "Sign In", inProgress: true) {}
            ProgressButton(text: "Sign In", disabled: true) {}
            ProgressButton(text: "Sign In", disabled: true, inProgress: true) {}
        }
    }
}
