import SwiftUI

struct ExpadableItemsSampleView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0.0) {
                ExpadableView(title: "StepText component sample") {
                    StepText(number: 1, description: "Text 1")
                    StepText(number: 2, description: "Text 2")
                    StepText(number: 3, description: "Text 3")
                }

                ExpadableView(title: "BodyText component sample") {
                    BodyText("Body text 1")
                    BodyText("Body text 2")
                    BodyText("Body text 3")
                }

                ExpadableView(title: "Any text sample") {
                    Text("Text 1")
                    Text("Text 2")
                    Text("Text 3")
                }

                ExpadableView(title: "Mixed text sample") {
                    BodyText("Body text one line")
                    BodyText(
                        "Body text joined:",
                        "Body text 1",
                        "Body text 2",
                        "Body text 3"
                    )
                    StepText(number: 1, description: "Text 1")
                    StepText(number: 2, description: "Text 2")
                    StepText(number: 3, description: "Text 3")
                    Text("Regular text component")
                }
            }
            .padding()
        }
    }
}

extension ExpadableItemsSampleView {
    struct BodyText: View {
        private let contentText: Text

        init(_ content: String) {
            contentText = Text(content)
        }

        init(_ contents: String..., separator: String = "\n") {
            contentText = Text(contents.joined(separator: separator))
        }

        var body: some View {
            contentText
                .multilineTextAlignment(.leading)
        }
    }

    struct StepText: View {
        let stepPoint: StepPoint
        let stepDescription: String

        init(number: Int, description: String) {
            stepPoint = .init(number: number)
            stepDescription = description
        }

        var body: some View {
            HStack(alignment: .firstTextBaseline) {
                stepPoint
                Text(stepDescription)
            }
        }
    }

    struct StepPoint: View {
        let number: Int

        var body: some View {
            Text("\(number)")
                .foregroundColor(.white)
                .frame(width: 24.0, height: 24.0)
                .background(
                    Circle()
                        .fill(.black)
                )
        }
    }

    struct ExpadableView<Content: View>: View {
        @State var isExpanded = false
        let title: String
        let contentAlignment: HorizontalAlignment
        let contentSpacing: CGFloat
        let verticalMargin: CGFloat
        let horizontalMargin: CGFloat
        let contentView: Content

        init(
            title: String,
            contentAlignment: HorizontalAlignment = .leading,
            contentSpacing: CGFloat = 16.0,
            verticalMargin: CGFloat = 24.0,
            horizontalMargin: CGFloat = 8.0,
            @ViewBuilder contentBuilder: @escaping () -> Content
        ) {
            self.title = title
            self.contentAlignment = contentAlignment
            self.contentSpacing = contentSpacing
            self.verticalMargin = verticalMargin
            self.horizontalMargin = horizontalMargin
            contentView = contentBuilder()
        }

        var body: some View {
            VStack(alignment: .leading, spacing: 0.0) {
                VStack(alignment: .leading, spacing: 0.0) {
                    HStack(spacing: horizontalMargin) {
                        Text(title)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Image(systemName: "chevron.down")
                            .rotationEffect(isExpanded ? .degrees(180.0) : .degrees(0.0))
                    }
                    .padding(.vertical, verticalMargin)
                    .background()
                    .onTapGesture {
                        withAnimation {
                            isExpanded.toggle()
                        }
                    }

                    if isExpanded {
                        VStack(alignment: contentAlignment, spacing: contentSpacing) {
                            contentView
                                .opacity(isExpanded ? 1.0 : 0.0)
                        }
                        .padding(.bottom, verticalMargin)
                        .frame(alignment: .top)
                    }
                }
                .frame(alignment: .top)
                .clipped()

                Divider()
            }
            .frame(alignment: .top)
        }
    }
}

struct ExpadableItemsSampleView_Previews: PreviewProvider {
    static var previews: some View {
        ExpadableItemsSampleView()
    }
}
