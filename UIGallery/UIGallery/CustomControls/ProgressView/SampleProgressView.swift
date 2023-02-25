import SwiftUI

struct SampleProgressView: View {
    @State var progress: Double = 0.25
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            ProgressView(progress: progress)
                .padding(20)
            Spacer()
            HStack(spacing: 30) {
                Spacer()
                Button(action: decrement) {
                    Image(systemName: "minus")
                        .frame(width: 44, height: 44)
                        .foregroundColor(Color.white)
                        .background(Color.red)
                        .clipShape(Circle())
                }
                Spacer()
                Button(action: increment) {
                    Image(systemName: "plus")
                        .frame(width: 44, height: 44)
                        .foregroundColor(Color.white)
                        .background(Color.green)
                        .clipShape(Circle())
                }
                Spacer()
            }
            Spacer()
        }
    }
    
    private func increment() {
        withAnimation {
            progress = min(progress + 0.25, 1.0)
        }
    }
    
    private func decrement() {
        withAnimation {
            progress = max(progress - 0.25, 0.0)
        }
    }
    
    struct CircleButtonStyle: ButtonStyle {
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .padding(40)
                .foregroundColor(Color.white)
                .clipShape(Circle())
        }
    }
}


struct SampleProgressView_Previews: PreviewProvider {
    static var previews: some View {
        SampleProgressView()
    }
}
