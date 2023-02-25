import SwiftUI

struct TextAddingView: View {
    var body: some View {
        Text("Interactive ")
            .foregroundColor(.yellow)
            .fontWeight(.heavy)
        + Text("tutorials ")
            .foregroundColor(.orange)
            .strikethrough()
        + Text("for ")
            .foregroundColor(.red)
            .italic()
        + Text("SwiftUI")
            .foregroundColor(.purple)
            .underline()
    }
}

struct TextAddingView_Previews: PreviewProvider {
    static var previews: some View {
        TextAddingView()
    }
}
