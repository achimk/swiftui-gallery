import SwiftUI

@available(iOS 15.0, *)
public extension View {
    func alert<T>(
        title: (T) -> Text,
        presenting binder: Binding<T?>,
        @ViewBuilder actions: @escaping (T) -> some View,
        @ViewBuilder message: @escaping (T) -> some View
    ) -> some View {
        alert(
            binder.wrappedValue.map(title) ?? Text(""),
            isPresented: binder.isPresent(),
            presenting: binder.wrappedValue,
            actions: actions,
            message: message
        )
    }
}
