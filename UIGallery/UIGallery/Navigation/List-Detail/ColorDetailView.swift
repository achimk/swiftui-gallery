import SwiftUI

struct ColorDetailView: View {
    // iOS 15 availibility only!
    // For presenting on previous system versions
    // please use: @Environment(\.presentationMode)
    @Environment(\.dismiss) var dismiss
    @Binding var colorModel: ColorModel
    var dismissContext: DismissViewModifier.Context = .stack
    
    var body: some View {
        ScrollView {
            VStack {
                Rectangle()
                    .fill(colorModel.color)
                    .frame(height: 240)
                
                VStack {
                    Text(colorModel.title)
                        .font(.system(.title, design: .rounded))
                        .fontWeight(.regular)
                        .padding(.bottom, 10)
                    
                    Text(colorModel.description)
                        .font(.system(.body, design: .rounded))
                }
                .padding()

                Spacer()
            }
        }
        .navigationBarHidden(true)
        .modifier(DismissViewModifier(
            context: dismissContext,
            dismiss: { self.dismiss() })
        )
    }
}

struct ColorDetailView_Previews: PreviewProvider {
    static let colorModel = ColorModel.generate()
    static var previews: some View {
        ColorDetailView(colorModel: .constant(colorModel))
    }
}
