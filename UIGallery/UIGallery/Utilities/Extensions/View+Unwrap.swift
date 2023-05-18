import SwiftUI

extension Binding {
    init?(unwrap binding: Binding<Value?>) {
        guard let wrappedValue = binding.wrappedValue else {
            return nil
        }
        
        self.init(
            get: { wrappedValue },
            set: { binding.wrappedValue = $0 }
        )
    }
}

extension Binding {
    func isPresent<Wrapped>() -> Binding<Bool> where Value == Optional<Wrapped> {
        Binding<Bool>(
            get: { self.wrappedValue != nil },
            set: { isPresented in
                if !isPresented {
                    self.wrappedValue = nil
                }
            }
        )
    }
}

extension View {
    func sheet<Value: Identifiable, Content: View>(
        unwrap optionalValue: Binding<Value?>,
        condition: @escaping (Value) -> Bool,
        @ViewBuilder content: @escaping (Binding<Value>) -> Content
    ) -> some View {
        let conditionBinder = Binding(get: {
            optionalValue.wrappedValue.flatMap {
                condition($0) ? $0 : nil
            }
        }, set: { value, _ in
            optionalValue.wrappedValue = value
        })
        
        return self.sheet(item: conditionBinder) { value in
            if let unwrappedBinder = Binding(unwrap: optionalValue) {
                content(unwrappedBinder)
            }
        }
    }
}

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
    
    func alert<A: View, M: View, T>(
        title: (T) -> Text,
        unwrap binder: Binding<T?>,
        condition: @escaping (T) -> Bool,
        @ViewBuilder actions: @escaping (T) -> A,
        @ViewBuilder message: @escaping (T) -> M
    ) -> some View {
        
        let conditionBinder = Binding<Bool>(get: {
            binder.wrappedValue.map(condition) ?? false
        }, set: { isPresent, _ in
            if !isPresent {
                binder.wrappedValue = nil
            }
        })

        return self.alert(
            binder.wrappedValue.map(title) ?? Text(""),
            isPresented: conditionBinder,
            presenting: binder.wrappedValue,
            actions: actions,
            message: message
        )
    }
}

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
    
    func confirmationDialog<A: View, M: View, T>(
        title: (T) -> Text,
        titleVisibility: Visibility = .automatic,
        unwrap binder: Binding<T?>,
        condition: @escaping (T) -> Bool,
        @ViewBuilder actions: @escaping (T) -> A,
        @ViewBuilder message: @escaping (T) -> M
    ) -> some View {
        
        let conditionBinder = Binding<Bool>(get: {
            binder.wrappedValue.map(condition) ?? false
        }, set: { isPresent, _ in
            if !isPresent {
                binder.wrappedValue = nil
            }
        })
        
        return self.confirmationDialog(
            binder.wrappedValue.map(title) ?? Text(""),
            isPresented: conditionBinder,
            titleVisibility: titleVisibility,
            presenting: binder.wrappedValue,
            actions: actions,
            message: message
        )
    }
}
