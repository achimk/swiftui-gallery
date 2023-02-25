import SwiftUI

struct Rotate3DAnimationsView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                Rotate3DAnimationSampleView(
                    title: "Rotate forever with auto-reverse",
                    animation: .linear(duration: 1).repeatForever())
                Rotate3DAnimationSampleView(
                    title: "Rotate forever without auto-reverse",
                    animation: .linear(duration: 1).repeatForever(autoreverses: false))
                Rotate3DAnimationSampleView(
                    title: "Rotate with delay",
                    animation: .linear(duration: 1).delay(1).repeatForever(autoreverses: false))
                Rotate3DAnimationSampleView(
                    title: "Rotate with opacity",
                    animation: .linear(duration: 1).repeatForever(),
                    enableOpacity: true)
                Rotate3DAnimationSampleView(
                    title: "Rotate with fill color",
                    animation: .linear(duration: 1).repeatForever(),
                    enableFillColor: true)
                Rotate3DAnimationSampleView(
                    title: "Rotate with Frame",
                    animation: .linear(duration: 1).repeatForever(),
                    enableFrame: true)
            }
        }
    }
}

private struct Rotate3DAnimationSampleView: View {
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
                .rotation3DEffect(Angle.degrees(isAnimating ? 180 : 0), axis: (x: 1, y: 0, z: 0))
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

struct Rotate3DAnimationsView_Previews: PreviewProvider {
    static var previews: some View {
        Rotate3DAnimationsView()
    }
}
