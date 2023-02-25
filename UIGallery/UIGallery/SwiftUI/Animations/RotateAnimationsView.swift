import SwiftUI

struct RotateAnimationsView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                RotateAnimationSampleView(
                    title: "Rotate forever with auto-reverse",
                    animation: .linear(duration: 1).repeatForever())
                RotateAnimationSampleView(
                    title: "Rotate forever without auto-reverse",
                    animation: .linear(duration: 1).repeatForever(autoreverses: false))
                RotateAnimationSampleView(
                    title: "Rotate with delay",
                    animation: .linear(duration: 1).delay(1).repeatForever(autoreverses: false))
                RotateAnimationSampleView(
                    title: "Rotate with opacity",
                    animation: .linear(duration: 1).repeatForever(autoreverses: false),
                    enableOpacity: true)
                RotateAnimationSampleView(
                    title: "Rotate with fill color",
                    animation: .linear(duration: 1).repeatForever(autoreverses: false),
                    enableFillColor: true)
                RotateAnimationSampleView(
                    title: "Rotate with Frame",
                    animation: .linear(duration: 1).repeatForever(autoreverses: false),
                    enableFrame: true)
            }
        }
    }
}

private struct RotateAnimationSampleView: View {
    @State private var isAnimating = false
    let title: String
    let animation: Animation
    let enableOpacity: Bool
    let enableFillColor: Bool
    let enableFrame: Bool
    
    init(
        title: String,
        animation: Animation,
        enableOpacity: Bool = false,
        enableFillColor: Bool = false,
        enableFrame: Bool = false
    ) {
        self.title = title
        self.animation = animation
        self.enableOpacity = enableOpacity
        self.enableFillColor = enableFillColor
        self.enableFrame = enableFrame
    }
    
    var body: some View {
        VStack {
            RoundedRectangle(cornerRadius: 15.0)
                .fill(enableFillColor ? (isAnimating ? Color.green : Color.red) : Color.red)
                .frame(width: enableFrame ? (isAnimating ? 100 : 200) : 200, height: 200)
                .opacity(enableOpacity ? (isAnimating ? 0.0 : 1.0) : 1.0)
                .rotationEffect(Angle.degrees(isAnimating ? 360 : 0))
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

struct RotateAnimationsView_Previews: PreviewProvider {
    static var previews: some View {
        RotateAnimationsView()
    }
}
