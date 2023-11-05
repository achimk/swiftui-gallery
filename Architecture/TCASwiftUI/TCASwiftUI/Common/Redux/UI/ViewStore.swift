import Combine

class ViewStore<ViewState, ViewAction>: ObservableObject {
    private(set) lazy var objectWillChange = ObservableObjectPublisher()
    private let dispatch: (ViewAction) -> Void
    private var cancellable: AnyCancellable?
    
    private(set) var state: ViewState {
        willSet {
            objectWillChange.send()
        }
    }
    
    init<S: Store>(
        _ store: S,
        observe toViewState: @escaping (S.State) -> ViewState,
        removeDuplicates isDuplicate: @escaping (ViewState, ViewState) -> Bool
    ) where S.Action == ViewAction {
        state = toViewState(store.state)
        dispatch = store.send(_:)
        cancellable = store.statePublisher
            .map(toViewState)
            .removeDuplicates(by: isDuplicate)
            .sink(receiveValue: { [weak self] viewState in
                self?.state = viewState
            })
    }
    
    func send(_ action: ViewAction) {
        dispatch(action)
    }
}
