//
//  TextButton.swift
//  MVVMSwiftUI
//
//  Created by Joachim Kret on 11/05/2023.
//

import SwiftUI

struct TextButton: View {
    var text: String
    var textColor: Color = .pink
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(text)
                .font(.system(.body, design: .rounded))
                .bold()
                .foregroundColor(textColor)
        }
    }
}

struct TextButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 4) {
            TextButton(text: "Sign Up") { }
            TextButton(text: "Sign Up", textColor: .green) { }
            TextButton(text: "Sign Up", textColor: .purple) { print("Action!") }
        }
    }
}
