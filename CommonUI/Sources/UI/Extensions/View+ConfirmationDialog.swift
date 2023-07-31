import SwiftUI

@available(iOS 15.0, *)
public extension View {
    func confirmationDialog<T>(
        title: (T) -> Text,
        titleVisibility: Visibility = .automatic,
        presenting binder: Binding<T?>,
        @ViewBuilder actions: @escaping (T) -> some View,
        @ViewBuilder message: @escaping (T) -> some View
    ) -> some View {
        confirmationDialog(
            binder.wrappedValue.map(title) ?? Text(""),
            isPresented: binder.isPresent(),
            titleVisibility: titleVisibility,
            presenting: binder.wrappedValue,
            actions: actions,
            message: message
        )
    }
}
