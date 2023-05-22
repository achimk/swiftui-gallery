import SwiftUI

struct ScrollHeroView: View {
    @Namespace private var animation
    @State private var selectedIndex: Int?
    
    var body: some View {
        ZStack {
            GeometryReader { proxy in
                ScrollView {
                    VStack(spacing: 40) {
                        ForEach(1...10, id: \.self) { index in
                             makeCardView(index)
                                .onTapGesture {
                                    withAnimation(.spring().speed(0.2)) {
                                        selectedIndex = index
                                    }
                                }
                                
                        }
                    }
                    .frame(width: proxy.size.width)
                }
            }
            
            if let index = selectedIndex {
                makeDetailView(index)
                    .onTapGesture {
                        withAnimation(.spring().speed(0.2)) {
                            selectedIndex = nil
                        }
                    }
            }
        }
    }

    @ViewBuilder
    private func makeCardView(_ index: Int) -> some View {
        ZStack {
            Rectangle()
                .fill(.indigo)
            Text("Index \(index)")
                .foregroundColor(.white)
                .font(.title)
                .bold()
        }
        .frame(width: 200, height: 200)
        .mask {
            RoundedRectangle(cornerRadius: 14)
                .matchedGeometryEffect(id: index, in: animation)
        }
        .shadow(radius: 15)
    }
    
    @ViewBuilder
    private func makeDetailView(_ index: Int) -> some View {
        ZStack {
            Rectangle()
                .fill(.indigo)

            VStack {
                Text("Index \(index)")
                    .foregroundColor(.white)
                    .font(.title)
                    .bold()
                    .padding(.top, 20)
                Spacer()
            }
        }
        .mask {
            RoundedRectangle(cornerRadius: 0)
                .matchedGeometryEffect(id: index, in: animation)
        }
    }
}

struct ScrollHeroView_Previews: PreviewProvider {
    static var previews: some View {
        ScrollHeroView()
    }
}
