//
//  GradientButton.swift
//  MVVMSwiftUI
//
//  Created by Joachim Kret on 11/05/2023.
//

import SwiftUI

struct GradientButton: View {
    var text: String
    var disabled: Bool = false
    var colors: [Color] = [.pink]
    var action: () -> Void
    
    var body: some View {
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
