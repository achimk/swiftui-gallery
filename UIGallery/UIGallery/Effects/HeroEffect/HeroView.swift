import SwiftUI

struct CardHeroView: View {
    @Namespace private var animation
    @State private var isShowingDetail = false
    
    var body: some View {
        ZStack {
            if isShowingDetail {
                CardDetailView(
                    isShowingDetail: $isShowingDetail,
                    animation: animation)
            } else {
                CardView(
                    isShowingDetail: $isShowingDetail,
                    animation: animation)
            }
        }
    }
}

enum CardHeroAnimationId {
    case backgroundShape
    case backgroundColor
    case backgroundContent
    case tagLabel1
    case tagLabel2
    case title
    case avatar
}

extension CardHeroView {
    
    struct Title: View {
        let text: String
        var body: some View {
            Text(text)
                .font(.headline)
                .fontWeight(.bold)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    struct Avatar: View {
        var body: some View {
            Circle()
                .fill(.white)
                .padding(8)
                .frame(height: 120)
        }
    }
    
    struct TagLabel: View {
        let text: String
        var body: some View {
            Text(text)
                .font(.caption)
                .foregroundColor(.white)
                .padding(.horizontal, 4)
                .padding(.vertical, 4)
                .background(.mint)
                .clipShape(RoundedRectangle(cornerRadius: 4))
        }
    }
    
    struct CloseButton: View {
        @Binding var isPresenting: Bool
        var body: some View {
            Image(systemName: "xmark")
                .font(.system(size: 16))
                .frame(width: 32, height: 32)
                .foregroundColor(.black)
                .background(.white)
                .clipShape(Circle())
                .onTapGesture {
                    withAnimation(.hero) {
                        isPresenting = false
                    }
                }
        }
    }
    
    struct CardView: View {
        @Binding var isShowingDetail: Bool
        let animation: Namespace.ID
        
        var body: some View {
            VStack(spacing: 0) {
                VStack {
                    HStack {
                        Spacer()
                        Avatar()
                            .matchedGeometryEffect(id: CardHeroAnimationId.avatar, in: animation)
                        Spacer()
                    }
                }
                .background(
                    Color.mint
                        .matchedGeometryEffect(id: CardHeroAnimationId.backgroundColor, in: animation)
                )
                
                VStack(alignment: .leading) {
                    Title(text: "Learing hero animation on card view.")
                        .matchedGeometryEffect(id: CardHeroAnimationId.title, in: animation)
                    
                    HStack {
                        TagLabel(text: "Learn")
                            .matchedGeometryEffect(id: CardHeroAnimationId.tagLabel1, in: animation)
                        TagLabel(text: "Test")
                            .matchedGeometryEffect(id: CardHeroAnimationId.tagLabel2, in: animation)
                        Spacer()
                    }
                }
                .padding(8)
                .background(
                    Color.white
                        .matchedGeometryEffect(id: CardHeroAnimationId.backgroundContent, in: animation)
                )
            }
            .frame(width: 200)
            .mask {
                RoundedRectangle(cornerRadius: 14)
                    .matchedGeometryEffect(
                        id: CardHeroAnimationId.backgroundShape,
                        in: animation)
            }
            .shadow(radius: 14)
            .onTapGesture {
                withAnimation(.hero) {
                    isShowingDetail = true
                }
            }
        }
    }

    struct CardDetailView: View {
        @Binding var isShowingDetail: Bool
        let animation: Namespace.ID
        
        var body: some View {
            ZStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        HStack {
                            Spacer()
                            Avatar()
                                .matchedGeometryEffect(id: CardHeroAnimationId.avatar, in: animation)
                            Spacer()
                        }
                        
                        .frame(height: 180)
                        .background(
                            Color.mint
                                .matchedGeometryEffect(id: CardHeroAnimationId.backgroundColor, in: animation)
                        )
                    }
                    
                    VStack(alignment: .leading, spacing: 0) {
                        HStack {
                            TagLabel(text: "Learn")
                                .matchedGeometryEffect(id: CardHeroAnimationId.tagLabel1, in: animation)
                            TagLabel(text: "Test")
                                .matchedGeometryEffect(id: CardHeroAnimationId.tagLabel2, in: animation)
                            
                            Spacer()
                        }
                        
                        Title(text: "Learing hero animation on card view.")
                            .matchedGeometryEffect(id: CardHeroAnimationId.title, in: animation)
                        
                        Spacer()
                    }
                    .padding()
                    .background(
                        Color.white
                            .matchedGeometryEffect(id: CardHeroAnimationId.backgroundContent, in: animation)
                    )
                }
                .mask {
                    RoundedRectangle(cornerRadius: 0)
                        .matchedGeometryEffect(
                            id: CardHeroAnimationId.backgroundShape,
                            in: animation)
                }
                .shadow(radius: 0)
                
                VStack { 
                    HStack {
                        Spacer()
                        CloseButton(isPresenting: $isShowingDetail)
                            .padding()
                    }
                    Spacer()
                }
            }
        }
    }
}

extension Animation {
    static var hero: Animation {
        .interactiveSpring(
            response: 0.6,
            dampingFraction: 0.85,
            blendDuration: 0.25)
        .speed(0.2)
    }
}

struct HeroView_Previews: PreviewProvider {
    @Namespace static var animation
    static var previews: some View {
        SimpleHeroView()
            .previewDisplayName("Simple hero effect")
        
        CardHeroView()
            .previewDisplayName("Card hero effect")
        
        CardHeroView.CardView(
            isShowingDetail: .constant(false),
            animation: animation
        )
        .previewDisplayName("Card view")
        
        CardHeroView.CardDetailView(
            isShowingDetail: .constant(true),
            animation: animation
        )
        .previewDisplayName("Card detail view")
    }
}
