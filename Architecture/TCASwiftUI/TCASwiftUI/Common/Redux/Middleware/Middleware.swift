import Foundation

protocol Middleware<State, Action> {
    associatedtype State
    associatedtype Action
    func handle(
        _ action: Action,
        getState: @escaping () -> State,
        dispatch: @escaping (Action) -> Void) -> Action?
}

