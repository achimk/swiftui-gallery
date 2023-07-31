import Combine
import Foundation

public final class LoadingPublisher<Event, Value, Error: Swift.Error>: Publisher {
    public typealias State = LoadingState<Value, Error>
    public typealias Output = (event: Event?, state: State)
    public typealias Failure = Never

    private let scheduler: AnySchedulerOf<DispatchQueue>
    private let subject = CurrentValueSubject<Output, Failure>((nil, .initial))
    private let createPublisher: (Event) -> AnyPublisher<Value, Error>
    private let isSendAllowed: (Event, State) -> Bool
    private var cancellable: Cancellable?

    public var currentState: State {
        subject.value.state
    }

    public var currentEvent: Event? {
        subject.value.event
    }

    public init(
        scheduler: AnySchedulerOf<DispatchQueue> = .main,
        createPublisher: @escaping (Event) -> AnyPublisher<Value, Error>,
        isSendAllowed: @escaping (Event, State) -> Bool = { !$1.isLoading }
    ) {
        self.scheduler = scheduler
        self.createPublisher = createPublisher
        self.isSendAllowed = isSendAllowed
    }

    @MainActor
    public func send(_ event: Event) {
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

    public func receive<S>(subscriber: S) where S: Subscriber, Failure == S.Failure, Output == S.Input {
        subject.receive(subscriber: subscriber)
    }
}

public extension LoadingPublisher where Event == Void {
    convenience init(
        scheduler: AnySchedulerOf<DispatchQueue> = .main,
        createPublisher: @escaping () -> AnyPublisher<Value, Error>,
        isSendAllowed: @escaping (State) -> Bool = { !$0.isLoading }
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
