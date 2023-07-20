import Combine
import Foundation

final class LoadingPublisher<Event, Value, Error: Swift.Error>: Publisher {
    typealias State = LoadingState<Value, Error>
    typealias Output = (event: Event?, state: State)
    typealias Failure = Never

    private let scheduler: AnySchedulerOf<DispatchQueue>
    private let subject = CurrentValueSubject<Output, Failure>((nil, .initial))
    private let createPublisher: (Event) -> AnyPublisher<Value, Error>
    private let isSendAllowed: (Event, State) -> Bool
    private var cancellable: Cancellable?

    var currentState: State {
        subject.value.state
    }

    var currentEvent: Event? {
        subject.value.event
    }

    init(
        scheduler: AnySchedulerOf<DispatchQueue> = .main,
        createPublisher: @escaping (Event) -> AnyPublisher<Value, Error>,
        isSendAllowed: @escaping (Event, State) -> Bool = ignoreLoadingState
    ) {
        self.scheduler = scheduler
        self.createPublisher = createPublisher
        self.isSendAllowed = isSendAllowed
    }

    @MainActor
    func send(_ event: Event) {
        guard isSendAllowed(event, currentState) else {
            return
        }

        let loading = Just((event, State.loading))
            .eraseToAnyPublisher()

        let completion = createPublisher(event)
            .first()
            .map {
                (event, State.success($0))
            }
            .catch {
                Just((event, State.failure($0)))
                    .setFailureType(to: Never.self)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()

        cancellable = Publishers.Concatenate(
            prefix: loading,
            suffix: completion
        )
        .receive(on: scheduler)
        .sink(receiveValue: { [subject] in
            subject.value = $0
        })
    }

    func receive<S>(subscriber: S) where S: Subscriber, Failure == S.Failure, Output == S.Input {
        subject.receive(subscriber: subscriber)
    }
}

extension LoadingPublisher where Event == Void {
    convenience init(
        scheduler: AnySchedulerOf<DispatchQueue> = .main,
        createPublisher: @escaping () -> AnyPublisher<Value, Error>,
        isSendAllowed: @escaping (State) -> Bool = ignoreLoadingState
    ) {
        self.init(
            scheduler: scheduler,
            createPublisher: { _ in
                createPublisher()
            }, isSendAllowed: { _, state in
                isSendAllowed(state)
            }
        )
    }

    @MainActor
    func load() {
        send(())
    }
}

private func ignoreLoadingState<Error: Swift.Error>(_: some Any, _ state: LoadingState<some Any, Error>) -> Bool {
    !state.isLoading
}

private func ignoreLoadingState<Error: Swift.Error>(_ state: LoadingState<some Any, Error>) -> Bool {
    !state.isLoading
}
