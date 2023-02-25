import SwiftUI

struct SequenceGestureView: View {
    @State var state = CGSize.zero
    @State var isDraggable = false
    @State var translation = CGSize.zero

    let minimumLongPressDuration = 1.0
    
    var body: some View {
        // Long Tap Gesture
        let longTap = LongPressGesture(minimumDuration: minimumLongPressDuration).onEnded { value in
            withAnimation {
                isDraggable = true
            }
        }

        // Drag Gesture
        let drag = DragGesture().onChanged { value in
            translation = value.translation
            withAnimation {
                isDraggable = true
            }
        }.onEnded { value in
            state.width += value.translation.width
            state.height += value.translation.height
            translation = .zero
            withAnimation {
                isDraggable = false
            }
        }

        // Sequence Gesture
        let sequenceGesture = longTap.sequenced(before: drag)
        
        Circle()
            .foregroundColor(Color.purple)
            .overlay(isDraggable ? Circle().stroke().stroke(Color.white, lineWidth: 2) : nil)
            .frame(width: 240, height: 240)
            .offset(x: state.width + translation.width, y: state.height + translation.height)
            .shadow(radius: isDraggable ? 15 : 0)
            .animation(.linear(duration: minimumLongPressDuration))
            .scaleEffect(isDraggable ? 1.1 : 1.0)
            .gesture(sequenceGesture)
    }
}

struct SequenceGestureView_Previews: PreviewProvider {
    static var previews: some View {
        SequenceGestureView()
    }
}
