import Combine

final class RootStore<State, Action>: Store {
    private let stateSubject: CurrentValueSubject<State, Never>
    private let reducer: (inout State, Action) -> Void
    
    private(set) var state: State {
        get { stateSubject.value }
        set { stateSubject.value = newValue }
    }
    
    var statePublisher: AnyPublisher<State, Never> {
        stateSubject.eraseToAnyPublisher()
    }
    
    init(
        initialState: State,
        reducer: @escaping (inout State, Action) -> Void
    ) {
        self.stateSubject = CurrentValueSubject(initialState)
        self.reducer = reducer
    }
    
    func send(_ action: Action) {
        reducer(&self.state, action)
    }
}

extension RootStore {
    func scope<LocalState, LocalAction>(
        toLocalState: @escaping (State) -> LocalState,
        fromLocalAction: @escaping (LocalAction) -> Action
    ) -> any Store<LocalState, LocalAction> {
        AnyStore(
            getState: { toLocalState(self.state) },
            dispatch: { self.send(fromLocalAction($0)) },
            statePublisher: statePublisher.map(toLocalState).eraseToAnyPublisher()
        )
    }
}
