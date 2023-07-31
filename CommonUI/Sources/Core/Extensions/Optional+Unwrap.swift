//
// Optional + Unwrap
// Solution based on Dart implementation of Optional:
// https://pub.dev/documentation/optional/latest/optional_internal/Optional-class.html
//

import Foundation

public extension Optional {
    func or(else value: Wrapped) -> Wrapped {
        self == nil ? value : self!
    }

    func or(else action: () -> Wrapped) -> Wrapped {
        self == nil ? action() : self!
    }

    func or(else value: Wrapped?) -> Wrapped? {
        self == nil ? value : self
    }

    func or(else action: () -> Wrapped?) -> Wrapped? {
        self == nil ? action() : self
    }
}
