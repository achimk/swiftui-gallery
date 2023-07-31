import Foundation

public enum ValidatedResult<Success, Failure> {
    case valid(Success)
    case invalid(Failure)
}

public extension ValidatedResult {
    var value: Success? {
        analyze(valid: { $0 }, invalid: { _ in nil })
    }

    var error: Failure? {
        analyze(valid: { _ in nil }, invalid: { $0 })
    }

    var isValid: Bool {
        analyze(valid: { _ in true }, invalid: { _ in false })
    }

    var isInvalid: Bool {
        !isValid
    }
}

public extension ValidatedResult {
    func map<U>(_ f: (Success) -> U) -> ValidatedResult<U, Failure> {
        flatMap { .valid(f($0)) }
    }

    func flatMap<U>(_ f: (Success) -> ValidatedResult<U, Failure>) -> ValidatedResult<U, Failure> {
        analyze(valid: f, invalid: ValidatedResult<U, Failure>.invalid)
    }

    func mapError<U>(_ f: (Failure) -> U) -> ValidatedResult<Success, U> {
        flatMapError { .invalid(f($0)) }
    }

    func flatMapError<U>(_ f: (Failure) -> ValidatedResult<Success, U>) -> ValidatedResult<Success, U> {
        analyze(valid: ValidatedResult<Success, U>.valid, invalid: f)
    }

    func ifValid(_ action: (Success) -> Void) {
        analyze(valid: action, invalid: { _ in })
    }

    func ifInvalid(_ action: (Failure) -> Void) {
        analyze(valid: { _ in }, invalid: action)
    }

    func analyze<T>(valid: (Success) -> T, invalid: (Failure) -> T) -> T {
        switch self {
        case let .valid(value): return valid(value)
        case let .invalid(error): return invalid(error)
        }
    }
}

public extension ValidatedResult where Failure: Swift.Error {
    func toResult() -> Result<Success, Failure> {
        analyze(
            valid: Result<Success, Failure>.success,
            invalid: Result<Success, Failure>.failure
        )
    }

    func get() throws -> Success {
        switch self {
        case let .valid(value): return value
        case let .invalid(error): throw error
        }
    }
}
