import Foundation

public extension Optional {
    func ifPresent(_ action: (Wrapped) -> Void) {
        ifPresent(action, otherwise: {})
    }

    func ifPresent(_ action: (Wrapped) -> Void, otherwise: () -> Void) {
        switch self {
        case .none: otherwise()
        case let .some(value): action(value)
        }
    }

    var isPresent: Bool {
        map { _ in true } ?? false
    }
}
