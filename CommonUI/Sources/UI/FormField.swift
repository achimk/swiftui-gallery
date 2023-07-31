#if canImport(SwiftUI)
    import SwiftUI

    public struct FormField: View {
        @Binding public var fieldValue: String
        public var fieldName: String
        public var isSecure: Bool

        public var body: some View {
            VStack {
                if isSecure {
                    SecureField(fieldName, text: $fieldValue)
                        .padding(.horizontal)
                } else {
                    TextField(fieldName, text: $fieldValue)
                        .padding(.horizontal)
                }

                Divider()
                    .frame(height: 1.0)
                    .background(Color(red: 240 / 255, green: 240 / 255, blue: 240 / 255))
                    .padding(.horizontal)
            }
            .font(.system(size: 20, weight: .semibold, design: .rounded))
        }
    }

    struct FormField_Previews: PreviewProvider {
        class ViewModel: ObservableObject {
            @Published var text: String = ""
        }

        @ObservedObject static var viewModel = ViewModel()

        static var previews: some View {
            VStack(spacing: 30) {
                Text("FormField")
                FormField(fieldValue: $viewModel.text, fieldName: "Placeholder", isSecure: false)
                Text("FormField (Secured)")
                FormField(fieldValue: $viewModel.text, fieldName: "Placeholder", isSecure: true)
                Button("Submit") {}
            }
        }
    }
#endif
