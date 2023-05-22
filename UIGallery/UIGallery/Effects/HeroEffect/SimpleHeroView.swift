import SwiftUI

struct SimpleHeroView: View {
    @Namespace private var animation
    @State private var isRevealed = false
    
    var body: some View {
        VStack {
            if isRevealed {
                makeDetailView()
            } else {
                makeCardView()
            }
        }
        .onTapGesture {
            withAnimation(.spring()) {
                isRevealed.toggle()
            }
        }
    }
        
    @ViewBuilder
    private func makeCardView() -> some View {
        ZStack {
            Rectangle()
                .fill(.mint)
            Text("Tap me!")
                .foregroundColor(.white)
                .font(.title)
                .bold()
                .matchedGeometryEffect(
                    id: "heroText",
                    in: animation)
        }
        .frame(width: 200, height: 200)
        .mask {
            RoundedRectangle(cornerRadius: 14)
                .matchedGeometryEffect(
                    id: "heroEffect",
                    in: animation)
        }
        .shadow(radius: 15)
    }
    
    @ViewBuilder
    private func makeDetailView() -> some View {
        ZStack {
            Rectangle()
                .fill(.mint)

            VStack {
                Text("Tap me!")
                    .foregroundColor(.white)
                    .font(.title)
                    .bold()
                    .matchedGeometryEffect(
                        id: "heroText",
                        in: animation)
                    .padding(.top, 20)
                Spacer()
            }
        }
        .mask {
            RoundedRectangle(cornerRadius: 0)
                .matchedGeometryEffect(
                    id: "heroEffect",
                    in: animation)
        }
    }
}

struct SimpleHeroView_Previews: PreviewProvider {
    static var previews: some View {
        SimpleHeroView()
    }
}
