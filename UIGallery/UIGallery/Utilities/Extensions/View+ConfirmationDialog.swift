import SwiftUI

extension View {
    func confirmationDialog<A: View, M: View, T>(
        title: (T) -> Text,
        titleVisibility: Visibility = .automatic,
        presenting binder: Binding<T?>,
        @ViewBuilder actions: @escaping (T) -> A,
        @ViewBuilder message: @escaping (T) -> M
    ) -> some View {
        return self.confirmationDialog(
            binder.wrappedValue.map(title) ?? Text(""),
            isPresented: binder.isPresent(),
            titleVisibility: titleVisibility,
            presenting: binder.wrappedValue,
            actions: actions,
            message: message
        )
    }
}
