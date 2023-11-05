import Combine

struct AnyStore<State, Action>: Store {
    let statePublisher: AnyPublisher<State, Never>
    private let getState: () -> State
    private let dispatch: (Action) -> Void
    
    var state: State {
        getState()
    }
    
    init(
        getState: @escaping () -> State,
        dispatch: @escaping (Action) -> Void,
        statePublisher: AnyPublisher<State, Never>
    ) {
        self.getState = getState
        self.dispatch = dispatch
        self.statePublisher = statePublisher
    }

    func send(_ action: Action) {
        dispatch(action)
    }
}
