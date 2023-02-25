import SwiftUI

struct RepeatAnimationsView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                RepeatAnimationSampleView(
                    title: "Repeat forever with auto-reverse",
                    animation: .linear(duration: 1).repeatForever())
                RepeatAnimationSampleView(
                    title: "Repeat forever without auto-reverse",
                    animation: .linear(duration: 1).repeatForever(autoreverses: false))
                RepeatAnimationSampleView(
                    title: "Repeat with delay",
                    animation: .linear(duration: 1).delay(1).repeatForever())
                RepeatAnimationSampleView(
                    title: "Repeat with opacity",
                    animation: .linear(duration: 1).repeatForever(),
                    enableOpacity: true)
                RepeatAnimationSampleView(
                    title: "Repeat with fill color",
                    animation: .linear(duration: 1).repeatForever(),
                    enableFillColor: true)
                RepeatAnimationSampleView(
                    title: "Repeat with Frame",
                    animation: .linear(duration: 1).repeatForever(),
                    enableFrame: true)
                RepeatAnimationSampleView(
                    title: "Repeat with bottom leading anchor point",
                    animation: .linear(duration: 1).repeatForever(),
                    scaleAnchorPoint: .bottomLeading)
            }
        }
    }
}

private struct RepeatAnimationSampleView: View {
    @State private var isAnimating = false
    let title: String
    let animation: Animation
    let enableOpacity: Bool
    let enableFillColor: Bool
    let enableFrame: Bool
    let scaleAnchorPoint: UnitPoint
    
    init(
        title: String,
        animation: Animation,
        enableOpacity: Bool = false,
        enableFillColor: Bool = false,
        enableFrame: Bool = false,
        scaleAnchorPoint: UnitPoint = .center
    ) {
        self.title = title
        self.animation = animation
        self.enableOpacity = enableOpacity
        self.enableFillColor = enableFillColor
        self.enableFrame = enableFrame
        self.scaleAnchorPoint = scaleAnchorPoint
    }
    
    var body: some View {
        VStack {
            RoundedRectangle(cornerRadius: 15.0)
                .fill(enableFillColor ? (isAnimating ? Color.green : Color.red) : Color.red)
                .frame(width: enableFrame ? (isAnimating ? 100 : 200) : 200, height: 200)
                .opacity(enableOpacity ? (isAnimating ? 0.0 : 1.0) : 1.0)
                .scaleEffect(isAnimating ? 0.5 : 1, anchor: scaleAnchorPoint)
                .animation(isAnimating ? animation : .default)
                .onTapGesture {
                    isAnimating.toggle()
                }
            Text(title)
                .font(.caption)
        }
        .frame(maxWidth: .infinity)
    }
}

struct RepeatAnimationsView_Previews: PreviewProvider {
    static var previews: some View {
        RepeatAnimationsView()
    }
}
