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
        
        let loading = Just(Output.loading)
            .eraseToAnyPublisher()
        
        let completion = createPublisher(action)
            .first()
            .map {
                Output.success($0)
            }
            .catch {
                Just(Output.failure($0))
                    .setFailureType(to: Never.self)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
        
        cancellable = Publishers.Concatenate(
            prefix: loading,
            suffix: completion)
        .receive(on: scheduler)
        .sink(receiveValue: { [currentState] in
            currentState.value = $0
        })
    }
    
    func receive<S>(subscriber: S) where S : Subscriber, Failure == S.Failure, Output == S.Input {
        currentState.receive(subscriber: subscriber)
    }
}
