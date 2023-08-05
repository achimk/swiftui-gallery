import Combine
import Foundation

public final class LoadingPublisher<Event, SuccessType, FailureType: Error>: Publisher {
    public typealias Completion = (Result<SuccessType, FailureType>) -> Void
    public typealias State = LoadingState<SuccessType, FailureType>
    public typealias Output = (event: Event?, state: State)
    public typealias Failure = Never

    private let input = PassthroughSubject<Event, Never>()
    private let output = CurrentValueSubject<Output, Failure>((nil, .initial))
    private let cancellable: AnyCancellable

    public init(
        queue: DispatchQueue? = .main,
        operation: @escaping (Event, @escaping Completion) -> AnyCancellable,
        isAllowed: @escaping (Event, State) -> Bool
    ) {
        cancellable = input
            .scheduleIfNeeded(with: queue)
            .map { [output] in ($0, output.value.state) }
            .filter(isAllowed)
            .flatMap { event, _ in
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
                ).eraseToAnyPublisher()
            }
            .scheduleIfNeeded(with: queue)
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
        operation: @escaping (@escaping Completion) -> AnyCancellable,
        isAllowed: @escaping (State) -> Bool
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
        isAllowed: @escaping (Event, State) -> Bool
    ) {
        var currentTask: Task<Void, Never>?
        let exchangeTask: (() -> Task<Void, Never>?) -> Void = { taskProvider in
            currentTask?.cancel()
            currentTask = taskProvider()
        }

        let taskOperation: (Event, @escaping Completion) -> AnyCancellable = { event, completion in
            exchangeTask {
                Task { @MainActor in
                    do {
                        let value = try await operation(event)
                        if !Task.isCancelled {
                            completion(.success(value))
                        }
                    } catch {
                        if !Task.isCancelled {
                            completion(.failure(error))
                        }
                    }
                }
            }

            // Cancellation occurs in exechangeTask function.
            // For some reasons cancellation from AnyCancellable
            // hasn't been propagated through the Combine stream.
            return AnyCancellable {}
        }

        self.init(
            queue: queue,
            operation: taskOperation,
            isAllowed: isAllowed
        )
    }
}

// MARK: - AnyPublisher cration support

public extension LoadingPublisher {
    convenience init(
        queue: DispatchQueue? = .main,
        operation: @escaping (Event) -> AnyPublisher<SuccessType, FailureType>,
        isAllowed: @escaping (Event, State) -> Bool
    ) {
        let createPublisherOperation: (Event, @escaping Completion) -> AnyCancellable = { event, completion in
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
            operation: createPublisherOperation,
            isAllowed: isAllowed
        )
    }
}

// MARK: - Helpers

private extension Publisher {
    func scheduleIfNeeded(with queue: DispatchQueue?) -> AnyPublisher<Output, Failure> {
        if let queue {
            return receive(on: queue).eraseToAnyPublisher()
        } else {
            return eraseToAnyPublisher()
        }
    }
}

private func createEventPublisher<Event, Output, Failure: Error>(
    with event: Event,
    operation: @escaping (Event, @escaping (Result<Output, Failure>) -> Void) -> AnyCancellable
) -> AnyPublisher<Output, Failure> {
    Deferred {
        var cancellation: AnyCancellable? = nil
        return Future<Output, Failure> { promise in
            cancellation = operation(event, promise)
        }.handleEvents(receiveCancel: {
            cancellation?.cancel()
        })
    }
    .eraseToAnyPublisher()
}
