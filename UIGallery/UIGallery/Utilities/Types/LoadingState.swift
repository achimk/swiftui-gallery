import Foundation

enum LoadingState<Success, Failure> {
    case initial
    case loading
    case success(Success)
    case failure(Failure)
}

extension LoadingState {
    
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
        return isSuccess || isFailure
    }
    
    func ifInitial(_ action: () -> ()) {
        if case .initial = self { action() }
    }
    
    func ifLoading(_ action: () -> ()) {
        if case .loading = self { action() }
    }
    
    func ifSuccess(_ action: (Success) -> ()) {
        if case .success(let value) = self { action(value) }
    }
    
    func ifFailure(_ action: (Failure) -> ()) {
        if case .failure(let error) = self { action(error) }
    }
    
    func ifFinished(_ action: () -> ()) {
        if isFinished{ action() }
    }
}

extension LoadingState {
    
    func map<U>(_ f: (Success) -> U) -> LoadingState<U, Failure> {
        switch self {
        case .initial: return .initial
        case .loading: return .loading
        case .success(let value): return .success(f(value))
        case .failure(let error): return .failure(error)
        }
    }
    
    func mapError<U>(_ f: (Failure) -> U) -> LoadingState<Success, U> {
        switch self {
        case .initial: return .initial
        case .loading: return .loading
        case .success(let value): return .success(value)
        case .failure(let error): return .failure(f(error))
        }
    }
}

extension LoadingState {
    
    var value: Success? {
        switch self {
        case .initial: return nil
        case .loading: return nil
        case .success(let value): return value
        case .failure: return nil
        }
    }
    
    var error: Failure? {
        switch self {
        case .initial: return nil
        case .loading: return nil
        case .success: return nil
        case .failure(let error): return error
        }
    }
}

extension LoadingState {
 
    func toActivityState() -> ActivityState {
        switch self {
        case .initial: return .initial
        case .loading: return .loading
        case .success: return .success
        case .failure: return .failure
        }
    }
}

extension LoadingState where Failure: Swift.Error {
    
    func toResult() -> Result<Success, Failure>? {
        switch self {
        case .initial: return nil
        case .loading: return nil
        case .success(let value): return .success(value)
        case .failure(let error): return .failure(error)
        }
    }
}

extension LoadingState: Equatable where Success: Equatable, Failure: Equatable {
    
    static func ==(lhs: LoadingState<Success, Failure>, rhs: LoadingState<Success, Failure>) -> Bool {
        switch (lhs, rhs) {
        case (.initial, .initial): return true
        case (.loading, .loading): return true
        case let (.success(l), .success(r)): return l == r
        case let (.failure(l), .failure(r)): return l == r
        default: return false
        }
    }
}
