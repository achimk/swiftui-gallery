import SwiftUI

enum BottomContentStyle {
    case plain
    case withShadow
}

struct BottomContentViewModifier<BottomContent: View>: ViewModifier {
    // Pass a binding here if you want to get the height of the view
    @Binding var height: CGFloat?
    let style: BottomContentStyle
    let verticalMargin: CGFloat
    let horizontalMargin: CGFloat
    let contentView: BottomContent

    init(
        height: Binding<CGFloat?> = .constant(nil),
        style: BottomContentStyle = .withShadow,
        verticalMargin: CGFloat = 16.0,
        horizontalMargin: CGFloat = 16.0,
        @ViewBuilder contentBuilder: @escaping () -> BottomContent
    ) {
        _height = height
        self.style = style
        self.verticalMargin = verticalMargin
        self.horizontalMargin = horizontalMargin
        contentView = contentBuilder()
    }

    func body(content: Content) -> some View {
        content.safeAreaInset(edge: .bottom) {
            contentView
                .padding(.vertical, verticalMargin)
                .padding(.horizontal, horizontalMargin)
                .frame(maxWidth: .infinity)
                .background(
                    Rectangle()
                        .fill(.white)
                        .when(style == .withShadow) {
                            $0.shadow(
                                color: .black.opacity(0.1),
                                radius: 4.0,
                                x: 0.0,
                                y: 0.0
                            )
                        }
                        .background {
                            GeometryReader { proxy in
                                Color.clear.onAppear {
                                    height = proxy.size.height
                                }
                            }
                        }
                        .ignoresSafeArea(.all, edges: .bottom)
                )
        }
    }
}

extension View {
    func bottomContent(
        height: Binding<CGFloat?> = .constant(nil),
        @ViewBuilder contentBuilder: @escaping () -> some View
    ) -> some View {
        modifier(BottomContentViewModifier(height: height, contentBuilder: contentBuilder))
    }
}

struct BottomContentSampleView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 0.0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 16.0) {
                    ForEach(0 ..< 20) { _ in
                        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
                        Divider()
                    }
                }
                .padding()
            }
            .bottomContent {
                VStack(spacing: 16) {
                    Button("Confirm") {
                        print("-> confirm")
                    }

                    Button("Cancel") {
                        print("-> confirm")
                    }
                }
                .padding()
            }
        }
    }
}

struct BottomContentSampleView_Previews: PreviewProvider {
    static var previews: some View {
        BottomContentSampleView()
    }
}
