import Foundation

@frozen
public enum LoadingState<Success, Failure> {
    case initial
    case loading
    case success(Success)
    case failure(Failure)
}

public extension LoadingState {
    var isInitial: Bool {
        if case .initial = self { return true }
        else { return false }
    }

    var isLoading: Bool {
        if case .loading = self { return true }
        else { return false }
    }

    var isSuccess: Bool {
        if case .success = self { return true }
        else { return false }
    }

    var isFailure: Bool {
        if case .failure = self { return true }
        else { return false }
    }

    var isFinished: Bool {
        isSuccess || isFailure
    }

    func ifInitial(_ action: () -> Void) {
        if case .initial = self { action() }
    }

    func ifLoading(_ action: () -> Void) {
        if case .loading = self { action() }
    }

    func ifSuccess(_ action: (Success) -> Void) {
        if case let .success(value) = self { action(value) }
    }

    func ifFailure(_ action: (Failure) -> Void) {
        if case let .failure(error) = self { action(error) }
    }

    func ifFinished(_ action: () -> Void) {
        if isFinished { action() }
    }
}

public extension LoadingState {
    func map<U>(_ f: (Success) -> U) -> LoadingState<U, Failure> {
        switch self {
        case .initial: return .initial
        case .loading: return .loading
        case let .success(value): return .success(f(value))
        case let .failure(error): return .failure(error)
        }
    }

    func mapError<U>(_ f: (Failure) -> U) -> LoadingState<Success, U> {
        switch self {
        case .initial: return .initial
        case .loading: return .loading
        case let .success(value): return .success(value)
        case let .failure(error): return .failure(f(error))
        }
    }
}

public extension LoadingState {
    var value: Success? {
        switch self {
        case .initial: return nil
        case .loading: return nil
        case let .success(value): return value
        case .failure: return nil
        }
    }

    var error: Failure? {
        switch self {
        case .initial: return nil
        case .loading: return nil
        case .success: return nil
        case let .failure(error): return error
        }
    }
}

public extension LoadingState where Failure: Swift.Error {
    func toResult() -> Result<Success, Failure>? {
        switch self {
        case .initial: return nil
        case .loading: return nil
        case let .success(value): return .success(value)
        case let .failure(error): return .failure(error)
        }
    }
}

extension LoadingState: Equatable where Success: Equatable, Failure: Equatable {
    public static func == (lhs: LoadingState<Success, Failure>, rhs: LoadingState<Success, Failure>) -> Bool {
        switch (lhs, rhs) {
        case (.initial, .initial): return true
        case (.loading, .loading): return true
        case let (.success(l), .success(r)): return l == r
        case let (.failure(l), .failure(r)): return l == r
        default: return false
        }
    }
}
