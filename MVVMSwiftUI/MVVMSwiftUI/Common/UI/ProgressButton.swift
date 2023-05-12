//
//  ProgressButton.swift
//  MVVMSwiftUI
//
//  Created by Joachim Kret on 12/05/2023.
//

import SwiftUI

struct ProgressButton: View {
    var text: String
    var disabled: Bool = false
    var inProgress: Bool = false
    var colors: [Color] = [.pink]
    var action: () -> Void
    
    var body: some View {
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
            ProgressButton(text: "Sign In") { }
            ProgressButton(text: "Sign In", inProgress: true) { }
            ProgressButton(text: "Sign In", disabled: true) { }
            ProgressButton(text: "Sign In", disabled: true, inProgress: true) { }
        }
    }
}
