import Combine
import CommonUI
import Foundation
import XCTest

// MARK: - Tests

class LoadingPublisherTests: XCTestCase {
    @MainActor
    func test_whenSuccessEvent_shouldReceiveStatesCorrectly() async throws {
        let components = makeTestComponents(createPublisher: withEvent(Int.self))

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
        let components = makeTestComponents(createPublisher: withEvent(Int.self))

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
        let components = makeTestComponents(createPublisher: withEvent(Int.self))

        components.publisher.send(.uncomplete)
        try await Task.sleep(nanoseconds: NSEC_PER_SEC)

        XCTAssertEqual(components.stateRecorder.records, [
            .initial,
            .loading,
        ])
    }

    @MainActor
    func test_whenCancelEvent_shouldReceiveStatesCorrectly() async throws {
        let components = makeTestComponents(createPublisher: withEvent(Int.self), isSendAllowed: allowsAllStates)

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

extension LoadingPublisherTests {
    private struct TestComponents<Event, Value: Equatable, Error: Swift.Error> {
        let publisher: LoadingPublisher<Event, Value, Error>
        let stateRecorder: ValueRecoder<LoadingState<Value, String>, Never>
    }

    private func makeTestComponents<Event, Value: Equatable, Error: Swift.Error>(
        createPublisher: @escaping (Event, @escaping (Result<Value, Error>) -> Void) -> AnyCancellable,
        isSendAllowed: @escaping (Event, LoadingState<Value, Error>) -> Bool = ignoreLoadingState
    ) -> TestComponents<Event, Value, Error> {
        let publisher = LoadingPublisher(
            queue: nil, // Don't specify dispatch queue for test purposes
            operation: createPublisher,
            isAllowed: isSendAllowed
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

// MARK: - Create publisher

@frozen
private enum Event<T> {
    case success(T)
    case uncomplete
    case throwError(Error)
    case sleep(TimeInterval, Result<T, Error>)
}

private func withEvent<T>(_: T.Type) -> (_ event: Event<T>, _ completion: @escaping (Result<T, Error>) -> Void) -> AnyCancellable {
    { event, completion in
        switch event {
        case let .success(value):
            completion(.success(value))
        case .uncomplete:
            break
        case let .throwError(error):
            completion(.failure(error))
        case let .sleep(interval, result):
            DispatchQueue.main.asyncAfter(deadline: .now() + interval) {
                completion(result)
            }
        }

        return AnyCancellable {}
    }
}

// MARK: - Send event strategies

private func ignoreLoadingState<Error: Swift.Error>(_: some Any, _ state: LoadingState<some Any, Error>) -> Bool {
    !state.isLoading
}

private func allowsAllStates<Error: Swift.Error>(_: some Any, _: LoadingState<some Any, Error>) -> Bool {
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
