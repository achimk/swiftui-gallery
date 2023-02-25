import SwiftUI

private func minSize(_ geometry: GeometryProxy) -> CGFloat {
    min(geometry.size.width, geometry.size.height)
}

struct ProgressView: View {
    let gradientColors: [Color] = [.blue, .purple]
    let sliceSize = 0.35
    let progress: Double

    init(progress: Double = 0.0) {
        self.progress = progress
    }
 
    var body: some View {
        GeometryReader { geometry in
            ZStack() {
                Group {
                    Circle()
                        .trim(from: 0, to: 1 - CGFloat(sliceSize))
                        .stroke(makeStrokeGradient(), style: makeStrokeStyle(with: geometry))
                        .opacity(0.5)
                    Circle()
                        .trim(from: 0, to: (1 - CGFloat(sliceSize)) * CGFloat(progress))
                        .stroke(makeStrokeGradient(), style: makeStrokeStyle(with: geometry))
                }
                .rotationEffect(.degrees(90) + .degrees(180 * sliceSize))
                
                if progress >= 0.995 {
                    withAnimation {
                        Image(systemName: "star.fill")
                            .font(.system(size: 0.2 * minSize(geometry),
                                          weight: .bold,
                                          design: .rounded))
                            .foregroundColor(.yellow)
                            .offset(y: -0.05 * minSize(geometry))
                    }
                } else {
                    withAnimation {
                        Text(makePercentageText())
                            .font(.system(size: 0.15 * minSize(geometry),
                                          weight: .bold,
                                          design: .rounded))
                            .offset(y: -0.05 * minSize(geometry))
                    }
                }
            }
            .offset(y: 0.1 * minSize(geometry))
            .padding(20)
        }
    }
    
    private func makeStrokeGradient() -> AngularGradient {
        AngularGradient(
            gradient: Gradient(colors: gradientColors),
            center: .center,
            angle: .degrees(-10))
    }
    
    private func makeStrokeStyle(with geometry: GeometryProxy) -> StrokeStyle {
        StrokeStyle(
            lineWidth: 0.08 * minSize(geometry),
            lineCap: .round)
    }
    
    private func makePercentageText() -> String {
        return "\(Int(progress * 100))%"
    }
}

struct ProgressView_Previews: PreviewProvider {
    static var previews: some View {
        ProgressView()
    }
}
