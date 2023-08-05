import Combine
import CommonUI
import Foundation
import XCTest

// MARK: - Tests

class LoadingPublisherTests: XCTestCase {
    enum Const {
        static let sleepTime: UInt64 = 300
    }

    @MainActor
    func test_whenSuccessEvent_shouldReceiveStatesCorrectly() async throws {
        let components = makeTestComponents(for: Int.self)

        components.publisher.send(.success(1))
        try await Task.sleep(nanoseconds: Const.sleepTime)

        XCTAssertEqual(components.stateRecorder.records, [
            .initial,
            .loading,
            .success(1),
        ])
    }

    @MainActor
    func test_whenThrowErrorEvent_shouldReceiveStatesCorrectly() async throws {
        let components = makeTestComponents(for: Int.self)

        components.publisher.send(.throwError(NSError(domain: "test", code: 0)))
        try await Task.sleep(nanoseconds: Const.sleepTime)

        XCTAssertEqual(components.stateRecorder.records, [
            .initial,
            .loading,
            .failure("error"),
        ])
    }

    @MainActor
    func test_whenUncompleteEvent_shouldReceiveStatesCorrectly() async throws {
        let components = makeTestComponents(for: Int.self)

        components.publisher.send(.uncomplete)
        try await Task.sleep(nanoseconds: Const.sleepTime)

        XCTAssertEqual(components.stateRecorder.records, [
            .initial,
            .loading,
        ])
    }

    @MainActor
    func test_whenCancelEvent_shouldReceiveStatesCorrectly() async throws {
        let components = makeTestComponents(for: Int.self, isSendAllowed: { _, _ in true })

        components.publisher.send(.sleep(100, .success(1)))
        components.publisher.send(.success(2))
        try await Task.sleep(nanoseconds: Const.sleepTime)

        XCTAssertEqual(components.stateRecorder.records, [
            .initial,
            .loading,
            .loading,
            .success(2),
        ])
    }

//    @MainActor
//    func test_multipleCallsPerformance_shouldNotFail() async throws {
//        @MainActor
//        func makeTest() async throws {
//            let components = makeTestComponents(for: Int.self, isSendAllowed: { _, _ in true })
//
//            components.publisher.send(.sleep(100, .success(1)))
//            components.publisher.send(.success(2))
//            try await Task.sleep(nanoseconds: 300)
//
//            let isEqual = (components.stateRecorder.records == [
//                .initial,
//                .loading,
//                .loading,
//                .success(2),
//            ])
//
//            if !isEqual {
//                throw NSError(domain: "Invalid order", code: 0, userInfo: ["records": components.stateRecorder.records])
//            } else {
//                print("test pass!")
//            }
//        }
//
//        let operations = Array(repeating: makeTest, count: 100)
//
//        for operation in operations {
//            try await operation()
//        }
//    }

    // Override enabled

    func makeTestComponents<Value: Equatable>(
        for type: Value.Type,
        isSendAllowed: @escaping (Event<Value>, LoadingState<Value, Error>) -> Bool = { !$1.isLoading }
    ) -> TestComponents<Value> {
        let publisher = LoadingPublisher(
            queue: nil, // Don't specify dispatch queue for test purposes
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
}

// MARK: - Test components

extension LoadingPublisherTests {
    struct TestComponents<Value: Equatable> {
        let publisher: LoadingPublisher<Event<Value>, Value, Error>
        let stateRecorder: ValueRecoder<LoadingState<Value, String>, Never>
    }

    private func withEvent<T>(_: T.Type) -> (_ event: Event<T>, _ completion: @escaping (Result<T, Error>) -> Void) -> AnyCancellable {
        { event, completion in
            var invalidated = false
            switch event {
            case let .success(value):
                completion(.success(value))
            case .uncomplete:
                break
            case let .throwError(error):
                completion(.failure(error))
            case let .sleep(interval, result):
                DispatchQueue.main.asyncAfter(deadline: .now() + .nanoseconds(Int(interval))) {
                    if !invalidated {
                        completion(result)
                    }
                }
            }

            return AnyCancellable {
                invalidated = true
            }
        }
    }
}

// MARK: - Helpers

extension LoadingPublisherTests {
    @frozen
    enum Event<T> {
        case success(T)
        case uncomplete
        case throwError(Error)
        case sleep(UInt64, Result<T, Error>)
    }

    final class ValueRecoder<T: Equatable, E: Error> {
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

    static func mapEquatable<Value: Equatable>(_ state: LoadingState<Value, some Any>) -> LoadingState<Value, String> {
        switch state {
        case .initial: return .initial
        case .loading: return .loading
        case let .success(value): return .success(value)
        case .failure: return .failure("error")
        }
    }
}
