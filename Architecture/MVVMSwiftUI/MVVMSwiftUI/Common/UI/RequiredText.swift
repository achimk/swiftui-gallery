//
//  RequiredText.swift
//  MVVMSwiftUI
//
//  Created by Joachim Kret on 11/05/2023.
//

import SwiftUI

struct RequiredText: View {
    var iconName: String = "xmark.square"
    var iconColor: Color = .pink
    var text: String = ""
    var isStrikeThrough: Bool = false
    var isLoading: Bool = false
    
    var body: some View {
        HStack {
            if isLoading {
                ProgressView()
                    .padding(.trailing, 1)
            } else {
                Image(systemName: iconName)
                    .foregroundColor(iconColor)
            }
            
            Text(text)
                .font(.system(.body, design: .rounded))
                .foregroundColor(.secondary)
                .strikethrough(!isLoading && isStrikeThrough)
            Spacer()
        }
    }
}

struct RequiredText_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 30) {
            RequiredText(text: "A mimimum 4 characters required")
            
            RequiredText(text: "A mimimum 4 characters required", isStrikeThrough: true)
            
            RequiredText(iconName: "lock.open", text: "Loading state", isLoading: true)
            
            RequiredText(iconName: "lock.open", text: "With custom icon of open lock")
            
            RequiredText(iconName: "lock", text: "With custom icon of closed lock")
            
            RequiredText(iconName: "lock", iconColor: .accentColor, text: "With custom icon color of closed lock")
            
            RequiredText(text: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Praesent gravida purus sit amet porta feugiat. Curabitur nunc nibh, commodo a arcu eget, consequat pellentesque purus. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Suspendisse aliquam diam libero, nec efficitur lacus porttitor in. Praesent rhoncus efficitur nibh, at molestie mauris sodales sed. Cras sollicitudin nisl at mauris mattis tristique eu suscipit velit. Aliquam hendrerit semper massa in ullamcorper. Nunc nibh lorem, congue venenatis urna in, malesuada consectetur diam. Donec tincidunt tincidunt velit, id vulputate sem interdum vel. Nam consectetur blandit nisl.")
        }.padding()
    }
}
