import SwiftUI

extension View {
    func alert<A: View, M: View, T>(
        title: (T) -> Text,
        presenting binder: Binding<T?>,
        @ViewBuilder actions: @escaping (T) -> A,
        @ViewBuilder message: @escaping (T) -> M
    ) -> some View {
        return self.alert(
            binder.wrappedValue.map(title) ?? Text(""),
            isPresented: binder.isPresent(),
            presenting: binder.wrappedValue,
            actions: actions,
            message: message
        )
    }
}
