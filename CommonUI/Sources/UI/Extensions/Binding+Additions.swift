#if canImport(SwiftUI)
    import SwiftUI

    public extension Binding {
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

    public extension Binding {
        func isPresent<Wrapped>() -> Binding<Bool> where Value == Wrapped? {
            Binding<Bool>(
                get: { self.wrappedValue != nil },
                set: { isPresented in
                    if !isPresented {
                        self.wrappedValue = nil
                    }
                }
            )
        }

        func isPresent<Wrapped>(with condition: @escaping (Wrapped) -> Bool) -> Binding<Bool> where Value == Wrapped? {
            Binding<Bool>(get: {
                self.wrappedValue.map(condition) ?? false
            }, set: { isPresent in
                if !isPresent {
                    self.wrappedValue = nil
                }
            })
        }

        func isPresent<Wrapped, U>(with condition: @escaping (Wrapped) -> U?) -> Binding<U?> where Value == Wrapped? {
            Binding<U?>(get: {
                self.wrappedValue.flatMap(condition)
            }, set: { value in
                if value == nil {
                    self.wrappedValue = nil
                }
            })
        }
    }
#endif
