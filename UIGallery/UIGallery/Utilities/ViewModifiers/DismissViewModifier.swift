import SwiftUI

struct DismissViewModifier: ViewModifier {
    
    enum Context {
        case modal
        case stack
        case bottomSheet
    }
    
    var context: Context = .stack
    var dismiss: () -> Void
    
    func body(content: Content) -> some View {
        ZStack(alignment: makeStackAlignment()) {
            content
            
            Button {
                dismiss()
            } label: {
                makeDismissImage()
            }
            .padding()
        }
    }
    
    private func makeStackAlignment() -> Alignment {
        switch context {
        case .modal:
            return .topTrailing
        case .stack:
            return .topLeading
        case .bottomSheet:
            return .center
        }
    }
    
    @ViewBuilder
    private func makeDismissImage() -> some View {
        switch context {
        case .modal:
            Image(systemName: "chevron.down.circle.fill")
                .font(.largeTitle)
                .foregroundColor(.white)
        case .stack:
            Image(systemName: "chevron.left.circle.fill")
                .font(.largeTitle)
                .foregroundColor(.white)
        case .bottomSheet:
            EmptyView()
        }
    }
}
