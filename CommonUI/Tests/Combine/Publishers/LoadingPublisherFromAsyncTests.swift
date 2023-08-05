import Combine
import CommonUI
import XCTest

class LoadingPublisherFromAsyncTests: LoadingPublisherTests {
    override func makeTestComponents<Value>(
        for type: Value.Type,
        isSendAllowed: @escaping (LoadingPublisherTests.Event<Value>, LoadingState<Value, Error>) -> Bool = { !$1.isLoading }
    ) -> LoadingPublisherTests.TestComponents<Value> where Value: Equatable {
        let publisher = LoadingPublisher(
            queue: nil,
            operation: withEvent(type),
            isAllowed: isSendAllowed
        )

        let statePublisher: AnyPublisher<LoadingState<Value, String>, Never> = publisher
            .map { Self.mapEquatable($0.state) }
            .eraseToAnyPublisher()

        let stateRecorder = ValueRecoder(statePublisher)

        return TestComponents(
            publisher: publisher,
            stateRecorder: stateRecorder
        )
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
}

// MARK: - Async samples

@MainActor
private func withResult<T>(_ result: Result<T, Error>, nanoseconds: UInt64) async throws -> T {
    try await withTaskCancellationHandler(operation: {
        try await Task.sleep(nanoseconds: nanoseconds)
        return try result.get()
    }, onCancel: {
//        print("=> Sleep task cancelled for:", result)
    })
}

@MainActor
private func uncompleted<T>(_: T.Type) async throws -> T {
    try await withCheckedThrowingContinuation { _ in
        // never completed
    }
}
