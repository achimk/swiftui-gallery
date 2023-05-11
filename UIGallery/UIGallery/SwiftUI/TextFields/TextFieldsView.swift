//
//  TextFieldsView.swift
//  UIGallery
//
//  Created by Joachim Kret on 11/05/2023.
//

import SwiftUI

struct TextFieldsView: View {
    @State private var text: String = ""
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                TextField("Placehoder", text: $text)
                TextField("Placehoder", text: $text)
                    .textFieldStyle(.plain)
                TextField("Placehoder", text: $text)
                    .textFieldStyle(.roundedBorder)
                TextField("Placehoder", text: $text)
                    .textFieldStyle(OutlinedTextFieldStyle())
                TextField("Placehoder", text: $text)
                    .textFieldStyle(OutlinedWithIconTextFieldStyle(icon: Image(systemName: "lock")))
                TextField("Placehoder", text: $text)
                    .textFieldStyle(RoundedTextFieldStyle())
            }
            .padding()
        }
    }
}

struct OutlinedTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        if #available(iOS 15, *) {
            configuration
                .padding()
                .overlay {
                    RoundedRectangle(
                        cornerRadius: 8.0,
                        style: .continuous
                    )
                    .stroke(Color(UIColor.systemGray4), lineWidth: 2.0)
                }
        }
    }
}

struct OutlinedWithIconTextFieldStyle: TextFieldStyle {
    @State var icon: Image?
    
    func _body(configuration: TextField<Self._Label>) -> some View {
        if #available(iOS 15, *) {
            HStack {
                if icon != nil {
                    icon
                        .foregroundColor(Color(UIColor.systemGray4))
                }
                configuration
            }
            .padding()
            .overlay {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(Color(UIColor.systemGray4), lineWidth: 2)
            }
        }
    }
}

struct RoundedTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(.vertical)
            .padding(.horizontal, 24)
            .background(
                Color(UIColor.systemGray6)
            )
            .clipShape(Capsule(style: .continuous))
    }
}

struct TextFieldsView_Previews: PreviewProvider {
    static var previews: some View {
        TextFieldsView()
    }
}
