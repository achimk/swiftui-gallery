import Combine
import Foundation

public final class LoadingPublisher<Event, SuccessType, FailureType: Error>: Publisher {
    public typealias Completion = (Result<SuccessType, FailureType>) -> Void
    public typealias State = LoadingState<SuccessType, FailureType>
    public typealias Output = (event: Event?, state: State)
    public typealias Failure = Never

    private let input = PassthroughSubject<Event, Never>()
    private let output = CurrentValueSubject<Output, Failure>((nil, .initial))
    private let cancellable: Cancellable

    public init(
        queue: DispatchQueue? = .main,
        operation: @escaping (Event, @escaping Completion) -> Cancellable,
        isAllowed: @escaping (Event, State) -> Bool = LoadingPublisher.whenNotLoading
    ) {
        cancellable = input
            .receiveIfNeeded(on: queue)
            .map { [output] in ($0, output.value.state) }
            .filter(isAllowed)
            .map { event, _ in
                let loading = Just((event, State.loading))
                let successOrFailure = createEventPublisher(
                    with: event,
                    operation: operation
                )
                .map {
                    (event, State.success($0))
                }
                .catch {
                    Just((event, State.failure($0)))
                        .setFailureType(to: Never.self)
                }

                return Publishers.Concatenate(
                    prefix: loading.eraseToAnyPublisher(),
                    suffix: successOrFailure.eraseToAnyPublisher()
                )
            }
            .switchToLatest()
            .receiveIfNeeded(on: queue)
            .sink { [output] result in
                output.value = result
            }
    }

    public func send(_ event: Event) {
        input.send(event)
    }

    public func receive<S>(subscriber: S) where S: Subscriber, Failure == S.Failure, Output == S.Input {
        output.receive(subscriber: subscriber)
    }
}

// MARK: Void Type support

public extension LoadingPublisher where Event == Void {
    convenience init(
        queue: DispatchQueue? = .main,
        operation: @escaping (@escaping Completion) -> Cancellable,
        isAllowed: @escaping (State) -> Bool = LoadingPublisher.whenNotLoading
    ) {
        self.init(
            queue: queue,
            operation: { operation($1) },
            isAllowed: { isAllowed($1) }
        )
    }

    func load() {
        send(())
    }

    func receive<S>(subscriber: S) where S: Subscriber, Failure == S.Failure, State == S.Input {
        output.map(\.state).receive(subscriber: subscriber)
    }
}

// MARK: - Await / Async support

public extension LoadingPublisher where FailureType == Error {
    convenience init(
        queue: DispatchQueue? = .main,
        operation: @escaping (Event) async throws -> SuccessType,
        isAllowed: @escaping (Event, State) -> Bool = LoadingPublisher.whenNotLoading
    ) {
        let taskOperation: (Event, @escaping Completion) -> Cancellable = { event, completion in
            let task = Task { @MainActor in
                do {
                    let value = try await operation(event)
                    try Task.checkCancellation()
                    completion(.success(value))
                } catch {
                    completion(.failure(error))
                }
            }
            return AnyCancellable {
                task.cancel()
            }
        }

        self.init(
            queue: queue,
            operation: taskOperation,
            isAllowed: isAllowed
        )
    }
}

public extension LoadingPublisher where Event == Void, FailureType == Error {
    convenience init(
        queue: DispatchQueue? = .main,
        operation: @escaping () async throws -> SuccessType,
        isAllowed: @escaping (State) -> Bool = LoadingPublisher.whenNotLoading
    ) {
        let asyncOperation: (Event) async throws -> SuccessType = { @MainActor _ in
            try await operation()
        }

        self.init(
            queue: queue,
            operation: asyncOperation,
            isAllowed: { isAllowed($1) }
        )
    }
}

// MARK: - AnyPublisher support

public extension LoadingPublisher {
    convenience init(
        queue: DispatchQueue? = .main,
        operation: @escaping (Event) -> AnyPublisher<SuccessType, FailureType>,
        isAllowed: @escaping (Event, State) -> Bool = LoadingPublisher.whenNotLoading
    ) {
        let sinkOperation: (Event, @escaping Completion) -> Cancellable = { event, completion in
            operation(event)
                .first()
                .sink(receiveCompletion: { receivedCompletion in
                    switch receivedCompletion {
                    case let .failure(error):
                        completion(.failure(error))
                    case .finished:
                        break
                    }
                }, receiveValue: { value in
                    completion(.success(value))
                })
        }

        self.init(
            queue: queue,
            operation: sinkOperation,
            isAllowed: isAllowed
        )
    }
}

public extension LoadingPublisher where Event == Void {
    convenience init(
        queue: DispatchQueue? = .main,
        operation: @escaping () -> AnyPublisher<SuccessType, FailureType>,
        isAllowed: @escaping (State) -> Bool = LoadingPublisher.whenNotLoading
    ) {
        let sinkOperation: (Event) -> AnyPublisher<SuccessType, FailureType> = { _ in
            operation()
        }

        self.init(
            queue: queue,
            operation: sinkOperation,
            isAllowed: { isAllowed($1) }
        )
    }
}

// MARK: - Allow operation strategies

public extension LoadingPublisher {
    static func whenNotLoading(_ state: State) -> Bool {
        !state.isLoading
    }

    static func whenNotLoading(_: Event, _ state: State) -> Bool {
        !state.isLoading
    }

    static func untilNotSuccess(_ state: State) -> Bool {
        state.isInitial || state.isFailure
    }

    static func untilNotSuccess(_: Event, _ state: State) -> Bool {
        state.isInitial || state.isFailure
    }

    static func always(_: State) -> Bool {
        true
    }

    static func always(_: Event, _: State) -> Bool {
        true
    }
}

// MARK: - Helpers

private extension Publisher {
    func receiveIfNeeded(on queue: DispatchQueue?) -> AnyPublisher<Output, Failure> {
        if let queue {
            return receive(on: queue).eraseToAnyPublisher()
        } else {
            return eraseToAnyPublisher()
        }
    }
}

private func createEventPublisher<Event, Output, Failure: Error>(
    with event: Event,
    operation: @escaping (Event, @escaping (Result<Output, Failure>) -> Void) -> Cancellable
) -> AnyPublisher<Output, Failure> {
    Deferred {
        var cancellation: Cancellable? = nil
        return Future<Output, Failure> { promise in
            cancellation = operation(event, promise)
        }.handleEvents(receiveCancel: {
            cancellation?.cancel()
        })
    }
    .eraseToAnyPublisher()
}
