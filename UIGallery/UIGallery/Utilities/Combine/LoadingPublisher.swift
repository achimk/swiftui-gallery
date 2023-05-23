import Combine
import Foundation

class LoadingPublisher<Action, Value, Error: Swift.Error>: Publisher {
    typealias Failure = Never
    typealias Output = LoadingState<Value, Error>
    
    private let scheduler: AnySchedulerOf<DispatchQueue>
    private let currentState = CurrentValueSubject<Output, Failure>(.initial)
    private let createPublisher: (Action) -> AnyPublisher<Value, Error>
    private var cancellable: Cancellable?
    
    var state: Output {
        return currentState.value
    }
    
    init(
        scheduler: AnySchedulerOf<DispatchQueue> = .main,
        createPublisher: @escaping (Action) -> AnyPublisher<Value, Error>
    ) {
        self.scheduler = scheduler
        self.createPublisher = createPublisher
    }
    
    func send(_ action: Action, force: Bool = false) {
        guard state.isLoading || force else {
            return
        }
        
        currentState.value = .loading
        
        cancellable = createPublisher(action)
            .first()
            .receive(on: scheduler)
            .sink(receiveCompletion: { [currentState] completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    currentState.value = .failure(error)
                }
            }, receiveValue: { [currentState] value in
                currentState.value = .success(value)
            })
    }
    
    func receive<S>(subscriber: S) where S : Subscriber, Failure == S.Failure, Output == S.Input {
        currentState.receive(subscriber: subscriber)
    }
}
