import Combine

protocol Store<State, Action> {
    associatedtype State
    associatedtype Action
    var state: State { get }
    var statePublisher: AnyPublisher<State, Never> { get }
    func send(_ action: Action)
}

extension Store where State: Equatable {
    func toViewStore() -> ViewStore<State, Action> {
        ViewStore(self, observe: { $0 }, removeDuplicates: ==)
    }
}
