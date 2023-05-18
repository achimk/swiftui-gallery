import SwiftUI

struct ColorRowView: View {
    @Binding var color: Color
    @Binding var text: String
    
    var body: some View {
        HStack(alignment: .center) {
            ZStack {
                Circle()
                    .fill(.radialGradient(
                        colors: [color, Color.white],
                        center: .center,
                        startRadius: 0.0,
                        endRadius: 20.0))
                    .frame(width: 43.0)
                    .padding(.top, 2)
                
                Circle()
                    .fill(color)
                    .frame(width: 30.0)
                
            }
            Text(text)
                .font(.system(.body, design: .rounded))
                .foregroundColor(.primary)
            Spacer()
        }
    }
}

struct ColorRowView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 10) {
            
            ColorRowView(
                color: .constant(.mint),
                text: .constant(""))
            
            ColorRowView(
                color: .constant(.pink),
                text: .constant("Pink color"))

            ColorRowView(
                color: .constant(.indigo),
                text: .constant("Lorem ipsum dolor sit amet, consectetur adipiscing elit. Praesent gravida purus sit amet porta feugiat. Curabitur nunc nibh, commodo a arcu eget, consequat pellentesque purus. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Suspendisse aliquam diam libero, nec efficitur lacus porttitor in. Praesent rhoncus efficitur nibh, at molestie mauris sodales sed. Cras sollicitudin nisl at mauris mattis tristique eu suscipit velit. Aliquam hendrerit semper massa in ullamcorper. Nunc nibh lorem, congue venenatis urna in, malesuada consectetur diam. Donec tincidunt tincidunt velit, id vulputate sem interdum vel. Nam consectetur blandit nisl."))
            
            ColorRowView(
                color: .constant(.purple),
                text: .constant("Purple color"))
        }
    }
}
