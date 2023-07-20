import Combine
import Foundation

final class AsyncLoadingPublisher<Event, Value>: Publisher {
    typealias State = LoadingState<Value, Error>
    typealias Output = (event: Event?, state: State)
    typealias Failure = Never

    private let subject = CurrentValueSubject<Output, Never>((nil, .initial))
    private let operation: (Event) async throws -> Value
    private let isSendAllowed: (Event, State) -> Bool
    private var currentTask: Task<Void, Never>?
    private var onceToken = Once.Token()

    var currentState: State {
        subject.value.state
    }

    var currentEvent: Event? {
        subject.value.event
    }

    init(
        operation: @escaping (Event) async throws -> Value,
        isSendAllowed: @escaping (Event, State) -> Bool = ignoreLoadingState
    ) {
        self.operation = operation
        self.isSendAllowed = isSendAllowed
    }

    @MainActor
    func send(_ event: Event) {
        guard isSendAllowed(event, currentState) else {
            return
        }

        let previousTask = currentTask
        let previousOnceToken = onceToken
        let onceToken = Once.Token()
        self.onceToken = onceToken

        let consumeLoading: () -> Void = { [weak self] in
            guard let self else { return }
            previousOnceToken.run {}
            previousTask?.cancel()
            subject.value = (event, .loading)
        }

        let consumeSuccess: (Value) -> Void = { [weak self] value in
            guard let self else { return }
            onceToken.run {
                self.subject.value = (event, .success(value))
            }
        }

        let consumeFailure: (Error) -> Void = { [weak self] error in
            guard let self else { return }
            onceToken.run {
                self.subject.value = (event, .failure(error))
            }
        }

        currentTask = Task<Void, Never> { @MainActor in
            do {
                consumeLoading()
                let value = try await operation(event)
                consumeSuccess(value)
            } catch {
                consumeFailure(error)
            }
        }
    }

    func receive<S>(subscriber: S) where S: Subscriber, Failure == S.Failure, Output == S.Input {
        subject.receive(subscriber: subscriber)
    }
}

extension AsyncLoadingPublisher where Event == Void {
    convenience init(
        operation: @escaping () async throws -> Value,
        isSendAllowed: @escaping (State) -> Bool = ignoreLoadingState
    ) {
        self.init(operation: { @MainActor _ in
            try await operation()
        }, isSendAllowed: { _, state in
            isSendAllowed(state)
        })
    }

    @MainActor
    func load() {
        send(())
    }
}

private func ignoreLoadingState(_: some Any, _ state: LoadingState<some Any, Error>) -> Bool {
    !state.isLoading
}

private func ignoreLoadingState(_ state: LoadingState<some Any, Error>) -> Bool {
    !state.isLoading
}
