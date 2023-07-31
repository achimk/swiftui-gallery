import Combine
import CommonUI
import XCTest

class AsyncLoadingPublisherTests: XCTestCase {
    @MainActor
    func test_whenSuccessEvent_shouldReceiveStatesCorrectly() async throws {
        let components = makeTestComponents(operation: withEvent(Int.self))

        components.publisher.send(.success(1))
        try await Task.sleep(nanoseconds: NSEC_PER_SEC)

        XCTAssertEqual(components.stateRecorder.records, [
            .initial,
            .loading,
            .success(1),
        ])
    }

    @MainActor
    func test_whenThrowErrorEvent_shouldReceiveStatesCorrectly() async throws {
        let components = makeTestComponents(operation: withEvent(Int.self))

        components.publisher.send(.throwError(NSError(domain: "test", code: 0)))
        try await Task.sleep(nanoseconds: NSEC_PER_SEC)

        XCTAssertEqual(components.stateRecorder.records, [
            .initial,
            .loading,
            .failure("error"),
        ])
    }

    @MainActor
    func test_whenUncompleteEvent_shouldReceiveStatesCorrectly() async throws {
        let components = makeTestComponents(operation: withEvent(Int.self))

        components.publisher.send(.uncomplete)
        try await Task.sleep(nanoseconds: NSEC_PER_SEC)

        XCTAssertEqual(components.stateRecorder.records, [
            .initial,
            .loading,
        ])
    }

    @MainActor
    func test_whenCancelEvent_shouldReceiveStatesCorrectly() async throws {
        let components = makeTestComponents(operation: withEvent(Int.self), isSendAllowed: allowsAllStates)

        components.publisher.send(.sleep(100, .success(1)))
        components.publisher.send(.success(2))
        try await Task.sleep(nanoseconds: NSEC_PER_SEC)

        XCTAssertEqual(components.stateRecorder.records, [
            .initial,
            .loading,
            .loading,
            .success(2),
        ])
    }
}

extension AsyncLoadingPublisherTests {
    private struct TestComponents<Event, Value: Equatable> {
        let publisher: AsyncLoadingPublisher<Event, Value>
        let stateRecorder: ValueRecoder<LoadingState<Value, String>, Never>
    }

    private func makeTestComponents<Event, Value: Equatable>(
        operation: @escaping (Event) async throws -> Value,
        isSendAllowed: @escaping (Event, LoadingState<Value, Error>) -> Bool = ignoreLoadingState
    ) -> TestComponents<Event, Value> {
        let publisher = AsyncLoadingPublisher(
            operation: operation,
            isSendAllowed: isSendAllowed
        )

        let statePublisher: AnyPublisher<LoadingState<Value, String>, Never> = publisher
            .map { mapEquatable($0.state) }
            .eraseToAnyPublisher()

        let stateRecorder = ValueRecoder(statePublisher)

        return TestComponents(
            publisher: publisher,
            stateRecorder: stateRecorder
        )
    }
}

// MARK: - Operation

@frozen
private enum Event<T> {
    case success(T)
    case uncomplete
    case throwError(Error)
    case sleep(UInt64, Result<T, Error>)
}

private func withEvent<T>(_ type: T.Type) -> @MainActor (_ event: Event<T>) async throws -> T {
    { event in
        switch event {
        case let .success(value):
            return value
        case let .throwError(error):
            throw error
        case .uncomplete:
            return try await uncompleted(T.self)
        case let .sleep(nanoseconds, result):
            return try await withResult(result, nanoseconds: nanoseconds)
        }
    }
}

// MARK: - Async samples

@MainActor
private func withResult<T>(_ result: Result<T, Error>, nanoseconds: UInt64) async throws -> T {
    try await Task.sleep(nanoseconds: nanoseconds)
    return try result.get()
}

@MainActor
private func uncompleted<T>(_: T.Type) async throws -> T {
    try await withCheckedThrowingContinuation { _ in
        // never completed
    }
}

// MARK: - Send event strategies

private func ignoreLoadingState(_: some Any, _ state: LoadingState<some Any, Error>) -> Bool {
    !state.isLoading
}

private func allowsAllStates(_: some Any, _: LoadingState<some Any, Error>) -> Bool {
    true
}

// MARK: - Helpers

private class ValueRecoder<T: Equatable, E: Error> {
    private let publisher: AnyPublisher<T, E>
    private(set) var records: [T] = []
    private var cancellable: AnyCancellable?

    init(_ publisher: AnyPublisher<T, E>) {
        self.publisher = publisher
        cancellable = publisher.sink(receiveCompletion: { _ in
            // ignored
        }, receiveValue: { [weak self] value in
            self?.records.append(value)
        })
    }

    func clear() {
        records = []
    }
}

private func mapEquatable<Value: Equatable>(_ state: LoadingState<Value, some Any>) -> LoadingState<Value, String> {
    switch state {
    case .initial: return .initial
    case .loading: return .loading
    case let .success(value): return .success(value)
    case .failure: return .failure("error")
    }
}
